---
title: "Create a prompt for Endpoint Manager (SCCM) OSD"
date: 2020-11-13T18:16:26-08:00
draft: false
tags: ["Server","Endpoint Manager","Powershell"]
description: "Creating a simple prompt during Microsoft's Endpoint Manager for certain criteria"
font-size: 10pt
---

# Let's customize the Task Sequence directly in OSD!

I got fed up with getting asked to create separate task sequences for OSD for such simple difference, some as simple
as instead of installing Office 2016 install Office Pro Plus (in the middle of migrating to Office 365).

### Prerequisites
There are a few things that you will need to have installed onto your Boot Image in order for this to work properly. These prerequisites can be found under **Software Library -> Operating Systems -> Boot Images**. If you use both x86 and x64 boot images you will need to add these to both.

Within the boot image properties navigate to Optional Components and click the yellow star. Add the following components:
* Windows Powershell (WinPE-Powershell)
* Microsoft .NET (WinPE-Dot3Svc)
* Microsoft .NET (WinPE-NetFs)
* HTML (WinPE-HTA)

This will add ~120MB to your boot images; however in todays world that isn't much of anything. You might even see that some of these are already apart of your boot image!


### Powershell Script
```powershell
#-------------------------------------------------------------#
#----Initial Declarations-------------------------------------#
#-------------------------------------------------------------#

Add-Type -AssemblyName PresentationCore, PresentationFramework

$Xaml = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Windows 10 Image Options" Height="200" Width="300" WindowStyle="ToolWindow">
    <Grid>
        <Label Content="Computer Name:" HorizontalAlignment="Left" Margin="20,20,0,0" VerticalAlignment="Top"/>
        <TextBox Name="CompName" HorizontalAlignment="Left" Height="23" Margin="126,24,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="125" AutomationProperties.IsRequiredForForm="True"/>
        <Label Content="Office Version:" HorizontalAlignment="Left" Margin="20,80,0,0" VerticalAlignment="Top"/>
        <Button Name="DoneButton" Content="Done" HorizontalAlignment="Left" Margin="208,141,0,0" VerticalAlignment="Top" Width="75"/>
        <ComboBox HorizontalAlignment="Left" Margin="126,84,0,0" VerticalAlignment="Top" Width="120" SelectedIndex="0">
            <ComboBoxItem Name="OfficeProPlus" Content="Office Pro Plus"/>
            <ComboBoxItem Name="Office2016" Content="Office 2016"/>
        </ComboBox>
    </Grid>
</Window>
"@
#-------------------------------------------------------------#
#----Control Event Handlers-----------------------------------#
#-------------------------------------------------------------#
function Set-TSVariable {
    param (
        [Parameter(Mandatory=$true)]
        $ComputerName,
        [Parameter(Mandatory=$true)]
        $OfficeVersion
    )

    $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment

    $tsenv.Value('OSDComputerName') = $ComputerName
    $tsenv.Value('OSDOfficeVersion') = $OfficeVersion
    $Window.Close() | Out-Null
}
#-------------------------------------------------------------#
#----Script Execution-----------------------------------------#
#-------------------------------------------------------------#
$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }
#-------------------------------------------------------------#
#----Validation-----------------------------------------------#
#-------------------------------------------------------------#
$CompName.Text = $env:COMPUTERNAME
# Computer Name Login
$CompName.Add_TextChanged({
    if ($CompName.Text -like "* *") {
        [System.Windows.MessageBox]::Show('Computer Name cannot contain spaces')
    }
    elseif ($CompName.Text.Length -gt 15) {
        [System.Windows.MessageBox]::Show('Computer Name must be less than 15 characters')
    }
    elseif ($CompName.Text -match '[!@#$%^&*()]') {
        [System.Windows.MessageBox]::Show('No Special Characters')
    }
    else {
        Set-Variable -Scope Global -Name ComputerName -Value $CompName.Text
        #$ComputerName = $CompName.Text
    }
})
#-------------------------------------------------------------#
#----Done Button Logic----------------------------------------#
#-------------------------------------------------------------#
$DoneButton.Add_Click({
# Office Version Logic
if ($OfficeProPlus.IsSelected -eq $true) {
    Set-Variable -Name OfficeVersion -Value "ProPlus" -Scope Global
}
elseif ($Office2016.IsSelected -eq $true) {
    Set-Variable -Name OfficeVersion -Value "2016" -Scope Global
}

Set-TSVariable -ComputerName $ComputerName -OfficeVersion $OfficeVersion
})
#Show Window

$Window.ShowDialog()
```
### Script Explanation
You may be saying to yourself... that's a lot going on! I will try to break what you are seeing in the script down for you...

The XAML variable is the WPF (Windows Presentation Framework) GUI. This is what you will actually see pop up during the OSD process and will take whatever you put in and output it as a Task Sequence variable. 

The next part; Control Event Handlers this is the function that will actually set the relevant Task Sequence variables. If you choose to create additional variables I would recommend staying with the OSD******** variable name. Just be sure you don't overwrite any other variables that may be in use if you don't mean to. OSDComputerName is a built in variable, and setting it will cause OSD to name the computer whatever the variable is set to. OSDOfficeVersion is the variable I use to determine which office version to install. 

The script execution parses the XAML variable and create a Variable for any of the XAML lines with a "Name" option; this allows us to refer to the items in the GUI via Powershell Variables.

The Validation step is to validate any information that you would like. In this script it is validating that the computer name does not contain any spaces, special characters, and is not more than 15 characters. This validates on every character typed and will throw an error window when it detects an issue.  

The Done button logic is what is run when the Done button is clicked on the prompt. You can see that I set the $OfficeVersion variable based on the prompt. The computer name is set to whatever is in the textbox so that won't need validation.

### Endpoint Manager Task Sequence Setup
Since the prompt updates task sequence variables you will then need to use these variables in the task options to facilitate what variable does what. The more granular of a prompt you create will obviously create a lot of steps in the task sequence. If you have a prompt for many different applications then it may be exploring the application Dynamic Variable List; which is something that I myself need to look into.

The way I have the task sequence setup I have two seperate steps depending on which Office Version was selected in the prompt and the logic is built under the options tab of each step:

* 2016 Desktop Applications
  * If **All** the conditions are true: Task Sequence Variable **OSDOfficeVersion equals "2016"**
* Pro Plus Desktop Applications
  * If **All** the conditions are true: Task Sequence Variable **OSDOfficeVersion equals "ProPlus"**