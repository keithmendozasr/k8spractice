*** Settings ***
Documentation   Test k8s training payload
Library         SeleniumLibrary
Test Teardown   Close Browser

*** Variables ***
${SITE_URL}     http://localhost:3000
${BROWSER}      Chrome

*** Test Cases ***
Front page unauthenticated
    Given Load Site
    Then Element Should Not Be Visible  nav-load
    And Element Should Not Be Visible  nav-nomenu
    And Element Should Be Visible   name:user
    And Element Should Be Visible   name:password

Front page correct menu
    Given Login to site
    And Wait Until Element Is Enabled   nav-load
    Then Correct nav item   nav-home    ${SITE_URL}/     Home
    And Correct nav item    nav-load    ${SITE_URL}/load     Load
    And Correct nav item    nav-nomenu  ${SITE_URL}/nomenu  No Menu

Navigate To Load
    Given Login to Site
    And Wait Until Element Is Enabled   nav-load
    When Click Link  nav-load
    Then Location Should Be     ${SITE_URL}/load

Navigate To No Menu
    Given Login to Site
    And Wait Until Element Is Enabled   nav-nomenu
    When Click Link  nav-nomenu
    Then Location Should Be     ${SITE_URL}/nomenu

Load Page
    Given Login to Site
    When Go To  ${SITE_URL}/load
    And Wait Until Element Is Enabled   nav-load
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

Login to site
    When Load Site
    And Input Text     name:user   user
    And Input Password  name:password   123456
    And Submit Form     loginform

Correct nav item
    [Arguments]     ${ID}   ${LINK}     ${TEXT}
    Then Element Attribute Value Should Be  ${ID}   href    ${LINK}
    And Element Text Should Be  ${ID}   ${TEXT}
