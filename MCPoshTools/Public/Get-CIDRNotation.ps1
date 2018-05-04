function Get-CIDRNotation {

<#
.SYNOPSIS
    Returns CIDR chart for subnetting reference
.DESCRIPTION
    Returns CIDR chart for subnetting reference

    It pulls the chart from a .json file located in the 'Inputs' directory of the module root
.EXAMPLE
    Get-CIDRNotation -Verbose
.INPUTS
    System.String
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20170411
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Added the -Raw parameter when reading in the .JSON file which will avoid processing error with earlier versions of PowerShell
    - Added syntax to better resolve and work with the UNC path to the input file
#>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param (
        [parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Default')]
        [ValidateScript({Test-Path -LiteralPath $_ -PathType Leaf})]
        [System.String]$Path = "$PSScriptRoot\..\Inputs\cidr-table.json"
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        # Use Get-Item to return a full/proper UNC path in the event ".." is used (makes it easier to read and work worth)
        $jsonPath = $null
        $jsonPath = (Get-Item -Path $Path).FullName

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Reading CIDR detail from local database file { $jsonPath }"
        try {

           Get-Content -Path $Path -ErrorAction 'Stop' -Raw | ConvertFrom-Json -ErrorAction 'Stop'

        } catch {

            throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Error importing file { $Path }. $_"

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-CIDRNotation
