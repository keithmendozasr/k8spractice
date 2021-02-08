#include <iostream>
#include <memory>
#include <iomanip>

#include <log4cplus/logger.h>
#include <log4cplus/loggingmacros.h>
#include <log4cplus/configurator.h>
#include <log4cplus/consoleappender.h>
#include <log4cplus/ndc.h>

#include <httpserver.hpp>

#include "baseresponse.h"
#include "auth.h"

using namespace std;
using namespace log4cplus;
using namespace httpserver;
using namespace k8sbackend;

void configureLogger()
{
    auto logger = Logger::getRoot();
    logger.removeAllAppenders();
    auto appender = SharedAppenderPtr(new ConsoleAppender);
    appender->setName(LOG4CPLUS_TEXT("appender.STDOUT"));
    appender->setLayout(unique_ptr<PatternLayout>(new PatternLayout("%d{%Y-%m-%dT%H%M%S.%q} %5p [%x-%c]: %m%n")));
    logger.addAppender(appender);
    
    logger.setLogLevel(TRACE_LOG_LEVEL);
}

const shared_ptr<http_response> internalErrorHandler(const http_request &req)
{
    auto logger = Logger::getRoot();
    NDCContextCreator logContext(req.get_requestor() + ":" + to_string(req.get_requestor_port()));
    LOG4CPLUS_ERROR(logger, "Error encountered handling " << req.get_path());
    return make_shared<string_response>("", 500);
}

const shared_ptr<http_response> notFoundHandler(const http_request &req)
{
    auto logger = Logger::getRoot();
    NDCContextCreator logContext(req.get_requestor() + ":" + to_string(req.get_requestor_port()));
    LOG4CPLUS_ERROR(logger, "No handler for " << req.get_path());
    return make_shared<string_response>("", 404);
}

int main()
{
    configureLogger();

    auto logger = Logger::getRoot();
    LOG4CPLUS_INFO(logger, "Backend started");

    webserver ws = create_webserver(5000)
        .internal_error_resource(internalErrorHandler)
        .not_found_resource(notFoundHandler);

    BaseResponse handler;
    ws.register_resource("/api/load", &handler);

    Auth authHandler;
    ws.register_resource("/api/auth/login", &authHandler);

    ws.start(true);

    return EXIT_SUCCESS;
}
