#include <sstream>

#include "json/json.h"
#include "log4cplus/loggingmacros.h"
#include "log4cplus/ndc.h"

#include "baseresponse.h"

using namespace std;
using namespace Json;
using namespace httpserver;
using namespace log4cplus;

namespace k8sbackend
{
    void BaseResponse::addMenu(const string &title, const string &link)
    {
        Value menuItem;
        menuItem["title"] = title;
        menuItem["link"] = link;
        responseData["menu"].append(menuItem);
    }

    BaseResponse::BaseResponse()
    {
        StreamWriterBuilder builder;
        builder["indentation"]="";
        writer = unique_ptr<StreamWriter>(builder.newStreamWriter());
    }

    const string BaseResponse::renderLoad()
    {
        LOG4CPLUS_DEBUG(logger, "Render load data");

        addMenu("item 1", "/item1");
        addMenu("item 2", "/item2");
        addMenu("item 3", "/item3");

        ostringstream outBuffer;
        writer->write(responseData, &outBuffer);
        return outBuffer.str();
    }

    const std::shared_ptr<httpserver::http_response> BaseResponse::render_GET(const httpserver::http_request &request)
    {
        NDCContextCreator logContext(LOG4CPLUS_TEXT(request.get_requestor() + ":" + to_string(request.get_requestor_port())));
        string retVal;
        shared_ptr<http_response> response;

        auto path = request.get_path();
        LOG4CPLUS_DEBUG(logger, "Value of path: " << path);
        if(path == "/api/load")
            response = make_shared<string_response>(renderLoad());
        else
            throw invalid_argument(path + " handler not found");

        responseData.clear();
        return response;
    }
};
