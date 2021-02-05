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
        
        const std::string binToHex(const std::basic_string<std::byte> &data);

        const Json::Value parseBody(const std::string &body);

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

        typedef std::tuple<std::basic_string<std::byte>, std::basic_string<std::byte>, unsigned short> UserCredData;
        typedef std::optional<UserCredData> UserCredInfo;
        UserCredInfo getUserCredInfo(const std::string &username);

        std::basic_string<std::byte> calcPasswordHash(const std::basic_string<std::byte> &iv,
            const std::string &cleartext, HashCtx && ctx);
        
        const std::shared_ptr<httpserver::http_response> renderLogin(const httpserver::http_request &request);

    public:
        const std::shared_ptr<httpserver::http_response> render_POST(const httpserver::http_request &request);

    };
};
