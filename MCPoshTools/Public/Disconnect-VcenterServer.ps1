function Disconnect-VcenterServer {

    <#
    .SYNOPSIS
        Disconnects all connected vCenter Server connections
    .DESCRIPTION
        Disconnects all connected vCenter Server connections.

        The list of connected vCenter Servers (VI Servers) is stored in the $Global:DefaultVIServers variable.

        This will disconnect ALL connected sessions.
    .PARAMETER Server
        vCenter Server/s Fully Qualified Domain Name
    .EXAMPLE
        Disconnect-VcenterServer -Verbose
    .INPUTS
        System.String
    .OUTPUTS
        N/A
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20161204
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Changed paramter name 'VcenterServerName' to 'Server'
        - Added logic to attempt to use the default value assigned to $Global:DefaultVIServers, if no value is passed to -Server
    #>

    [OutputType()]
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Default')]
        [System.String[]]$Server
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        # if not value was given to the -Server param, check to see if there are any connected vCenter servers, and attempt to run it against, all of those
        if(-not($PSCmdlet.MyInvocation.BoundParameters.Keys.Contains('Server'))) {

            # using Test-Path to check for variable; if we don't, we will get an error complaining about looking for a variable that hasn't been set
            if(Test-Path -Path Variable:\Global:defaultViServers){

                $Server = ((Get-Variable -Scope Global -Name DefaultViServers).Value | Where-Object {$_.IsConnected -eq $true}).Name

                if($Server -eq $null -or $Server -eq ''){

                    throw "[Disconnect-VcenterServer][ERROR] No Value was provided to the '-Server' Parameter and no current connection could be found"

                } else {

                   Write-Verbose -Message '[Disconnect-VcenterServer] Processing connected vCenter servers discovered in variable { $Global:DefaultViServers }'

                } # end else/if

            } else {

                throw '[Disconnect-VcenterServer][ERROR] No Value was provided to the -Server Parameter and no current connection could be found; variable { $Global:DefaultViServers } does not exist'

            } # end if/else Test-Path

        } # end if

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[Disconnect-VcenterServer] Preparing to disconnect ALL vCenter Servers"

        foreach ($vcenterServer in $Server) {

            if ($PSCmdlet.ShouldProcess("$vcenterServer", 'Disconnecting vCenter Server Connection')) {

                try {

                    [void](Disconnect-VIServer -Server $vcenterServer -Confirm:$false -ErrorAction 'Stop')

                    Write-Verbose -Message "[Disconnect-VcenterServer] Disconnecting from vCenter { $vcenterServer }"

                } catch {

                    Throw "[Disconnect-VcenterServer][ERROR] Could not disconnect from vCenter { $vcenterServer }. $_ "

                } # end try/catch

            } # end if

        } # end foreach $vcenterServer

    } # end PROCESS block

    END {

        Write-Verbose -Message "[Disconnect-VcenterServer] Processing Complete"

    } # end END block

} # end function Disconnect-VcenterServer
