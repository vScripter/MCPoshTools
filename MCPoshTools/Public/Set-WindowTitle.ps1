function Set-WindowTitle {

    <#
    .SYNOPSIS
        Sets the console window title to a custom text value
    .DESCRIPTION
        Sets the console window title to a custom text value.
    .INPUTS
        System.String
    .EXAMPLE
        Set-WindowTitle -Message "$env:computername - $env:username"
    .NOTES
        Author: Kevin Kirkpatrick (CSC)
        Email: See About_MCPoshTools for contact information
        Last Updated: 20150325
        Last Update Notes:
        - [KMK] Added to module
    #>

    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param (
        [parameter(ParameterSetName = 'Message',
                   Mandatory = $True,
                   Position = 0)]
        [System.String]$Message,

        [parameter(ParameterSetName = 'Reset')]
        [switch]$Default
    )


    if (($Host.Name -eq 'ConsoleHost') -or ($Host.Name -eq 'Windows PowerShell ISE Host')) {

        if ($Default) {

            Write-Verbose -Message "Setting console window to default settings"

            try {

                [bool]$runAsAdminCheck = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
                [int]$psVersionCheck = $psversiontable.PSVersion.Major

                $Message = "User: $($ENV:USERDOMAIN + '\' + $ENV:USERNAME)    Computer: $ENV:COMPUTERNAME    Admin: $runAsAdminCheck    PSVersion: $psVersionCheck"

                $host.UI.RawUI.WindowTitle = $Message

            } catch {

                Write-Warning -Message 'Error settings window title to default setting'

            } # end try/catch

        } elseif ($Message) {

            try {

                Write-Verbose -Message "Setting Console Window Title to: '$Message'"

                $host.UI.RawUI.WindowTitle = $Message

            } catch {

                Write-Warning -Message "$_"

            } # end try/catch

        } else { }

    } else {

        Write-Warning -Message '[Set-WindowTitle] This function only works when using the native PS Console'

    } # end if $host.name


} # end function Set-WindowTitle
