*** Settings ***
Documentation   Test k8s backend auth API
Library         REST    ${API_HOST}
Library         RedisLibrary
Suite Setup     Flush Redis Cache
Suite Teardown  Flush Redis Cache

*** Variables ***
${PREFIX}   /api/auth
${REDIS_HOST}   localhost
${REDIS_PORT}   6379

*** Test Cases ***
Successful login
    Given POST  ${PREFIX}/login     { "user": "user", "password": "password" }
    Then Integer    response status     200
    ${redis_conn}=  Connect To Redis    ${REDIS_HOST}   redis_port=${REDIS_PORT}
    @{key_list}=    Get All Match Keys  ${redis_conn}   token:*
    ${data}=    Get From Redis  ${redis_conn}   ${key_list[0]}
    And Should Be Equal As Strings  user    ${data}
    ${ttl}=     Get Time To Live In Redis   ${redis_conn}   ${key_list[0]}
    And Should Be True  ${ttl} <= 600
    [Teardown]  Flush All   ${redis_conn}

GET on login fail
    Given GET   ${PREFIX}/login
    Then Integer    response status     405

Login failed
    Given POST  ${PREFIX}/login     { "user": "user", "password": "baddpass" }
    Then Integer    response status     401
    ${redis_conn}=  Connect To Redis    ${REDIS_HOST}   redis_port=${REDIS_PORT}
    @{key_list}=    Get All Match Keys  ${redis_conn}   token:*
    And Should Be Empty     ${key_list}

*** Keywords ***
Flush Redis Cache
    ${redis_conn}=  Connect To Redis   ${REDIS_HOST}   redis_port=${REDIS_PORT}
    Flush All   ${redis_conn}
