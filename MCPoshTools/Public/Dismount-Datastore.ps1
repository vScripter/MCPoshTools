function Dismount-Datastore {

<#
.SYNOPSIS
    Unmount all datastores that match a wildcard name value from a given host
.DESCRIPTION
    Unmount all datastores that match a wildcard name value from a given host.

    This is just an UNMOUNT of the datastore. If the host is rebooted the datastores will re-mount.

    When dealing with LUN-backed datastores, this will not detach the LUN from the host.

    The command is issued via esxcli methods, therefore, you will not see any tasks appear in the vSphere Client. The process can also be
    sensitive to the speed and total number of datastores to be unmounted. A wait period has been added between executing unmount commands so that the host
    can process the request. If a large number of datastores are being specified, it is possible that a couple of operations might fail, in which
    case, re-run the script and it should unmount them.
.PARAMETER Server
    vCenter FQDN
.PARAMETER VMHost
    VMhost FQDN
.PARAMETER DatastorePrefixName
    Name of datastore to unmount. If there are multiple datastores with the same name, use a * to specify a wildcard search.
.INPUTS
    System.String
.EXAMPLE
    Dismount-Datastore -Server vcenter01.corp.com -VMHost esxi01.corp.com -DatastorePrefixName clus01_ds* -WhatIf
.EXAMPLE
    Dismount-Datastore -Server vcenter01.corp.com -VMHost esxi01.corp.com -DatastorePrefixName clus01_ds* -Verbose
.NOTES
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20140609
    Last Updates By: K. Kirkpatrick
    Last Update Notes:
    - Added in check to ensure VMHost is in Maint. Mode
    - Added in the number of datastores that will be unmounted which will get displayed when running with -WhatIf
#>

    [cmdletbinding(SupportsShouldProcess = $true,
                   ConfirmImpact = 'High',
                   DefaultParameterSetName = 'default')]
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [System.String]$Server,

        [parameter(Mandatory = $true, Position = 1)]
        [System.String[]]$VMHost,

        [parameter(Mandatory = $true, Position = 2)]
        [System.String]$DatastorePrefixName
    )

    BEGIN {

        $currentEaSetting = $ErrorActionPreference

        # set global EA pref so we can catch errors generated from exectuing ESXCLI commands
        $ErrorActionPreference = 'Stop'

        $vCenterServer = $Server

    } # end BEGIN block

    PROCESS {

        foreach ($vmhostSystem in $VMHost) {

            $esxcli = $null
            $esxHostName = $null
            $datastoreQuery = $null
            $vmHostQuery = $null
            $datastoreCount = $null

            Write-Verbose -Message "[Dismount-Datastore] Initiating esxcli endpoint connection for { $vmhostSystem } on { $vCenterServer }"
            try {

                $vmHostQuery = Get-VMHost -Server $vCenterServer -Name $vmhostSystem -ErrorAction 'Stop'

                if ($vmHostQuery.ConnectionState -eq 'Maintenance') {

                    Start-Sleep -Milliseconds 500
                    $esxcli = Get-VMHost -Server $vCenterServer -Name $vmhostSystem -ErrorAction 'Stop' | Get-EsxCli -ErrorAction 'Stop'

                } else {

                    Write-Warning -Message "[Dismount-Datastore] VMHost { $vmhostSystem } is not in Maintenance Mode. Please verify the host is in maintenance mode by logging into vCenter { $vCenterServer }"

                } # end if/else

            } catch {

                Write-Warning -Message "[Dismount-Datastore] Could not create EsxCli endpoint on { $vmhostSystem }"
                continue

            } # end try/catch


            try {

                $esxHostName = ($esxcli.system.hostname.Get()).FullyQualifiedDomainName

                Write-Verbose -Message "[Dismount-Datastore] Gathering datastores mounted to { $esxHostName }"
                $datastoreQuery = $esxcli.storage.filesystem.list() | Where-Object { $psitem.Volumename -like $DatastorePrefixName -and $psitem.Mounted -eq $true }
                $datastoreCount = $datastoreQuery.Count

                if ($PSCmdlet.ShouldProcess("$esxHostName", "Filesystem unmounts for { $datastoreCount } connected datastores")) {

                    foreach ($datastore in $datastoreQuery) {

                        $datastoreName = $null
                        $datastoreName = $datastore.VolumeName

                        Write-Verbose -Message "[Dismount-Datastore] Performing Filesystem unmount for the { $datastoreName } datastore on { $esxHostName }"
                        $esxcli.storage.filesystem.unmount($false, $datastoreName, $null, $null)

                        Start-Sleep -Milliseconds 1500

                    } # end foreach

                } # end if $PSCmdlet

                if ($PSCmdlet.ShouldProcess("$esxHostName", "Filesystem rescan")) {

                    Write-Verbose -Message "[Dismount-Datastore] Performing Filesystem rescan on { $esxHostName }"
                    $esxcli.storage.filesystem.rescan()

                } # end if

            } catch {

                Write-Warning -Message "[Dismount-Datastore] Could not execute unmount/rescan for datastore { $datastoreName } on VMHost { $vmhostSystem }. $_"
                continue

            } # end try/catch


        } # end foreach $vmhostSystem

    } # end PROCESS block

    END {

        $ErrorActionPreference = $currentEaSetting

        Write-Verbose -Message "[Dismount-Datastore] Processing complete."

    } # end END block

} # end function Dismount-Datastore
