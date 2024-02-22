*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables

*** Variables ***
${orders}=   Get Orders

*** Keywords ***
Open the robot order website
    Open Browser    https://robotsparebinindustries.com/#/robot-order    Chrome  

Download Orders File
   Download    https://robotsparebinindustries.com/orders.csv    orders.csv     overwrite=True

Get Orders
    ${table}=  Read Table From CSV  orders.csv
    FOR  ${row}  IN  @{table}
        ${head}=  Set Variable  ${row}[Head]
        Set Suite Variable    ${head}
        ${body}=  Set Variable  ${row}[Body]
        Set Suite Variable    ${body}
        ${legs}=  Set Variable  ${row}[Legs]
        Set Suite Variable    ${legs}
        ${address}=  Set Variable  ${row}[Address]
    END
    Set Suite Variable    ${row}
    Set Suite Variable    ${table}
Close the annoying modal
    Wait Until Page Contains Element   css:.btn.btn-danger
    Click Element   css:.btn.btn-danger

Fill the Form
    Select From List By Value   css:#head  ${head}  
    Click Element   css:#id-body-${body}
*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download Orders File
    Get Orders
    Open the robot order website
    Close the annoying modal
    Fill the Form
    Log    Done.

