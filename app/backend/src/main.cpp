#include <iostream>

#include <log4cplus/logger.h>
#include <log4cplus/loggingmacros.h>
#include <log4cplus/configurator.h>
#include <log4cplus/consoleappender.h>

using namespace std;
using namespace log4cplus;

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

int main()
{
    configureLogger();

    auto logger = Logger::getRoot();
    LOG4CPLUS_INFO(logger, "Backend started");

    return EXIT_SUCCESS;
}
