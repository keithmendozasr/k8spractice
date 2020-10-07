*** Settings ***
Documentation   Test k8s backend user management API
Resource        ../shared.robot
Library         RequestsLibrary
Library         Collections
Library         DatabaseLibrary
Test Setup      Initialize Test
Test Teardown   Disconnect From Database

*** Variables ***
${API_PATH}   /api/auth/usermgnt

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

Update password
    Execute Sql String  INSERT INTO k8spractice.user(name, password, iv, version) VALUES('user', '\\xe7a737823d17e307cb145b6cb64fc90bf132c80d63266330629cbd59dcd5a50f', '\\x6bb23c22a9c2bdb6484261decb3507584537bc1701a080c8e702f0d258ae7397', 1)
    Login To Backend
    ${post_body}=   Create Dictionary   curpass=123456  newpass=abcdefg
    ${resp}=    Post Request    API     ${API_PATH}     json=${post_body}
    Status Should Be    200     ${resp}
    Row Count Is Equal to X     SELECT * FROM k8spractice.user WHERE name='user' AND password = '\\xe7a737823d17e307cb145b6cb64fc90bf132c80d63266330629cbd59dcd5a50f'   0

Update password missing current password
    Execute Sql String  INSERT INTO k8spractice.user(name, password, iv, version) VALUES('user', '\\xe7a737823d17e307cb145b6cb64fc90bf132c80d63266330629cbd59dcd5a50f', '\\x6bb23c22a9c2bdb6484261decb3507584537bc1701a080c8e702f0d258ae7397', 1)
    Login To Backend
    ${post_body}=   Create Dictionary   newpass=abcdefg
    ${resp}=    Post Request    API     ${API_PATH}     json=${post_body}
    Status Should Be    400     ${resp}

Update password missing new password
    Execute Sql String  INSERT INTO k8spractice.user(name, password, iv, version) VALUES('user', '\\xe7a737823d17e307cb145b6cb64fc90bf132c80d63266330629cbd59dcd5a50f', '\\x6bb23c22a9c2bdb6484261decb3507584537bc1701a080c8e702f0d258ae7397', 1)
    Login To Backend
    ${post_body}=   Create Dictionary   curpass=123456
    ${resp}=    Post Request    API     ${API_PATH}     json=${post_body}
    Status Should Be    400     ${resp}

Update password bad credentials
    Execute Sql String  INSERT INTO k8spractice.user(name, password, iv, version) VALUES('user', '\\xe7a737823d17e307cb145b6cb64fc90bf132c80d63266330629cbd59dcd5a50f', '\\x6bb23c22a9c2bdb6484261decb3507584537bc1701a080c8e702f0d258ae7397', 1)
    Login To Backend
    ${post_body}=   Create Dictionary   curpass=9999    newpass=derfgt
    ${resp}=    Post Request    API     ${API_PATH}     json=${post_body}
    Status Should Be    405     ${resp}
    ${data}=    Set Variable    ${resp.json()}
    Should Be Equal     ${data['error']}    Invalid password

*** Keywords ***
Initialize Test
    Connect To Database
    Create Session  API     ${API_HOST}
    Delete All Rows From Table      k8spractice.user
