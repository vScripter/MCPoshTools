function Get-TypeName {

<#
    .SYNOPSIS
        Return the PowerShell/.NET Type Name of the provided object/s
    .DESCRIPTION
        Return the PowerShell/.NET Type Name of the object/s that are either coming through the pipeline or passed to the function.
    .PARAMETER  Object
        PS Object that you would like to return the Type Name from
    .EXAMPLE
        PS C:\> Get-TypeName -Object $objectValue
        'This is the output'
        This example shows how to call the Get-TypeName function with named parameters.
    .EXAMPLE
        PS C:\> Get-TypeName $objectValue

        This example shows how to call the Get-TypeName function with positional parameters.
    .INPUTS
        PS Object
    .OUTPUTS
        System.String
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Version: 1.0
        Last Updated: 20150611
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Added to module
#>

    [CmdletBinding(DefaultParameterSetName = 'default')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        $Object
    )

    BEGIN {

        $ErrorActionPreference = 'Stop'

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[Get-TypeName] Processing Input"
        try {

            ($Object).GetType().FullName

        } catch {

            Write-Warning -Message "[Get-TypeName][ERROR]. $_ "
            break

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[Get-TypeName] Processing Complete"

    } # end END block

} # end function Get-TypeName
