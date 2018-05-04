function Disconnect-LoggedOnUser {

    <#
    .SYNOPSIS
        This function will log off the specified user/session, based on session ID
    .DESCRIPTION
        This function will log off the specified user/session, based on session ID.

        It was written to accept pipeline input from the Get-TSSession function, but it can also be run as a stand-alone function, if desired.

    .PARAMETER ComputerName
        Name of computer/s
    .PARAMETER ID
        Session ID number
    .EXAMPLE
        Get-TSSession-ComputerName 'SERVER1' | Where-Object {$_.UserName -like 'USER123' } | Disconnect-LoggedOnUser -Verbose
    .EXAMPLE
        Get-TSSession-ComputerName 'SERVER1',SERVER2' | where username -like 'USER123' | Disconnect-LoggedOnUser -Verbose

        This will only work on PS version 3, or newer, since it uses a 'quick' property filter
    .NOTES
        Author: Kevin Kirkpatrick (CSC)
        Email: See About_MCPoshTools for contact information
        Last Updated: 20150318
        Last Update Notes:
        - [KMK] Added to module
    #>

    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(
                   Mandatory = $true,
                   Position = 0,
                   ValueFromPipelineByPropertyName = $true)]
        [alias('Computer', 'CN')]
        $ComputerName,

        [parameter(
                   Mandatory = $true,
                   Position = 2,
                   ValueFromPipelineByPropertyName = $true)]
        $ID
    )

    BEGIN {

        # save current EA Pref
        $currentEaSetting = $ErrorActionPreference

        # set the EA pref to 'STOP' in order to catch any errors throw from running rwinsta
        $ErrorActionPreference = 'Stop'

    }

    PROCESS {

        try {

            Write-Verbose -Message "[$ComputerName] Logging off session '$ID'"

            rwinsta $ID /Server:$Computername

        } catch {

            Write-Warning -Message "[ERROR] $_"

        } # end try/catch

    } # end PROCESS block

    END {

        # reset EA Pref
        $ErrorActionPreference = $currentEaSetting

    } # end END block

} # end function Disconnect-LoggedOnUser
