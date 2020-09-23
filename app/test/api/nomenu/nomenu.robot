*** Settings ***
Documentation   Test k8s backend nomenu API
Resource        ../shared.robot
Library         RequestsLibrary
Library         Collections
Suite Setup     Reset user table
Test Setup      Initialize Test

*** Test Cases ***
Check nomenu
    Login To Backend
    ${resp}=    Get Request     API     /api/nomenu
    Status Should Be    200     ${resp}
    ${data}=    Set Variable    ${resp.json()}
    Should Be Equal     ${data['menu']}     ${None}
