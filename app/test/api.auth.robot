*** Settings ***
Documentation   Test k8s backend auth API
Library         REST    ${API_HOST}

*** Variables ***
${PREFIX}   /api/auth

*** Test Cases ***
Successful login
    Given POST  ${PREFIX}/login     { "user": "user", "password": "password" }
    Then Integer    response status     200

GET on login fail
    Given GET   ${PREFIX}/login
    Then Integer    response status     405

Login failed
    Given POST  ${PREFIX}/login     { "user": "user", "password": "baddpass" }
    Then Integer    response status     401
