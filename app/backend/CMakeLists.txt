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

ExternalProject_Add(libhttpserver_build
	URL https://github.com/etr/libhttpserver/archive/0.18.2.tar.gz
    URL_HASH SHA256=1dfe548ac2add77fcb6c05bd00222c55650ffd02b209f4e3f133a6e3eb29c89d
    DOWNLOAD_NAME libhttpserver.tar.gz
    PREFIX ${EXTERNLIBS_DIR}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${EXTERNLIBS_DIR} --enable-shared=no --disable-examples --disable-doxygen-doc "CPPFLAGS=${CPPFLAGS} -I${EXTERNLIBS_DIR}/include" "LDFLAGS=${LDFLAGS} -L${EXTERNLIBS_DIR}/lib -pthread"
    BUILD_COMMAND make
    INSTALL_COMMAND make install
)

ExternalProject_Add_Step(libhttpserver_build run_bootstrap
    COMMAND ./bootstrap
    WORKING_DIRECTORY <SOURCE_DIR>
    DEPENDEES patch
    DEPENDERS configure
)
add_dependencies(libhttpserver_build microhttpd_build)

ExternalProject_add(jsoncpp_build
    URL https://github.com/open-source-parsers/jsoncpp/archive/1.9.4.tar.gz
    URL_HASH SHA256=e34a628a8142643b976c7233ef381457efad79468c67cb1ae0b83a33d7493999
    DOWNLOAD_NAME jsoncpp.tar.gz
    PREFIX ${EXTERNLIBS_DIR}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DJSONCPP_WITH_TESTS:BOOL=OFF -DJSONCPP_WITH_POST_BUILD_UNITTEST:BOOL=OFF -JSONCPP_WITH_PKGCONFIG_SUPPORT:BOOL=OFF -DJSONCPP_WITH_CMAKE_PACKAGE:BOOL=OFF -DBUILD_SHARED_LIBS:BOOL=OFF -DBUILD_OBJECT_LIBS:BOOL=OFF
)

find_library(CRYPTO crypto REQUIRED)

include_directories(${CMAKE_BINARY_DIR}/externlibs/include)
link_directories(${CMAKE_BINARY_DIR}/externlibs/lib)

add_subdirectory(src)
