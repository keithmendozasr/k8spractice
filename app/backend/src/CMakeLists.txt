include_directories(${HTTPSERVER_INCLUDE_DIRS})

add_executable(k8spracticebackend main.cpp)

install(TARGETS k8spracticebackend
    RUNTIME DESTINATION bin
)
