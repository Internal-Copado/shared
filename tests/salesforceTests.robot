*** Settings ***
Library                         QForce
Library                         String
Library                         DateTime
# Library                         RetryFailed    global_retries=1   keep_retried_tests=False    log_level=None


*** Variables ***
${BROWSER}                      chrome

${home_url}                     ${login_url}/lightning/page/home
${applauncher}                  //*[contains(@class, "appLauncher")]

${company}                      ExampleCorp
${accountName}                  ExamplaryBranch
${first}                        Demo
${last}                         McTest
${email}                        DTest@test.test
${phone}                        1234567890

${demoFirst}                    Marty
${demoLast}                     McFly

*** Keywords ***

Setup Browser
    Set Library Search Order    QWeb
    Evaluate                    random.seed()
    Open Browser                about:blank                 ${BROWSER}
    SetConfig                   LineBreak                   ${EMPTY}                    #\ue000
    SetConfig                   DefaultTimeout              20s                         #sometimes salesforce is slow
    SetConfig                   CaseInsensitive             True

Setup Incognito Browser
    Set Library Search Order    QWeb
    Evaluate                    random.seed()
    Open Browser                about:blank                 ${BROWSER}    --incognito
    SetConfig                   LineBreak                   ${EMPTY}                    #\ue000
    SetConfig                   DefaultTimeout              20s                         #sometimes salesforce is slow
    SetConfig                   CaseInsensitive             True

Form Fill
    [Documentation]             This requests a demo
    TypeText                    First Name*                 Marty
    TypeText                    Last Name*                  McFly
    TypeText                    Business Email*             delorean88@copado.com
    TypeText                    Phone*                      1234567890
    TypeText                    Company*                    Copado
    TypeText                    Job Title*                  Sales Engineer
    DropDown                    Country                     United States

End suite
    Close All Browsers

Form fill demo
    TypeText                    First Name*                 Marty
    TypeText                    Last Name*                  McFly
    TypeText                    Business Email*             delorean88@copado.com
    TypeText                    Phone*                      1234567890
    TypeText                    Company*                    Copado
    DropDown                    Employee Size*              1-2,500
    TypeText                    Job Title*                  Sales Engineer
    DropDown                    Country                     Netherlands

Form Fill Training
    [Documentation]             This keyword was generated during the training and can be used to fill in the form on the copado website
    TypeText                    First Name*                 Marty
    TypeText                    Last Name*                  McFly
    TypeText                    Business Email*             delorean88@copado.com
    TypeText                    Phone*                      1234567890
    TypeText                    Company*                    Copado
    DropDown                    Employee Size*              1-2,500
    TypeText                    Job Title*                  Sales Engineer
    DropDown                    Country                     Netherlands

Login
    [Documentation]             Login to Salesforce instance
    GoTo                        ${login_url}
    TypeText                    Username                    ${username}
    TypeText                    Password                    ${password}
    ClickText                   Log In
    ${isMFA}=                   IsText                      Verify Your Identity        #Determines MFA is prompted
    Log To Console              ${isMFA}
    IF                          ${isMFA}                    #Conditional Statement for if MFA verification is required to proceed
        ${mfa_code}=            GetOTP                      ${username}                 ${MY_SECRET}                ${password}
        TypeSecret              Code                        ${mfa_code}
        ClickText               Verify
    END

Setup       
    GoTo                        ${login_url}lightning/setup/SetupOneHome/home

Home
    [Documentation]             Navigate to homepage, login if needed
    End suite
    Setup Browser
    # Setup Incognito Browser
    GoTo                        ${home_url}
    ${login_status}=            IsText                      To access this page, you have to log in to Salesforce.                              10
    Run Keyword If              ${login_status}             Login
    VerifyText                  Home

InsertRandomValue
    [Documentation]             This keyword accepts a character count, suffix, and prefix.
    ...                         It then types a random string into the given field.
    ...                         This is an example of generating dynamic data within a test
    ...                         and how to create a keyword with optional/default arguments.
    [Arguments]                 ${field}                    ${charCount}=5              ${prefix}=                  ${suffix}=
    Set Library Search Order    QWeb
    ${testRandom}=              Generate Random String      ${charCount}
    TypeText                    ${field}                    ${prefix}${testRandom}${suffix}


VerifyNoAccounts
    VerifyNoText                ${accountName}              timeout=3


DeleteData
    [Documentation]             RunBlock to remove all data until it doesn't exist anymore
    ClickText                   ${accountName}
    ClickText                   Show more actions
    ClickText                   Delete
    VerifyText                  Are you sure you want to delete this account?
    # ClickText                   Delete                      2
    ClickText    Delete
    VerifyText                  Undo
    VerifyNoText                Undo
    ClickText                   Accounts                    partial_match=False

Cleanup                   
    Login
    Sleep                       3
    LaunchApp                   Sales
    ClickText                   Accounts
    RunBlock                    VerifyNoAccounts            timeout=180s                exp_handler=DeleteData
    Sleep                       3

MFA Login
    ${isMFA}=                   IsText                      Verify Your Identity        #Determines MFA is prompted
    Log To Console              ${isMFA}
    IF                          ${isMFA}                    #Conditional Statement for if MFA verification is required to proceed
        ${mfa_code}=            GetOTP                      ${username}                 ${MY_SECRET}                ${password}
        TypeSecret              Code                        ${mfa_code}
        ClickText               Verify
    END

ExampleKey
    ClickText                   New
    UseModal                    On
    ClickText                   Account Name
    TypeText                    Account Name                App
    PickList                    Account Currency            USD - U.S. Dollar
    ClickText                   Save                        anchor=SaveEdit
    UseModal                    Off

Commonfunction
    ClickText                   Opportunities
    ClickText                   New
    UseModal                    On
    ClickText                   Complete this field.
    TypeText                    Close Date                  12/1/2022

    ClickText                   Complete this field.
    TypeText                    *Opportunity Name           Hidde BV
    ClickText                   Save                        partial_match=False
    PickList                    *Stage                      Prospecting
    ClickText                   Save                        partial_match=False
    UseModal                    Off

    ClickText                   View profile
    VerifyText                  TEST ROBOT
    ClickText                   Log Out

Login As
    [Documentation]             Login As different persona. User needs to be logged into Salesforce with Admin rights
    ...                         before calling this keyword to change persona.
    ...                         Example:
    ...                         LoginAs                     Chatter Expert
    [Arguments]                 ${persona}
    ClickText                   Setup
    ClickText                   Setup for current app
    SwitchWindow                NEW
    TypeText                    Search Setup                ${persona}                  delay=2
    ClickText                   User                        anchor=${persona}           delay=5                     # wait for list to populate, then click
    VerifyText                  Freeze                      timeout=45                  # this is slow, needs longer timeout
    ClickText                   Login                       anchor=Freeze               delay=1

Close Intelligence View Popup
    [Documentation]    This keyword checks for the presence of the "Intelligence View" popup 
    ...                by looking for the text "Check Out the Intelligence View". 
    ...                If the popup is found within 3 seconds, it will click on the "Got It" button
    ...                to close the popup. If the popup is not present, 
    ...                the keyword will not perform any action.
    ${intelligence_view}    IsText    Check Out the Intelligence View    timeout=3s
    IF    ${intelligence_view}
        ClickText           Got It
    END