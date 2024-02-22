*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Desktop
Library    RPA.Archive


Resource          ./Resource/Pages/pg_orders.resource

Suite Setup       Open Available Browser    headlesschrome

*** Variables ***
${receipt_dir}=      ${CURDIR}${/}receipts
${screenshot_dir}=   ${CURDIR}${/}screenshots
${out_dir}=          ${CURDIR}${/}output

*** Keywords ***
Open the robot order website
    Go To    https://robotsparebinindustries.com/#/robot-order    
    Maximize Browser Window


Close the annoying modal
    Wait Until Page Contains Element   css:.btn.btn-danger
    Click Element   css:.btn.btn-danger

Download Orders File
   Download    https://robotsparebinindustries.com/orders.csv    orders.csv     overwrite=True

Get Orders
    ${table}=  Read Table From CSV  orders.csv
    [Return]  ${table}


Fill the Form
    [Arguments]  ${row}
    ${head}=  Set Variable  ${row}[Head]
    Select From List By Value   ${order_head}    ${head}
    ${body}=  Set Variable  ${row}[Body]
    Click Element   ${order_body}${Body}
    ${legs}=  Set Variable  ${row}[Legs]
    Input Text    ${order_legs}  ${legs}
    ${address}=  Set Variable  ${row}[Address]
    Input Text    ${order_address}    ${address}
    Wait Until Element Is Visible    ${order_preview}
    Click Element   ${order_preview}
    Wait Until Element Is Visible    ${order_preview_image}    timeout=10s
    ${screenshot}=  Take Screenshot of robot image    ${row}[Order number]
    Wait Until Keyword Succeeds    10x    0.5 sec    Submit Order
    Set Suite Variable    ${screenshot}
Order a New Robot
    Click Element   ${order_another}

Submit Order
    Click Element   ${order_submit}
    Wait Until Element Is Visible    ${order_another}

Take Screenshot of robot image
    [Arguments]  ${order_number}
    Set Local Variable    ${file_path}    ${screenshot_dir}/robot_preview_image_${order_number}.png
    Capture Element Screenshot     ${order_preview_image}     filename=${file_path}       
    [Return]  ${file_path}

Store order receipt as PDF
    [Arguments]  ${order_number}
    ${html_receipt} =   Get Element Attribute     ${order_receipt}    outerHTML
    Set Local Variable    ${file_path}         ${receipt_dir}${/}receipt_${order_number}.pdf
    Html To Pdf    ${html_receipt}    ${file_path}
    [Return]  ${file_path}

Embed the robot screenshot to the receipt PDF file
    [Arguments]  ${screenshot}  ${pdf}
    Open Pdf    ${pdf}
    ${image_files}=  Create List  ${screenshot}:align=center
    Add Files To Pdf    ${image_files}    ${pdf}    append=true

Create receipt PDF complete
    [Arguments]  ${order_number}    ${screenshot}
    ${pdf}=    Store order receipt as pdf    ${order_number}
    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}

Create ZIP file of all receipts
    ${zip_file} =    Set Variable    ${out_dir}${/}all_receipts.zip
    Archive Folder With Zip    ${receipt_dir}    ${zip_file}

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download Orders File
    Open the robot order website
   ${table}=  Get Orders
    FOR  ${row}  IN  @{table}
        Close the annoying modal
        Fill The Form  ${row}
        Create receipt PDF Complete      ${row}[Order number]    ${screenshot}
        Order a New Robot
    END
    Create ZIP File of all receipts

