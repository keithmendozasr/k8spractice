*** Settings ***
Documentation   Test k8s training payload
Library         SeleniumLibrary
Test Teardown   Close Browser

*** Variables ***
${SITE_URL}     http://localhost:3000
${BROWSER}      Chrome

*** Test Cases ***
Front page correct menu
    Given Load Site
    Then Correct nav item   nav-home    ${SITE_URL}/     Home
    And Correct nav item    nav-load    ${SITE_URL}/load     Load
    And Correct nav item    nav-nomenu  ${SITE_URL}/nomenu  No Menu

Navigate To Load
    Given Load Site
    When Click Link  nav-load
    Then Location Should Be     ${SITE_URL}/load

Navigate To No Menu
    Given Load Site
    When Click Link  nav-nomenu
    Then Location Should Be     ${SITE_URL}/nomenu

Load Page
    When Open Browser   ${SITE_URL}/load    ${BROWSER}
    ${elem}=    Get WebElement  link:item 1
    ${link}=    Set Variable    ${SITE_URL}/item1
    Then Element Attribute Value Should Be  ${elem}     href    ${link}

    ${elem}=    Get WebElement  link:item 2
    ${link}=    Set Variable    ${SITE_URL}/item2
    And Element Attribute Value Should Be  ${elem}     href    ${link}

    ${elem}=    Get WebElement  link:item 3
    ${link}=    Set Variable    ${SITE_URL}/item3
    And Element Attribute Value Should Be  ${elem}     href    ${link}

*** Keywords ***

Load Site
    When Open Browser    ${SITE_URL}     ${BROWSER}
    Then Title Should Be     Training payload

Correct nav item
    [Arguments]     ${ID}   ${LINK}     ${TEXT}
    Then Element Attribute Value Should Be  ${ID}   href    ${LINK}
    And Element Text Should Be  ${ID}   ${TEXT}
