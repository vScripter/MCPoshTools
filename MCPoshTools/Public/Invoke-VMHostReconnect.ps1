function Invoke-VMHostReconnect {

<#
.SYNOPSIS
    Reconnect multiple hosts to vCenter that are reporting a specific connection state
.DESCRIPTION
    This script/function will submit a task which will attempt to reconnect multiple hosts to vCenter, based on their current connection state. Valid connection states are
    - Connected
    - Disconnected
    - NotResponding

    Host credentials are passed via Get-Credential or a variable with proper PSCrednetial values.

    There is a -Force parameter option that will force-add the host to vCenter (or at least attempt to do so). What this means is that it will ignore
    any warning messages that would typically abort the reconnect process, such as, the host being managed by a different vCenter server Name or IP address. Make
    sure you use caution when running with -Force.

    This script/function also supports using -WhatIf, which will SIMULATE the process.

    For verbose output, the reccomendation is to always run with the -Verbose switch.

    If a vCenter server is provided using the -Server parameter, a connection attempt will be made to that vCenter. If you are already connected to a vCenter server,
    or multiple vCenter servers, the most recently connected vCenter server will be the one that this script/function runs against. (This is the server stored in the
    $Global:DefaultVIServer variable. To list all connected vCenter servers, check the $Global:DefaultVIServers (plural) variable.
.PARAMETER Server
    VI Server name, if desired
.PARAMETER SearchRoot
    You can query for all hosts within a Cluster, Datacenter, Folder or Global
.PARAMETER SearchName
    This is the name of the object specified in -SearchRoot. EX: If you specified '-SearchRoot Cluster' then the -SearchName value should
    be the name of the cluster you want to query
.PARAMETER HostCredential
    The host credential that has root access; in most cases this would be the root user name and password
.PARAMETER QueryConnectionState
    This is the connection state that you wish to query for
.PARAMETER Force
    If you supply the -Force switch, it will attempt to force-reconnect the host. This would be required, say, if the IP address of vCenter changed
.INPUTS
    System.String
    System.Management.Automation.PSCredential
.OUTPUTS
    N/A
.EXAMPLE
    Invoke-VMHostReconnect -HostCredential (Get-Credential) -Force -Verbose -WhatIf

    This will attempt to accept the default value for SearchScope, which is 'Global' as well as the default value for -QueryConnectionState, which
    is 'NotResponding'. The result is a query to the entire vCenter inventory for any host that is reporting a 'NotResponding' status. The -WhatIf param
    will prevent any action from being taken but will simulate the work.
.EXAMPLE
    Invoke-VMHostReconnect -Server 'vcenter1.domain.corp' -HostCredential (Get-Credential) -SearchRoot Cluster -SearchName 'DC01_C1' -QueryConnectionState 'NotResponding' -Verbose -Force

    This will attempt to connect to the provided vCenter server and reconnect hosts in the 'DC01_C1' cluster that are in a 'NotResponding' state. The -Force param will force-add them and
    ignore any warnings
.EXAMPLE
    $vicred = Get-Credential
    C:\PS>Invoke-VMHostReconnect -Server 'vcenter1.domain.corp' -Cred $vicred -SR Datacenter -SN 'DC01' -QCS 'NotResponding' -Verbose -WhatIf

    This will connect to the provided vCenter server, use the credentials supplied stored in $vicred, and 'test' reconnecting all hosts that are 'NotResponding'
    in the 'DC01' virtual datacenter. It also uses the 'alias' names for some of the parameters that support aliases.
.NOTES

    #TAG:

    Author: Kevin M. Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Update: 20161007
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Minor formatting updates
#>
    [OutputType()]
    [cmdletbinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High',
        DefaultParameterSetName = 'default')]
    param (
        [parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'default')]
        [ValidateSet('Cluster', 'Datacenter', 'Folder', 'Global')]
        [alias('SR')]
        [System.String]
        $SearchRoot = 'Global',

        [parameter(
            Mandatory = $false,
            Position = 1,
            ParameterSetName = 'default')]
        [alias('SN')]
        [System.String]
        $SearchName,

        [parameter(
            Mandatory = $true,
            Position = 2,
            ParameterSetName = 'default')]
        [alias('Credential', 'Cred')]
        [System.Management.Automation.PSCredential]
        $HostCredential,

        [parameter(
            Mandatory = $false,
            Position = 3,
            ParameterSetName = 'default')]
        [ValidateSet('NotResponding', 'Disconnected', 'Connected')]
        [alias('QCS')]
        [System.String]
        $QueryConnectionState = 'NotResponding',

        [parameter(
            Mandatory = $false,
            ParameterSetName = 'default')]
        [System.String]
        $Server,

        [parameter(
            Mandatory = $false,
            ParameterSetName = 'default')]
        [switch]
        $Force
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        # setting the EA pref to 'Stop' in order to force any error to be a terminating error and thus be caught in the try/catch loop
        $ErrorActionPreference = 'stop'


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

            Write-Verbose -Message "VMware.VimAutomation.Core PSSnapin is already added; continuing..."

        } # end if/else


        # if -Server was specified, try connecting, else make sure there is a valid connection
        if ($Server) {

            Write-Verbose -Message 'Connecting to vCenter Server'

            try {

                Connect-VIServer -Server $Server | Out-Null

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

        # write selected VI server to the console
        Write-Verbose -Message "Selected VI Server: $global:defaultviserver"


        # define proper query based on input provided to -SearchRoot param
        switch ($SearchRoot) {

        <#
        for each of the different queries that support a -SearchRoot param, the object type has to be a VI MoRef object, which is why
        we convert/store the MoRef obj, first, and then supply it in the form of a variable when we run the command. We are filtering
        a 'global' Get-View query, which is much more effecient than running a foreach loop against an array of hosts, and then trying
        to loop through and run Get-View for each.
        #>

            'Cluster' {

                $hostMoRef = (Get-Cluster -Name $SearchName | Get-View).MoRef

                $hostQuery = Get-View -ViewType 'Hostsystem' -SearchRoot $hostMoRef -Property 'name' -Filter @{ "Runtime.ConnectionState" = "$QueryConnectionState" }

            } # end 'Cluster'

            'Datacenter' {

                $dcMoRef = (Get-Datacenter -Name $SearchName | Get-View).MoRef

                $hostQuery = Get-View -ViewType 'Hostsystem' -SearchRoot $dcMoRef -Property 'name' -Filter @{ "Runtime.ConnectionState" = "$QueryConnectionState" }

            } # end 'Datacenter'

            'Folder' {

                $folderMoRef = (Get-Folder -Name $SearchName | Get-View).MoRef

                $hostQuery = Get-View -ViewType 'Hostsystem' -SearchRoot $folderMoRef -Property 'name' -Filter @{ "Runtime.ConnectionState" = "$QueryConnectionState" }

            } # end 'Folder'

            'Global' {

                $hostQuery = Get-View -ViewType 'Hostsystem' -Property 'name' -Filter @{ "Runtime.ConnectionState" = "$QueryConnectionState" }

            } # end 'Global'

        } # end switch


    } # end BEGIN block

    PROCESS {

        # recurse through each host returned in $hostQuery
        Foreach ($vmHost in $hostQuery) {

            # clear $objVMHost on each iteration to ensure accurate data
            $objVMHost = $null

            # the line below adds support for using -WhatIf
            if ($PSCmdlet.ShouldProcess($vmHost.Name, 'Attemtping to reconnect host to vCenter')) {

                # Add info to the console on current host
                Write-Verbose -Message "[$($vmHost.name)] Working..."

                Try {

                    # create proper host object
                    $objVMHost = New-Object VMware.Vim.HostConnectSpec

                    # grab the actual host name string value
                    $objVMHost.hostName = $vmHost.Name

                    # grab the username string value that was provided in $HostCredential
                    $objVMHost.userName = $HostCredential.UserName

                    <# grab the password string value that was provided in $HostCredential. By default the password is stored encrypted when
                    working with [PSCredential] objects, which is why we need to convert to plain text #>
                    $objVMHost.password = $HostCredential.GetNetworkCredential().Password

                    # set the 'force' bit to force the reconnect operation, if the -Force param was supplied
                    if ($Force) {

                        $objVMHost.force = $true

                    } # end if $Force

                    # Reconnect the host
                    $vmHost.ReconnectHost_Task($objVMHost, $null)

                } Catch {

                    # write error details to the screen as well as to a log file
                    Write-Warning -Message "[$($vmHost.Name))][ERROR] $_"

                    # need to change logging to use Write-Log function that is part of the MCPoshTools module
                    #Write-Output "[$($vmHost.Name))][ERROR] $_" | Out-File "$PSScriptRoot\Invoke-VMHostReconnect.log" -Append

                } # end try/catch

            } # end if $pscmdlet.shouldprocess

        } # end foreach $vmhost

    } # end PROCESS block

    END {


    } # end END block

} # end function Invoke-VMHostReconnect
