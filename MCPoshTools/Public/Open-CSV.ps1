function Open-CSV {

<#
.SYNOPSIS
    Reads in a .CSV file and uses PowerShell to display the contents in an interactive GridView
.DESCRIPTION
    Reads in a .CSV file and uses PowerShell to display the contents in an interactive GridView.

    This cmdlet will not run in Windows Server Core or Nano.
.EXAMPLE
    Open-CSV -Path $Home\Desktop\Report.csv

    Opens a report called 'Report.csv'.
.INPUTS
    System.String
.NOTES
    --------------------------------
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20171027
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Updated CBH
#>

    [OutputType()]
    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [validatescript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [System.String]$Path = (Select-FileName)
    )

    BEGIN {

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[Open-CSV] Opening file {$Path}"

        try {

            Get-Content -LiteralPath $Path -ErrorAction 'stop' | ConvertFrom-CSV -ErrorAction 'stop' | Out-GridView -ErrorAction 'stop' -Title "Opened CSV from {$Path}"

        } catch {

            Write-Warning -Message "[Open-CSV][ERROR] Could not open file {$Path}. $_"

        } # end try/catch

    } #end PROCESS block

    END {

        Write-Verbose -Message "[Open-CSV] Processing Complete"

    } # end END block

} # end function Open-CSV
