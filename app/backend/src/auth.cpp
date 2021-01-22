#include <sstream>

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
        response = make_shared<string_response>("{data:\"hello\"}");
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
}
