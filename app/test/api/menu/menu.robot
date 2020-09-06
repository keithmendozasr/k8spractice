*** Settings ***
Documentation   Test k8s backend API
Library         RequestsLibrary
Library         Collections
Test Setup      Initialize Test

*** Test Cases ***
Check Menu
    ${resp}=    Get Request     API     /api/load
    Status Should Be    200     ${resp}
    ${data}=     Set Variable    ${resp.json()}
    Log     ${data}
    Should Be Equal As Integers     ${data['body']['parta']}    1
    ${expected}=    Create List     a   b   c   d
    Lists Should Be Equal   ${data['body']['partb']}   ${expected}
    Should Be Equal     ${data['menu'][0]['title']}     item 1

*** Keywords ***
Initialize Test
    Create Session  API     ${API_HOST}
    ${post_body}=   Create Dictionary   user=user   password=password
    ${resp}=    Post Request    API     /api/auth/login     json=${post_body}
    Status Should Be    200     ${resp}
