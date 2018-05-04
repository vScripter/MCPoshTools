function Get-VMHostMapping {

    <#
    .SYNOPSIS
        Returns basic VMhost mapping from the VMHost all the way up to the vCenter Server
    .DESCRIPTION
        Returns basic VMhost mapping from the VMHost all the way up to the vCenter Server

        This information can be used to provide basic location information for VMHosts and where they are currently running
    .PARAMETER Server
        VI (vCenter) server name
    .PARAMETER Credential
        PS Credential to pass to connecting to the vCenter server
    .PARAMETER ReadInCredential
        Use this switch parameter if you wish to read in credentials from a pre-saved file. The files need to exist in a/the same directory.
    .PARAMETER CredentialStorePath
        UNC path to a directory where encrypted credential files are stored. These files should be created using the Export-Credential cmdlet/function that is part of this module
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .EXAMPLE
        Get-BVMHostMapping -Verbose | Export-Csv C:\VMHostMappings.csv -NoTypeInformation -Force
    .EXAMPLE
        Get-BVMHostMapping -Verbose | Out-GridView
    .NOTES
        Author: Kevin M. Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Version: 1.2
        Last Update: 20150612
        Last Update Notes:
        - Added support for alternate credentials
    #>

    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Cred')]
        [parameter(Mandatory = $false, Position = 0, ParameterSetName = 'ReadInCred')]
        [alias('VIServer')]
        [System.String]$Server,

        [parameter(Mandatory = $false, Position = 1, ParameterSetName = 'Cred')]
        [System.Management.Automation.PSCredential]$Credential,

        [parameter(Mandatory = $false, Position = 1, ParameterSetName = 'ReadInCred')]
        [Switch]$ReadInCredential,

        [parameter(Mandatory = $false, Position = 2, ParameterSetName = 'ReadInCred', HelpMessage = 'Enther the UNC path to the directory where the credential files are stored ')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [System.String]$CredentialStorePath = 'I:\Input\Credentials'

    )

    BEGIN {

        #Requires -Version 3

        Write-Verbose -Message 'Checking for VMware.VimAutomation.Core PSSnapin'
        if ((Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction 'SilentlyContinue').Name -eq $null) {

            try {

                Add-PSSnapin VMware.VimAutomation.Core -ErrorAction 'Stop'

            } catch {

                Write-Warning -Message "Error adding VMware PSSnapin: $_"
                Write-Warning -Message 'Exiting script'
                break

            } # try/catch

        } else {

            Write-Verbose -Message "'VMware.VimAutomation.Core' PSSnapin is already added; continuing..."

        } # end if/else


        # if -Server was specified, try connecting, else make sure there is a valid connection
        if ($Server) {

            Write-Verbose -Message 'Connecting to vCenter Server'

            try {

                if ($Credential) {

                    Connect-VIServer -Server $Server -Credential $Credential -ErrorAction 'Stop' | Out-Null

                } elseif ($ReadInCredential) {

                    $credentialFile = $null
                    $importCredential = $null
                    $credentialUserName = $null
                    $computerShortName = $null

                    if (($Server).Contains('.') -eq $true) {

                        $computerShortName = ($Server).Split('.')[0].ToUpper()

                    } else {

                        $computerShortName = $Server.ToUpper()

                    } # end if/else

                    $credentialFile = (Get-ChildItem -LiteralPath $CredentialStorePath -Filter *.clixml -ErrorAction 'Stop' | Where-Object { $_.Name -eq "$($computerShortName)_Cred.clixml" }).FullName
                    $importCredential = Import-Credential -Path $credentialFile -ErrorAction 'Stop'
                    $credentialUserName = $importCredential.UserName

                    Write-Verbose -Message "Alternative credentials imported from file {$credentialFile}. Attempting to connect with {$credentialUserName\*******}"
                    Connect-VIServer -Server $Server -Credential $importCredential | Out-Null

                } else {

                    Connect-VIServer -Server $Server -ErrorAction 'Stop' | Out-Null

                } # end if/else $Credential

            } catch {

                Write-Warning -Message 'Error connecting to vCenter'
                Write-Warning -Message 'Exiting script'
                break

            } # end try/catch

        } elseif (($global:defaultviserver).Name -eq $null) {

            Write-Warning -Message 'No default vCenter connection. Connect to vCenter or specify a vCenter Server name and try again.'
            Write-Warning -Message 'Exiting script'
            break

        } # end if/elseif

        $viServer = $global:defaultviserver.Name
        $viServerVersion = $global:defaultviserver.Version

        # write selected VI server to the console
        Write-Verbose -Message "Selected VI Server: $viServer"

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[$viServer] Gathering List of Clusters"
        try {

            $datacenterQuery = Get-View -Server $viServer -ViewType Datacenter -Property Name -ErrorAction 'Stop'

        } catch {

            Write-Warning -Message "[$viServer] Error Gathering List of Clusters"
            Write-Warning -Message "[$viServer] Exiting script"
            break

        } # end try/catch

        $dcCount = ($datacenterQuery).Count
        $dcProgress = 0

        foreach ($datacenter in $datacenterQuery) {

            $dcProgress++
            Write-Progress -Id 1 -ParentId 0 -Activity "Generating VM Host Mapping Detail" -Status "Processing Data Center" -CurrentOperation "$($datacenter.Name)" -PercentComplete (($dcProgress/$dcCount) * 100)

            $datacenterName = $null
            $clusterQuery = $null

            [System.DateTime]$dateGenerated = Get-Date

            $datacenterName = $datacenter.Name

            $clusterQuery = Get-View -Server $viServer -ViewType ClusterComputeResource -Property Name -SearchRoot $datacenter.MoRef

            $clusterCount = ($clusterQuery).Count
            $clusterProgress = 0

            foreach ($cluster in $clusterQuery) {

                $clusterProgress++
                Write-Progress -Id 2 -ParentId 1 -Activity "Gathering Cluster Inventory" -Status "Processing Cluster" -CurrentOperation "$($cluster.Name)" -PercentComplete (($clusterProgress/ $clusterCount) * 100)

                Write-Verbose -Message "[$viServer][$($cluster.Name)] Gathering list of VMHosts from cluster"

                #$clusterVMs = $null
                #$clusterVMs = Get-View -Server $viServer -ViewType VirtualMachine -Property Name, Guest, Runtime, Summary -SearchRoot $cluster.MoRef

                $clusterVmHosts = $null

                $clusterVMHosts = Get-View -Server $viServer -ViewType HostSystem -Property Name, Summary -SearchRoot $cluster.MoRef

                $vmHostCount = ($clusterVMHosts).Count
                $vmHostProgress = 0

                foreach ($vmHostSystem in $clusterVmHosts) {

                    $vmHostProgress++
                    Write-Progress -Id 3 -ParentId 2 -Activity "Gathering VM Host Inventory" -Status 'Processing Hypervisor' -CurrentOperation "$($vmHostSystem.Name)" -PercentComplete (($vmHostProgress/$vmHostCount) * 100)

                    Write-Verbose -Message "[$viServer][$($cluster.Name)][$($vmHostSystem.Name)] Gathering VMHost Information"

                    $colCustomInfo = @()
                    $objVmHostMapping = @()
                    [int]$hostUptime = $null
                    [int]$hostUptimeInDays = $null
                    [int]$hostCpuCoresPerSocket = $null
                    $memorySize = $null
                    $memorySizeGB = $null

                    $hostUptime = $vmHostSystem.summary.quickstats.uptime / 86400
                    $hostUptimeInDays = [System.Math]::Round($hostUptime)
                    $hostCpuCoresPerSocket = ($vmHostSystem.summary.hardware.NumCpuCores) / ($vmHostSystem.summary.hardware.NumCpuPkgs)
                    $memorySize = (($vmHostSystem.Summary.Hardware.MemorySize/1024)/1024)/1024
                    $memorySizeGB = [System.Math]::Round($memorySize)

                    $objVmHostMapping = [PSCustomObject] @{
                        Name = $vmHostSystem.name
                        vCenterServer = $viServer
                        Datacenter = $datacenterName
                        Cluster = $cluster.Name
                        Version = $vmHostSystem.summary.config.product.version
                        Build = $vmHostSystem.summary.config.product.build
                        APIVersion = $vmHostSystem.summary.config.product.apiversion
                        HAStatus = $vmHostSystem.summary.runtime.dashoststate.state
                        ConnectionState = $vmHostSystem.summary.runtime.ConnectionState
                        PowerState = $vmHostSystem.summary.runtime.powerstate
                        InMaintenanceMode = $vmHostSystem.summary.runtime.inmaintenancemode
                        UptimeInDays = $hostUptimeInDays
                        Manufacturer = $vmHostSystem.summary.hardware.vendor
                        Model = $vmHostSystem.summary.hardware.model
                        CPUModel = $vmHostSystem.summary.hardware.cpumodel
                        CPUSockets = $vmHostSystem.summary.hardware.NumCpuPkgs
                        CPUCores = $vmHostSystem.summary.hardware.NumCpuCores
                        CPUHyperCores = $vmHostSystem.summary.hardware.NumCpuThreads
                        CPUCoresPerSocket = $hostCpuCoresPerSocket
                        MemorySizeGB = $memorySizeGB
                        NumNICs = $vmHostSystem.summary.hardware.NumNics
                        NumHBAs = $vmHostSystem.summary.hardware.NumHBAs
                        RebootRequired = $vmHostSystem.summary.rebootrequired
                        CurrentEVCMode = $vmHostSystem.Summary.CurrentEVCModeKey
                        MaxEVCMode = $vmHostSystem.Summary.MaxEVCModeKey
                        vCenterVersion = $viServerVersion
                        Generated = $dateGenerated
                    } # end $objVmHostMapping

                    $objVmHostMapping

                } # end foreach $vmHostSystem

            } # end foreach $cluster

        } # end foreach $datacenter

    } # end PROCESS block

    END {


    } # end END block

} # end function  Get-VMHostMapping
