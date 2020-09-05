*** Settings ***
Documentation   Test k8s backend auth API
Library         RequestsLibrary
Library         RedisLibrary
Library         Collections
Test Setup      Initialize Test

*** Variables ***
${PREFIX}   /api/auth
${REDIS_HOST}   localhost
${REDIS_PORT}   6379

*** Test Cases ***
Successful login
    ${post_body}=   Create Dictionary   user=user   password=password
    ${resp}=    Post Request    API     ${PREFIX}/login     json=${post_body}
    Status Should Be    200     ${resp}
    ${redis_conn}=  Connect To Redis    ${REDIS_HOST}   redis_port=${REDIS_PORT}
    @{key_list}=    Get All Match Keys  ${redis_conn}   token:*
    ${data}=    Get From Redis  ${redis_conn}   ${key_list[0]}
    Should Be Equal As Strings  user    ${data}
    ${ttl}=     Get Time To Live In Redis   ${redis_conn}   ${key_list[0]}
    Should Be True  ${ttl} <= 600

GET on login fail
    ${resp}     Get Request     API     ${PREFIX}/login
    Status Should Be    405     ${resp}

Login failed
    ${post_body}=   Create Dictionary   user=user   password=badpass
    ${resp}=    Post Request    API     ${PREFIX}/login     json=${post_body}
    Status Should Be    401     ${resp}
    ${redis_conn}=  Connect To Redis    ${REDIS_HOST}   redis_port=${REDIS_PORT}
    @{key_list}=    Get All Match Keys  ${redis_conn}   token:*
    And Should Be Empty     ${key_list}

*** Keywords ***
Flush Redis Cache
    ${redis_conn}=  Connect To Redis   ${REDIS_HOST}   redis_port=${REDIS_PORT}
    Flush All   ${redis_conn}

Initialize Test
    Flush Redis Cache
    Create Session  API     ${API_HOST}
