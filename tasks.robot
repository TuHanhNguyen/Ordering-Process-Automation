*** Settings ***
Documentation       Exersive for Lv2 RPA with Robot Framework
...                 Github.com/TuHanhNguyen

Library             RPA.Browser.Playwright
Library             RPA.Excel.Files
Library             RPA.HTTP
Library             OperatingSystem
Library             RPA.Browser.Selenium
Library             RPA.Tables
Library             RPA.PDF

Suite Setup         New Browser    chromium    headless=true
# Suite Teardown    Clean Dev Session


*** Variables ***
${output_folder}                ${CURDIR}{/}output
${screenshot_folder}            ${CURDIR}/screenshot
${receipt_folder}               ${OUTPUT_DIR}${/}receipts/

${GLOBAL_RETRY_AMOUNT}          10x
${GLOBAL_RETRY_INTERVAL}        2s
${default_selenium_timeout}     ${EMPTY}


*** Tasks ***
Order robots from csv file
    Open ordering website
    ${order_list}=    Get order file and read as table
    FOR    ${row}    IN    @{order_list}
        Close annoying popup
        Fill the form    ${row}
        Wait Until Keyword Succeeds    ${GLOBAL_RETRY_AMOUNT}    ${GLOBAL_RETRY_INTERVAL}    Click button "Preview"
        Wait Until Keyword Succeeds    ${GLOBAL_RETRY_AMOUNT}    ${GLOBAL_RETRY_INTERVAL}    Click button "ORDER"
        Store the order receipt as a PDF file
        # Take a screenshot of the robot image
        # Embed the robot screenshot to the receipt PDF file
        Click button "ORDER ANOTHER ROBOT"
    END

    # Collect the results


*** Keywords ***
Store the order receipt as a PDF file
    Wait Until Element Is Visible    XPATH://html/body/div[1]/div/div[1]/div/div[1]/div/div
    ${receipt_outer_html}=    Get Element Attribute
    ...    XPATH://html/body/div[1]/div/div[1]/div/div[1]/div/div
    ...    outerHTML
    ${receipt_id}=    RPA.Browser.Selenium.Get Text    XPATH://html/body/div[1]/div/div[1]/div/div[1]/div/div/p[1]
    Html To Pdf    ${receipt_outer_html}    ${receipt_folder}{/}${receipt_id}.pdf

# Download robot preview image
#    Set Local Variable    ${robot_preview_image}    XPATH://html/body/div/div/div[1]/div/div[2]/div/div
#    ${robot_preview_image_prefix}=    RPA.Browser.Selenium.Get Value
#    ...    XPATH://html/body/div/div/div[1]/div/div[1]/div/div/div[1]
#    Screenshot    ${robot_preview_image}    filename=${robot_preview_image_prefix}

Click button "Preview"
    Set Local Variable    ${button_preview}    XPATH://html/body/div/div/div[1]/div/div[1]/form/button[1]
    Click Element    ${button_preview}

Click button "ORDER"
    Set Local Variable    ${order_button_locator}    XPATH://html/body/div/div/div[1]/div/div[1]/form/button[2]
    Click Element    ${order_button_locator}
    Page Should Contain Element    XPATH://html/body/div/div/div[1]/div/div[1]/div/button

Click button "ORDER ANOTHER ROBOT"
    Set Local Variable
    ...    ${order_another_robot_button_locator}
    ...    XPATH://html/body/div/div/div[1]/div/div[1]/div/button
    Wait Until Keyword Succeeds
    ...    ${GLOBAL_RETRY_AMOUNT}
    ...    ${GLOBAL_RETRY_INTERVAL}
    ...    Click Element    ${order_another_robot_button_locator}

Open ordering website
    RPA.Browser.Selenium.Open Browser    https://robotsparebinindustries.com/#/robot-order

Close annoying popup
    Set Local Variable    ${annoying_popup_locator}    XPATH://html/body/div/div/div[2]/div/div/div/div/div/button[1]
    Click Element    ${annoying_popup_locator}

Get order file and read as table
    RPA.HTTP.Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${order_list}=    Set Variable    orders.csv
    ${order_list}=    Read table from CSV    ${order_list}
    RETURN    ${order_list}

Fill the form
    [Arguments]    ${order}
    # We need to exact the value from the returned {table}
    # Which is dictinary
    Set Local Variable    ${order_no}    ${order}[Order number]
    Set Local Variable    ${head}    ${order}[Head]
    Set Local Variable    ${body}    ${order}[Body]
    Set Local Variable    ${legs}    ${order}[Legs]
    Set Local Variable    ${shipping_address}    ${order}[Address]

    Select From List By Value    //*[@id="head"]    ${head}
    Select Radio Button    body    ${body}
    Input Text    XPATH://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${legs}
    Input Text    XPATH://html/body/div/div/div[1]/div/div[1]/form/div[4]/input    ${shipping_address}

# Clean Dev Session
#    RPA.Browser.Playwright.Close Browser
#    Remove Directory    ${screenshot_folder}    recursive=True
#    Remove Directory    ${receipt_folder}    recursive=True
