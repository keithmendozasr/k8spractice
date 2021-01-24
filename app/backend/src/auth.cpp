#include <iostream>
#include <sstream>
#include <memory>
#include <cstring>
#include <iomanip>
#include <cstring>

#include "log4cplus/loggingmacros.h"
#include "log4cplus/ndc.h"
#include "json/reader.h"

#include "auth.h"

using namespace std;
using namespace httpserver;
using namespace log4cplus;
using namespace Json;

namespace k8sbackend
{
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

    tuple<unique_ptr<unsigned char[]>, unsigned int> Auth::calcPasswordHash(const string &iv, const string &cleartext, HashCtx && ctx)
    {
        auto ctxPtr = ctx.get();
        EVP_DigestUpdate(ctxPtr, &(iv.c_str())[0], iv.size());
        EVP_DigestUpdate(ctxPtr, &(cleartext.c_str())[0], cleartext.size());

        auto outBuf = make_unique<unsigned char[]>(EVP_MAX_MD_SIZE);
        unsigned int outSize;
        EVP_DigestFinal_ex(ctxPtr, outBuf.get(), &outSize);

        return make_tuple(std::move(outBuf), outSize);
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
            auto passwordVal = password.asString();

            LOG4CPLUS_DEBUG(logger, "username: " + userVal);

            auto hasher = buildHasher();

            //TODO: Properly populate the IV
            auto [credHash, hashSize] = calcPasswordHash("", passwordVal, std::move(hasher));
            if(logger.isEnabledFor(TRACE_LOG_LEVEL))
            {
                ostringstream hashStr;
                for(auto i=0; i<hashSize; i++)
                    hashStr << setfill('0') << setw(2) << hex << (int)credHash[i];
                LOG4CPLUS_TRACE(logger, "Value of hash");
                LOG4CPLUS_TRACE(logger, hashStr.str());
            }

            unsigned char expectHash[] = {
                0x9f, 0x86, 0xd0, 0x81, 0x88, 0x4c, 0x7d,
                0x65, 0x9a, 0x2f, 0xea, 0xa0, 0xc5, 0x5a,
                0xd0, 0x15, 0xa3, 0xbf, 0x4f, 0x1b, 0x2b,
                0x0b, 0x82, 0x2c, 0xd1, 0x5d, 0x6c, 0x15,
                0xb0, 0xf0, 0x0a, 0x08
            };

            if(userVal == "user" && memcmp(&expectHash[0], &credHash[0], hashSize) == 0)
            {
                LOG4CPLUS_INFO(logger, string("User \"") + userVal + "\" authorized");
                response = make_shared<string_response>("{data:\"hello\"}");
            }
            else
            {
                LOG4CPLUS_INFO(logger, string("User \"") + userVal + "\" not authorized");
                response = make_shared<string_response>("", http::http_utils::http_unauthorized);
            }
        }
        catch(Json::Exception &e)
        {
            LOG4CPLUS_ERROR(logger, string("Failed to parse request body. Reason: ") + e.what());
            response = make_shared<string_response>("{\"error\":\"Parsing failed\"}", http::http_utils::http_bad_request);
        }

        return response;
    }

    const shared_ptr<http_response> Auth::render_POST(const http_request &request)
    {
        NDCContextCreator logContext(LOG4CPLUS_TEXT(request.get_requestor() + ":" + to_string(request.get_requestor_port())));
        string retVal;
        shared_ptr<http_response> response;

        auto path = request.get_path();
        LOG4CPLUS_DEBUG(logger, string("Value of path: ") + path);
        if(path == "/api/auth/login")
            response = renderLogin(request);
        else
            throw invalid_argument(path + " handler not found");

        return response;
    }
};
