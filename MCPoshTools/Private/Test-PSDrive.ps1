
function Test-PSDrive {

<#
.SYNOPSIS
    Returns a true of false value when checking for the existence of certain PSDrive Name
.DESCRIPTION
    Returns a true of false value when checking for the existence of certain PSDrive Name

    As of 12/5/2016, this is only used in the Invoke-RecursiveDatastoreSearch function, as part of the MCPoshTools module
.NOTES
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20161205
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Moved to Private functions folder
    - Added CBH
#>
    [OutPutType([System.Boolean])]
    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'default')]
        [System.String]$Name
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[Test-PSDrive] Checking for PSDrive {$Name}"
        Write-Debug -Message "[Test-PSDrive] Checking for PSDrive {$Name}
Pertinent Variables
------------------------------
[`$Name]{$Name} "

        $psDrive = Get-PSDrive -Name $Name -ErrorAction 'SilentlyContinue'

        if ($psDrive) {

            $finalResult = $true
            [System.Boolean]$true

        } else {

            $finalResult = $false
            [System.Boolean]$false

        } # end if/else

    } # end PROCESS block

    END {

        Write-Verbose -Message "[Test-PSDrive] Processing Complete"
        Write-Debug -Message "[Test-PSDrive] Checking for PSDrive {$Name}
Pertinent Variables
------------------------------
[`$Name]{$Name}
[`$finalResult]{$finalResult}"

    } # end END block

} # end function Test-PSDrive
