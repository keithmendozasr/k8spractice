#pragma once

#include <memory>
#include <string>
#include <tuple>

#include <openssl/evp.h>

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

        class MdCtxDeleter
        {
        public:
            void operator()(EVP_MD_CTX *ctx) const
            {
                EVP_MD_CTX_free(ctx);
            }
        };

        typedef std::unique_ptr<EVP_MD_CTX, MdCtxDeleter> HashCtx;
        HashCtx buildHasher(const unsigned short version = 1);

        std::tuple<std::unique_ptr<unsigned char[]>, unsigned int> calcPasswordHash(const std::string &iv, const std::string &cleartext, HashCtx && ctx);

    public:
        const std::shared_ptr<httpserver::http_response> render_POST(const httpserver::http_request &request);

    };
};
