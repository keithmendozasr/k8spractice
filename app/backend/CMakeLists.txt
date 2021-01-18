cmake_minimum_required(VERSION 3.13)

project(k8spractice_backend
    VERSION 0.0.1)
enable_testing()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(EXTERNLIBS_DIR ${CMAKE_BINARY_DIR}/externlibs)

include(ExternalProject)
ExternalProject_Add(log4cplus_build
    URL https://github.com/log4cplus/log4cplus/releases/download/REL_2_0_5/log4cplus-2.0.5.tar.gz
    URL_HASH SHA256=c07115c23219390633798def30b7b51a0f79fdeb857e4b49632f17746d0ceb97
    PREFIX ${EXTERNLIBS_DIR}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DBUILD_SHARED_LIBS:BOOL=OFF -DLOG4CPLUS_BUILD_TESTING:BOOL=OFF -DLOG4CPLUS_BUILD_LOGGINGSERVER:BOOL=OFF -DWITH_UNIT_TESTS:BOOL=OFF
)

ExternalProject_Add(microhttpd_build
    URL https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.71.tar.gz
    URL_HASH SHA256=e8f445e85faf727b89e9f9590daea4473ae00ead38b237cf1eda55172b89b182
    PREFIX ${EXTERNLIBS_DIR}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${CMAKE_BINARY_DIR}/externlibs --enable-shared=no --enable-https=no
    BUILD_COMMAND make
    INSTALL_COMMAND make install
)

include_directories(${EXTERNLIBS_DIR}/include)
link_directories(${EXTERNLIBS_DIR}/lib)

add_subdirectory(src)
