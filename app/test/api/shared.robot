*** Settings ***
Library         RedisLibrary
Library         DatabaseLibrary

*** Variables ***
${REDIS_HOST}   localhost
${REDIS_PORT}   6379

*** Keywords ***
Flush Redis Cache
    ${redis_conn}=  Connect To Redis   ${REDIS_HOST}   redis_port=${REDIS_PORT}
    Flush All   ${redis_conn}

Initialize Test
    Flush Redis Cache
    Create Session  API     ${API_HOST}

Reset user table
    Connect To Database
    Delete All Rows From Table      k8spractice.user
    Execute Sql String  INSERT INTO k8spractice.user(name, password, iv, version) VALUES('user', '\\xe7a737823d17e307cb145b6cb64fc90bf132c80d63266330629cbd59dcd5a50f', '\\x6bb23c22a9c2bdb6484261decb3507584537bc1701a080c8e702f0d258ae7397', 1)

Login To Backend
    ${post_body}=   Create Dictionary   user=user   password=123456
    ${resp}=    Post Request    API     /api/auth/login     json=${post_body}
    Status Should Be    200     ${resp}
