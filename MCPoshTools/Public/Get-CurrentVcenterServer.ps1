function Get-CurrentVcenterServer {

    <#
    .SYNOPSIS
        Returns the default selected VI (vCenter) server
    .DESCRIPTION
        Returns the default selected VI (vCenter) server
    .OUTPUTS
        System.String
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20150526
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Renamed from Get-CurrentVIServer

    #>

    [OutputType([System.String])]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param()

    PROCESS {

        try {

            (Get-Variable -Scope Global -Name DefaultVIServer -ErrorAction 'Stop').Value.Name

        } catch {

            throw "[Get-CurrentVcenterServer][ERROR] $_"

        } # end t/c

    } # end PROCESS block

} # end function Get-CurrentVServer
