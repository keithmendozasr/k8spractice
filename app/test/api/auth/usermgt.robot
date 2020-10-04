*** Settings ***
Documentation   Test k8s backend user management API
Library         RequestsLibrary
Library         Collections
Library         DatabaseLibrary
Test Setup      Initialize Test
Test Teardown   Disconnect FroM Database

*** Variables ***
${API_PATH}   /api/auth/usermgt

*** Test Cases ***
Create New User Missing user
    ${post_body}=   Create Dictionary   password=123456
    ${resp}=    Put Request    API     ${API_PATH}     json=${post_body}
    Status Should Be    400     ${resp}
    Row Count Is Equal To X     SELECT * FROM k8spractice.user  0
    
Create New User Missing password
    ${post_body}=   Create Dictionary   user=shouldnotwork
    ${resp}=    Put Request    API     ${API_PATH}     json=${post_body}
    Status Should Be    400     ${resp}
    Row Count Is Equal To X     SELECT * FROM k8spractice.user  0

Create New User
    ${post_body}=   Create Dictionary   user=user   password=123456
    ${resp}=    Put Request    API     ${API_PATH}     json=${post_body}
    Status Should Be    200     ${resp}
    Row Count Is Equal To X     SELECT * FROM k8spractice.user where name='user'    1

Reuse username
    Execute Sql String  INSERT INTO k8spractice.user(name, password, iv, version) VALUES('reuseuser', '\\x11', '\\x12', 1)
    ${post_body}=   Create Dictionary   user=reuseuser   password=123456
    ${resp}=    Put Request    API     ${API_PATH}     json=${post_body}
    Status Should Be    400     ${resp}
    ${data}=    Set Variable    ${resp.json()}
    Should Be Equal     ${data['error']}    Username already exists in the system

Update user password
    Execute Sql String  INSERT INTO k8spractice.user(name, password, iv, version) VALUES('user', '\\xe7a737823d17e307cb145b6cb64fc90bf132c80d63266330629cbd59dcd5a50f', '\\x6bb23c22a9c2bdb6484261decb3507584537bc1701a080c8e702f0d258ae7397', 1)
    ${post_body}=   Create Dictionary   user=user   curpass=123456  newpass=abcdefg
    ${resp}=    Post Request    API     ${API_PATH}     json=${post_body}
    Status Should Be    200     ${resp}

*** Keywords ***
Initialize Test
    Connect To Database
    Create Session  API     ${API_HOST}
    Delete All Rows From Table      k8spractice.user
