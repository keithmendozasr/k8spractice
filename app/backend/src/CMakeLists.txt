add_executable(k8spracticebackend main.cpp baseresponse.cpp)
add_dependencies(k8spracticebackend log4cplus_build libhttpserver_build jsoncpp_build)

target_link_libraries(k8spracticebackend
    log4cplusS
    pthread
    httpserver
    microhttpd
    gnutls
    jsoncpp
)
