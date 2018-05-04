function Get-DatastoreInventory {

<#
    .SYNOPSIS
        Collect datastore inventory information for each cluster managed by the provided vCenter Server
    .DESCRIPTION
        Collect datastore inventory information for each cluster managed by the provided vCenter Server
    .PARAMETER  Server
        FWDN of vCenter Server
    .EXAMPLE
        PS C:\> Get-DatastoreInventory -Server vcenter01.corp.com | Out-GridView

        This example shows how to call the Get-DatastoreInventory function with named parameters.
    .EXAMPLE
        PS C:\> Get-DatastoreInventory vcenter01.corp.com -Verbose | Export-Csv C:\ClusterDatastoreReport.csv -NoTypeInformation

        This example shows how to call the Get-DatastoreInventory function with positional parameters.
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20161218
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Expanded all instances of alias 'measure' with 'Measure-Object'
#>
    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Position = 0, Mandatory = $false, ParameterSetName = 'Default')]
        [System.String[]]$Server
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        Write-Verbose -Message "[Get-DatastoreInventory] Processing Started"

        # if not value was given to the -Server param, check to see if there are any connected vCenter servers, and attempt to run it against, all of those
        if(-not($PSCmdlet.MyInvocation.BoundParameters.Keys.Contains('Server'))) {

            # using Test-Path to check for variable; if we don't, we will get an error complaining about looking for a variable that hasn't been set
            if(Test-Path -Path Variable:\Global:defaultViServers){

                $Server = ((Get-Variable -Scope Global -Name DefaultViServers).Value | Where-Object {$_.IsConnected -eq $true}).Name

                if($Server -eq $null -or $Server -eq ''){

                    throw "[Get-DatastoreInventory][ERROR] No Value was provided to the '-Server' Parameter and no current connection could be found"

                } else {

                   Write-Verbose -Message '[Get-DatastoreInventory] Processing connected vCenter servers discovered in variable { $Global:DefaultViServers }'

                } # end else/if

            } else {

                throw '[Get-DatastoreInventory][ERROR] No Value was provided to the -Server Parameter and no current connection could be found; variable { $Global:DefaultViServers } does not exist'

            } # end if/else Test-Path

        } # end if

    } # end BEGIN block

    PROCESS {

        foreach ($vcenterServer in $Server){

            try {

                $clusterCount = 0

                $dsView       = $null
                $clusView     = $null
                $dsView       = Get-View -Server $vcenterServer -ViewType Datastore -Property Name, Info, Summary -ErrorAction 'Stop'
                $clusView     = Get-View -Server $vcenterServer -ViewType ClusterComputeResource -Property Name, Datastore -ErrorAction 'Stop'

                $clusterCount    = ($clusView | Measure-Object).Count
                $clusterProgress = 0

                foreach ($cluster in $clusView) {

                    $clusterProgress++
                    Write-Progress -Id 1 -ParentId 0 -Activity "Generating Datastore Inventory" -Status "Processing Cluster" -CurrentOperation "$($cluster.Name)" -PercentComplete (($clusterProgress/$clusterCount) * 100)

                    $clusDatastores    = $null
                    $clusterName       = $null
                    $datastoreCount    = $null

                    $clusterName       = $cluster.Name
                    $clusDatastores    = $cluster.Datastore.Value

                    $datastoreCount    = ($clusDatastores | Measure-Object).Count
                    $datastoreProgress = 0

                    Write-Verbose -Message "[Get-DatastoreInventory] Processing datastores on Cluster { $clusterName }"

                    foreach ($datastore in $clusDatastores) {

                        $datastoreProgress++

                        $datastoreProperties = $null
                        $cap                 = $null
                        $freeSpace           = $null
                        $spaceUsed           = $null

                        $dsProperties = $dsView | Where-Object { $psitem.MoRef -like "*$datastore" }

                        Write-Progress -Id 2 -ParentId 1 -Activity "Gathering Datastore Information" -Status "Processing Datastore" -CurrentOperation "$($dsProperties.Name)" -PercentComplete (($datastoreProgress/$datastoreCount) * 100)

                        $cap       = ((($dsProperties.Summary.Capacity/1024)/1024)/1024)
                        $freeSpace = ((($dsProperties.Summary.FreeSpace/1024)/1024)/1024)
                        $spaceUsed = $cap - $freeSpace

                        [pscustomobject] @{
                            Name           = $dsProperties.Name
                            FileType       = $dsProperties.Summary.Type
                            VMFSVersion    = if ($dsProperties.Summary.Type -eq 'vsan'){
                                'N/A'
                            } else {
                                $dsProperties.Info.Vmfs.MajorVersion
                            }
                            CapacityInGB   = [math]::Round($cap)
                            FreeSpaceInGB  = [math]::Round($freeSpace)
                            UsedSpaceInGB  = [math]::Round($spaceUsed)
                            vCenterCluster = $cluster.Name
                            vCenterName    = $vcenterServer
                        } # end psobj

                    } # end foreach $datastore

                } # end foreach $cluster

            } catch {

                throw "[Get-DatastoreInventory][ERROR]. $_ "

            } # end try/catch

        } # end foreach $vcenterServer

    } # end PROCESS block

    END {

        Write-Verbose -Message "[Get-DatastoreInventory] Processing Complete"

    } # end END block

} # end function Get-DatastoreInventory
