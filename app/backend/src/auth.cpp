#include <iostream>
#include <sstream>
#include <memory>
#include <cstring>
#include <iomanip>
#include <cstring>
#include <utility>
#include <string>
#include <cstddef>
#include <tuple>
#include <algorithm>
#include <random>

#include "log4cplus/loggingmacros.h"
#include "log4cplus/ndc.h"
#include "json/reader.h"
#include "pqxx/connection"
#include "pqxx/transaction"
#include "pqxx/result"
#include "pqxx/binarystring"

#include "auth.h"

using namespace std;
using namespace httpserver;
using namespace log4cplus;
using namespace Json;
using namespace pqxx;

namespace k8sbackend
{
    const string Auth::binToHex(const std::basic_string<byte> &data)
    {
        ostringstream hashStr;
        for(auto i=0; i<data.size(); i++)
            hashStr << setfill('0') << setw(2) << hex << (int)data[i];

        return hashStr.str();
    }

    const Value Auth::parseBody(const string &body)
    {
        LOG4CPLUS_DEBUG(logger, string("BODY data to parse: ") + body);

        istringstream bodyStream(body);
        Value root;
        bodyStream >> root;
        return root;
    }

    Auth::HashCtx Auth::buildHasher(const unsigned short version)
    {
        auto retVal = unique_ptr<EVP_MD_CTX, MdCtxDeleter>(EVP_MD_CTX_new(), MdCtxDeleter());
        auto ptr = retVal.get();
        switch(version)
        {
        case 1:
            EVP_DigestInit_ex(ptr, EVP_sha256(), nullptr);
            break;
        default:
            throw invalid_argument("Invalid hash version value provided");
        }

        return move(retVal);
    }

    Auth::UserCredInfo Auth::getUserCredInfo(const string &username)
    {
        connection dbConn;
        LOG4CPLUS_DEBUG(logger, string("Connected to ") + dbConn.dbname());
        dbConn.prepare("getcreds", "SELECT iv, password, version FROM k8spractice.user WHERE name = $1");

        work tx{dbConn};
        auto dbResult{tx.exec_prepared("getcreds", username)};
        auto rowCount = size(dbResult);

        if(logger.isEnabledFor(TRACE_LOG_LEVEL))
        {
            ostringstream logMsg;
            logMsg << "Number of user rows: " << rowCount;
            LOG4CPLUS_TRACE(logger, logMsg.str());
        }

        if(size(dbResult) == 0)
        {
            LOG4CPLUS_TRACE(logger, "User not found in database");
            return {};
        }

        LOG4CPLUS_TRACE(logger, "User found in database");
        auto row = dbResult[0];
        return make_optional<UserCredData>(row[0].as<basic_string<byte>>(), row[1].as<basic_string<byte>>(), row[2].as<unsigned short>());
    }

    basic_string<byte> Auth::calcPasswordHash(const basic_string<byte> &iv, const string &cleartext, HashCtx && ctx)
    {
        auto ctxPtr = ctx.get();
        EVP_DigestUpdate(ctxPtr, iv.data(), iv.size());
        EVP_DigestUpdate(ctxPtr, cleartext.c_str(), cleartext.size());

        unsigned char outBuf[EVP_MAX_MD_SIZE];
        unsigned int outSize;
        EVP_DigestFinal_ex(ctxPtr, outBuf, &outSize);

        return basic_string<byte>((byte*)outBuf, outSize);
    }

    const shared_ptr<http_response> Auth::renderLogin(const http_request &request)
    {
        shared_ptr<http_response> response;
        try
        {
            auto body = parseBody(request.get_content());
            auto user = body["user"];
            auto password = body["password"];

            if(!user.isString() || !password.isString())
            {
                LOG4CPLUS_INFO(logger, "Missing username or password input value");
                return make_shared<string_response>("{\"error\":\"Failed to parse data\"}", 400);
            }

            auto userVal = user.asString();
            LOG4CPLUS_DEBUG(logger, "username: " << userVal);
            auto credInfo = getUserCredInfo(userVal);

            if(credInfo)
            {
                auto passwordVal = password.asString();
                basic_string<byte> iv, savedPassword;
                unsigned short hashVersion;
                tie(iv, savedPassword, hashVersion) = credInfo.value();
                LOG4CPLUS_TRACE(logger, "Size of iv: " << iv.size());

                auto hasher = buildHasher(hashVersion);

                auto credHash = calcPasswordHash(iv, passwordVal, std::move(hasher));
                if(logger.isEnabledFor(TRACE_LOG_LEVEL))
                {
                    LOG4CPLUS_TRACE(logger, "Value of savedPassword: " << binToHex(savedPassword));
                    LOG4CPLUS_TRACE(logger, "Value of credHash: " << binToHex(credHash));
                }

                if(equal(credHash.begin(), credHash.end(), savedPassword.data()))
                {
                    LOG4CPLUS_INFO(logger, "User \"" << userVal << "\" authorized");
                    response = make_shared<string_response>("{data:\"hello\"}");
                }
                else
                    LOG4CPLUS_DEBUG(logger, "Failed to validate credential for \"" << userVal << "\"");
            }
            else
                LOG4CPLUS_DEBUG(logger, "User \"" << userVal << "\" not found");

            if(!response)
            {
                LOG4CPLUS_INFO(logger, "User \"" << userVal << "\" not authorized");
                response = make_shared<string_response>("", http::http_utils::http_unauthorized);
            }
        }
        catch(Json::Exception &e)
        {
            LOG4CPLUS_ERROR(logger, "Failed to parse request body. Reason: " << e.what());
            response = make_shared<string_response>("{\"error\":\"Parsing failed\"}", http::http_utils::http_bad_request);
        }
        catch(const pqxx::failure &e)
        {
            LOG4CPLUS_ERROR(logger, "DB-related error encountered: " << e.what());
            response = make_shared<string_response>("{\"error\":\"Internal error\"}", http::http_utils::http_internal_server_error);
        }

        return response;
    }

    const shared_ptr<http_response> Auth::render_POST(const http_request &request)
    {
        NDCContextCreator logContext(LOG4CPLUS_TEXT(request.get_requestor() + ":" + to_string(request.get_requestor_port())));
        string retVal;
        shared_ptr<http_response> response;

        auto path = request.get_path();
        LOG4CPLUS_DEBUG(logger, "Value of path: " << path);
        if(path == "/api/auth/login")
            response = renderLogin(request);
        else
            throw invalid_argument(path + " handler not found");

        return response;
    }
};
