function Get-PowerShellVersion {

    <#
    .SYNOPSIS
        Lists PowerShell version information
    .DESCRIPTION
        Lists PowerShell version information
    .NOTES
        Author: Kevin Kirkpatrick (CSC)
        Email: See About_MCPoshTools for contact information
        Last Updated: 20150325
        Last Update Notes:
        - [KMK] Added to module
    #>

    [cmdletbinding()]
    param ()

    PROCESS {

        $PSVersionTable

    } # end PROCESS block

} # end function Get-PowerShellVersion
