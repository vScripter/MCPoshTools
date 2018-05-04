function Test-VcenterConnection {

    <#
    .SYNOPSIS
        Tests the connection to a provided vCenter server, or multiple vCenter Servers
    .DESCRIPTION
        Tests the connection to a provided vCenter server, or multiple vCenter Servers.

        This can be used in scripts that are automated, or you wish to automate the connection to a vCenter server, in the event no connection has been made.

        It will return a boolean value, which can be assigned to a variable in a script/function, for an easier way to process and validate vCenter connections
    .NOTES
        Author: Kevin Kirkpatrick (CSC)
        Email: See About_MCPoshTools for contact information
        Last Updated: 20150526
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Renamed to Test-VcenterConnection from Test-VIConnection
    #>

    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [System.String]$vCenter
    )

    BEGIN {

        [bool]$statusCode = 0

        Write-Warning -Message "[Test-VcenterServer] This function has been discontinued. Contact author for more details."
        break

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message '[Test-VIConnection][Get/Add-PSSnapin] Checking for VMware.VimAutomation.Core PSSnapin'
        if ((Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction 'SilentlyContinue').Name -eq $null) {

            try {

                Add-PSSnapin VMware.VimAutomation.Core -ErrorAction 'Stop'
                $statusCode = 1

            } catch {

                Write-Warning -Message "[Test-VIConnection][Get/Add-PSSnapin] Error adding VMware PSSnapin: $_"
                Write-Warning -Message '[Test-VIConnection][Get/Add-PSSnapin] Exiting script'
                $statusCode = 0
                Write-Debug -Message "[Test-VIConnection][Get/Add-PSSnapin]
Pertinent Variables
------------------------------
[`$statusCode]{$statusCode} "

                break


            } # try/catch

        } else {

            Write-Verbose -Message "[Test-VIConnection][Get/Add-PSSnapin]'VMware.VimAutomation.Core' PSSnapin is already added; continuing..."

        } # end if/else


        # if -Server was specified, try connecting, else make sure there is a valid connection
        if ($Server) {

            Write-Verbose -Message '[Test-VIConnection][if($Server)] Connecting to vCenter Server'

            try {

                Connect-VIServer -Server $vCenter -ErrorAction 'Stop' | Out-Null
                $statusCode = 1

            } catch {

                Write-Warning -Message '[Test-VIConnection][if($vCenter)::Connect-VIServer] Error connecting to vCenter'
                Write-Warning -Message '[Test-VIConnection][if($vCenter)::Connect-VIServer] Exiting script'
                $statusCode = 0
                Write-Debug -Message "[Test-VIConnection][Get/Add-PSSnapin]
Pertinent Variables
------------------------------
[`$statusCode]{$statusCode} "

                break


            } # end try/catch

        } elseif (($global:defaultviserver).Name -eq $null) {

            Write-Warning -Message '[Test-VIConnection][elseif($global:defaultviserver)] No default vCenter connection. Connect to vCenter or specify a vCenter Server name and try again.'
            Write-Warning -Message '[Test-VIConnection][elseif($global:defaultviserver)] Exiting script'
            $statusCode = 0

            Write-Debug -Message "[Test-VIConnection][elseif(`$global:defaultviserver)]
Pertinent Variables
------------------------------
[`$statusCode]{$statusCode} "

            break

        } # end if/elseif

        $viServer = $global:defaultviserver.Name
        $viServerVersion = $global:defaultviserver.Version

        # write selected VI server to the console
        Write-Verbose -Message "[Test-VIConnection] VI Server Name/Version: {$viServer} {v$viServerVersion}"

    } # end PROCESS block

    END {

        Write-Debug -Message "[Test-VIConnection] Finished execution"


        if ($statusCode -eq 1) {

            #return $true
            Write-Output $true

        } elseif ($statusCode -eq 0) {

            #return $false
            Write-Output $false

        }

        Write-Debug -Message "[Test-VIConnection]
Pertinent Variables
------------------------------
[`$statusCode]{$statusCode}"

    } # end END block


} # end function Test-VcenterConnection
