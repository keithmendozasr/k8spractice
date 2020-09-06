*** Settings ***
Documentation   Test k8s backend API
Library         RequestsLibrary
Library         Collections
Test Setup      Initialize Test

*** Test Cases ***
Check nomenu
    ${resp}=    Get Request     API     /api/nomenu
    Status Should Be    200     ${resp}
    ${data}=    Set Variable    ${resp.json()}
    Should Be Equal     ${data['menu']}     ${None}

*** Keywords ***
Initialize Test
    Create Session  API     ${API_HOST}
    ${post_body}=   Create Dictionary   user=user   password=password
    ${resp}=    Post Request    API     /api/auth/login     json=${post_body}
    Status Should Be    200     ${resp}
