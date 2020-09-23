*** Settings ***
Documentation   Test k8s backend auth API
Resource        ../shared.robot
Library         RequestsLibrary
Suite Setup     Reset user table
Test Setup      Initialize Test

*** Variables ***
${PREFIX}   /api/auth
${REDIS_HOST}   localhost
${REDIS_PORT}   6379

*** Test Cases ***
Active Session
    Login To Backend
    ${resp}=    Get Request     API     ${PREFIX}/checksession
    Status Should Be    200     ${resp}

No session after login failed
    ${post_body}=   Create Dictionary   user=user   password=badpass
    ${resp}=    Post Request    API     ${PREFIX}/login     json=${post_body}
    Status Should Be    401     ${resp}
    ${resp}=    Get Request     API     ${PREFIX}/checksession
    Status Should Be    401     ${resp}

Expired Session
    Login To Backend
    Flush Redis Cache
    ${resp}=    Get Request     API     ${PREFIX}/checksession
    Log     ${resp}
    Status Should Be    401     ${resp}
