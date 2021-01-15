add_executable(k8spracticebackend main.cpp)
add_dependencies(k8spracticebackend log4cplus_build)

target_link_libraries(k8spracticebackend
    log4cplusS
    pthread
)
