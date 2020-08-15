*** Settings ***
Documentation   Test k8s backend API
Library         RequestsLibrary

*** Variables ***
${API_URL}  http://localhost:8000

*** Test Cases ***
Check Menu
    Given Create Session  api     ${API_URL}
    ${resp}=    Get Request     api     /api/load
    Then Status Should Be   200     ${resp}
    ${obj}=     Call Method     ${resp}     json
    And Should Be Equal As Strings   ${obj}[body][parta]     1
    And Should Contain  ${obj}[body][partb]     a
    And Should Contain  ${obj}[body][partb]     b
    And Should Contain  ${obj}[body][partb]     c
