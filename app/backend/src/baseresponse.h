#pragma once

#include <string>

#include "log4cplus/logger.h"
#include "httpserver.hpp"
#include "json/value.h"
#include "json/writer.h"

namespace k8sbackend
{
    class BaseResponse : public httpserver::http_resource
    {
    private:
        log4cplus::Logger logger = log4cplus::Logger::getInstance("BaseResponse");
        std::unique_ptr<Json::StreamWriter> writer;
        Json::Value responseData;

        void addMenu(const std::string &title, const std::string &link);
        const std::string renderLoad();

    public:
        explicit BaseResponse();
        
        const std::shared_ptr<httpserver::http_response> render_GET(const httpserver::http_request &request);
    };
};
