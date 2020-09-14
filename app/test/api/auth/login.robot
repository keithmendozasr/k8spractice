*** Settings ***
Documentation   Test k8s backend auth API
Library         RequestsLibrary
Library         RedisLibrary
Library         Collections
Library         DatabaseLibrary
Suite Setup     Reset user table
Test Setup      Initialize Test

*** Variables ***
${PREFIX}   /api/auth
${REDIS_HOST}   localhost
${REDIS_PORT}   6379

*** Test Cases ***
Successful login
    ${post_body}=   Create Dictionary   user=user   password=123456
    ${resp}=    Post Request    API     ${PREFIX}/login     json=${post_body}
    Status Should Be    200     ${resp}
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
