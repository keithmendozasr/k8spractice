*** Settings ***
Documentation   Test k8s backend auth API
Library         RequestsLibrary
Library         RedisLibrary
Test Setup      Initialize Test

*** Variables ***
${PREFIX}   /api/auth
${REDIS_HOST}   localhost
${REDIS_PORT}   6379

*** Test Cases ***
Active Session
    ${post_body}=   create dictionary   user=user   password=password
    ${resp}=    post request    api     ${prefix}/login     json=${post_body}
    status should be    200     ${resp}
    ${resp}=    Get Request     API     ${PREFIX}/checksession
    Status Should Be    200     ${resp}

No session after login failed
    ${post_body}=   Create Dictionary   user=user   password=badpass
    ${resp}=    Post Request    API     ${PREFIX}/login     json=${post_body}
    Status Should Be    401     ${resp}
    ${resp}=    Get Request     API     ${PREFIX}/checksession
    Status Should Be    401     ${resp}

Expired Session
    ${post_body}=   create dictionary   user=user   password=password
    ${resp}=    post request    api     ${prefix}/login     json=${post_body}
    Status Should Be    200     ${resp}
    Flush Redis Cache
    ${resp}=    Get Request     API     ${PREFIX}/checksession
    Log     ${resp}
    Status Should Be    401     ${resp}

*** Keywords ***
Flush Redis Cache
    ${redis_conn}=  Connect To Redis   ${REDIS_HOST}   redis_port=${REDIS_PORT}
    Flush All   ${redis_conn}

Initialize Test
    Flush Redis Cache
    Create Session  API     ${API_HOST}
