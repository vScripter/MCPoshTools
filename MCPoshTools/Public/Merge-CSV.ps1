function Merge-CSV {

    <#
    .SYNOPSIS
        Merge all .CSV files in the same directory
    .DESCRIPTION
        This function will merge all .CSV files in a given directory, into a single .CSV file
    .PARAMETER Path
    .PARAMETER FileName
    .PARAMETER Properties
    .INPUTS
        System.String
    .OUTPUTS
        .CSV file
    .EXAMPLE
        Merge-CSV -Path C:\Test\CSVs -FileName Master.csv -Properties ComputerName,Name -Verbose
    .NOTES
        Author: Kevin M. Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Update: 20150327
        Last Update Notes:
        - [KMK] Created
    #>

    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(Position = 0,
                   Mandatory = $true)]
        [ValidateScript({ Test-Path -LiteralPath $_ })]
        [System.String]$Path,

        [parameter(Position = 1,
                   Mandatory = $false)]
        [System.String]$FileName = 'Master.csv',

        [parameter(Position = 2,
                   Mandatory = $false)]
        [System.String[]]$Properties
    )

    BEGIN {

        $gatheredFiles = Get-ChildItem -Path $Path -Filter *.csv | Select-Object -ExpandProperty FullName

        $exportPath = "$Path\$FileName"

    } # end BEGIN block

    PROCESS {

        try {

            foreach ($file in $gatheredFiles) {

                Get-Content -Path $file -ErrorAction 'Stop' |
                ConvertFrom-Csv -ErrorAction 'Stop' |
                Select-Object $Properties -ErrorAction 'Stop' |
                Export-Csv -Path $exportPath -NoTypeInformation -Append -ErrorAction 'Stop'

            } # end foreach $file

        } catch {

            Write-Warning -Message "[ERROR] $_"

        } # end try/catch


    } # end PROCESS block

    END {


    } # end END block

} # end function Merge-CSV
