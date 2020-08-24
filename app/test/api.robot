*** Settings ***
Documentation   Test k8s backend API
Library         REST    ${API_HOST}

*** Test Cases ***
Check Menu
    Given GET   /api/load
    Then Integer    response status     200
    And Integer     response body body parta    1
    And Array   response body body partb    [ "a", "b", "c", "d" ]
    And String  response body menu 0 title  item 1
