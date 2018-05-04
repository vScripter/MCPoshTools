function Expand-Zip {

    <#
    .SYNOPSIS
        Expand a .ZIP file to a specified directory
    .DESCRIPTION
        Expand a .ZIP file to a specified directory.

        By default, if no path is provided to the -DestinationPath parameter, it will extract the .ZIP in the current execution directory
    .INPUTS
        System.String
    .OUTPUTS
        Extracted .ZIP archive contents
    .EXAMPLE
        Expand-Zip -Path $env:userprofile\Downloads\File.Zip -DestinationPath $env:userprofile\Documents -Verbose
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20150501
        Last Update Notes:
        - [KMK] Created
    #>

    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [validatescript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [validatenotnullorempty()]
        [System.String]$Path,

        [parameter(Mandatory = $false, Position = 1)]
        [validatescript({
            if (Test-Path -LiteralPath $_ -PathType Container) {

                $true

            } else {

                throw "{ $_ } is not a valid destination path."

            }
        })]
        [validatenotnullorempty()]
        [System.String]$DestinationPath = (Split-Path $Path)
    )

    BEGIN {

        #Requires -Version 3
        $ErrorActionPreference = 'Stop'

        [Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.Filesystem") | Out-Null

    } # end BEGIN block

    PROCESS {

        try {

            Write-Verbose -Message "[Expand-Zip] Un-Zipping file { $Path }"

            [System.IO.Compression.ZipFile]::ExtractToDirectory("$$$Path", "$$DestinationPath")

        } catch {

            Write-Warning -Message "[Expand-Zip] Error un-zipping directory { $Path } to { $DestinationPath }"

        } # end try/catch

    } # end PROCESS block

    END {

    } # end END block

} # end function Expand-Zip
