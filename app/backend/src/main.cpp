#include <iostream>
#include <memory>

#include <log4cplus/logger.h>
#include <log4cplus/loggingmacros.h>
#include <log4cplus/configurator.h>
#include <log4cplus/consoleappender.h>
#include <log4cplus/ndc.h>

#include <httpserver.hpp>

using namespace std;
using namespace log4cplus;
using namespace httpserver;

void configureLogger()
{
    auto logger = Logger::getRoot();
    logger.removeAllAppenders();
    auto appender = SharedAppenderPtr(new ConsoleAppender);
    appender->setName(LOG4CPLUS_TEXT("appender.STDOUT"));
    appender->setLayout(unique_ptr<PatternLayout>(new PatternLayout("%d{%Y-%m-%dT%H%M%S.%q} %5p [%x-%c]: %m%n")));
    logger.addAppender(appender);
    
    logger.setLogLevel(INFO_LOG_LEVEL);
}

class StartingServer : public http_resource {
private:
    Logger logger = Logger::getInstance("StartingServer");

public:
    const shared_ptr<http_response> render(const http_request &request)
    {
        NDCContextCreator ndc(request.get_requestor() + ":" + to_string(request.get_requestor_port()));
        LOG4CPLUS_INFO(logger, "Handling request");
        return make_shared<string_response>("Test");
    };
};

int main()
{
    configureLogger();

    auto logger = Logger::getRoot();
    LOG4CPLUS_INFO(logger, "Backend started");

    webserver ws = create_webserver(5000);
    StartingServer server;
    ws.register_resource("/", &server);
    ws.start(true);


    return EXIT_SUCCESS;
}
