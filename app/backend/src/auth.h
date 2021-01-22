#pragma once

#include <memory>
#include <string>

#include "log4cplus/logger.h"
#include "httpserver.hpp"
#include "json/value.h"

namespace k8sbackend
{
    class Auth : public httpserver::http_resource
    {
    private:
        log4cplus::Logger logger = log4cplus::Logger::getInstance("Auth");
        
        const Json::Value parseBody(const std::string &body);
        const std::shared_ptr<httpserver::http_response> renderLogin(const httpserver::http_request &request);

    public:
        const std::shared_ptr<httpserver::http_response> render_POST(const httpserver::http_request &request);
    };
};
