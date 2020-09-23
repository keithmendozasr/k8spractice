*** Settings ***
Documentation   Test k8s backend auth API
Resource        ../shared.robot
Library         RequestsLibrary
Library         Collections
Suite Setup     Reset user table
Test Setup      Initialize Test

*** Variables ***
${PREFIX}   /api/auth
${REDIS_HOST}   localhost
${REDIS_PORT}   6379

*** Test Cases ***
Successful login
    Login To Backend
    ${redis_conn}=  Connect To Redis    ${REDIS_HOST}   redis_port=${REDIS_PORT}
    @{key_list}=    Get All Match Keys  ${redis_conn}   token:*
    ${data}=    Get From Redis  ${redis_conn}   ${key_list[0]}
    Should Be Equal As Strings  user    ${data}
    ${ttl}=     Get Time To Live In Redis   ${redis_conn}   ${key_list[0]}
    Should Be True  ${ttl} <= 600
    ${resp}=    Get Request     API     /api/nomenu
    Status Should Be    200     ${resp}

GET on login fail
    ${resp}     Get Request     API     ${PREFIX}/login
    Status Should Be    405     ${resp}

Unregistered user
    ${post_body}=   Create Dictionary   user=notpresent   password=wontmatter
    ${resp}=    Post Request    API     ${PREFIX}/login     json=${post_body}
    Status Should Be    401     ${resp}
    ${redis_conn}=  Connect To Redis    ${REDIS_HOST}   redis_port=${REDIS_PORT}
    @{key_list}=    Get All Match Keys  ${redis_conn}   token:*
    Should Be Empty     ${key_list}
