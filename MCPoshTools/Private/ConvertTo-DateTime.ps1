function ConvertTo-DateTime {

<#
    .SYNOPSIS
        Convert a custom string of text into a proper [DateTime] object
    .DESCRIPTION
        Convert a custom string of text into a proper [DateTime] object.

        This is to primaryily support parsing strings that may not follow a pre-existing standard that PowerShell can understand.

        For example, if you were to run:
        Get-Date '6/23/15'

        PowerShell would automatically convert the string to a proper [DateTime] object.

        That said, you may have an internal standard which you prefer, but need an easy means to parse and convert that custom string into a [DateTime] object, which is where
        this cmdlet/function comes into play.

        You can add regex conditions, as you please/need, to exapand the initial basic functionality (this functionality should be added as an option to the -InputFormat parameter
        and have related code added to the switch block)

    .PARAMETER  String
        The string you wish to parse
    .PARAMETER  InputFormat
        The format of the string value you wish to covert to a proper [DateTime] object.
    .EXAMPLE
        ConvertTo-DateTime -String '20151007' -InputFormat 'yyyyMMdd'
    .INPUTS
        System.String
    .OUTPUTS
        System.DateTime
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Version: 1.1
        Last Updated: 20151007
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Changed -Format parameter name to -InputFormat, which is more descriptive
        - Added example in CBH
#>

    [OutputType([System.DateTime])]
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$String,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateSet('yyyyMMdd')]
        [System.String]$InputFormat = 'yyyyMMdd'
    )

    BEGIN {


    } # end BEGIN block

    PROCESS {


        try {

            switch ($InputFormat) {

                'yyyyMMdd' {

                    Write-Verbose -Message "[ConvertTo-DateTime] Parsing and converting string {$String} using custom format {$InputFormat}"

                    $parseDateMonth = $null
                    $parseDateYear = $null
                    $parseDateDay = $null
                    $parseDateTime = $null

                    $parseDateMonth = ($String).Substring(4, 2)
                    $parseDateYear = ($String).Substring(0, 4)
                    $parseDateDay = ($String).Substring(6, 2)
                    $parseDateTime = "$parseDateMonth/$parseDateDay/$parseDateYear"

                    [DateTime]$finalParseDate = Get-Date $parseDateTime -ErrorAction 'Stop'

                    $finalParseDate

                } # end 'yyyyMMdd'

            } # end switch

        } catch {

            Write-Warning -Message "[ConvertTo-DateTime][ERROR] Could not parse into proper DateTime object. $_ "
            # code

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[ConvertTo-DateTime] Processing Complete"

    } # end END block

} # end function ConvertTo-DateTime
