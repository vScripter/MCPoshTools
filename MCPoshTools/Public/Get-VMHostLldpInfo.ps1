function Get-VMHostLLDPInfo {

        <#
    .SYNOPSIS
        Function to retrieve LLDP information from ESXi host network adapters.
    .DESCRIPTION
        Function to retrieve LLDP information from ESXi host network adapters.

        This function accepts a single host or multiple hosts and also accepts pipeline input from current PowerCLI cmdlets, such as Get-VMHost
    .PARAMETER Name
        The name of a host/s or a proper VMhost object.
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .EXAMPLE
        Get-VMHostLldpInfo -Name ESXi01,ESXi02 -Verbose | Format-Table -AutoSize
    .EXAMPLE
        Get-VMHost ESXi01,ESXi02 | Get-VMHostLldpInfo
    .EXAMPLE
        Get-VMHostLldpInfo -Name (Get-VMHost ESXI01.corp.domain) -Verbose | ft -a
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20171006
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Removed the customization of the switchport format; it's not a commong standard and the entire string value should be returned
        - Commendted using strong-type on the -Name parameter; changes in PowerCLI objects cause issues, depending on version

    #>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding(DefaultParameterSetName = 'default')]
    Param(
        [parameter(
            Position = 0,
            ValueFromPipeline = $true,
            ParameterSetName = 'default')]
        #[VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]
        $Name
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Started"

        Write-Debug -Message "[$PSCmdlet.MyInvocation.MyCommand.Name][DEBUG] Processing Started. 'Name' has value {$Name}"

    } # end BEGIN block

    PROCESS {

        foreach ($vmHost in $Name) {

            $pNicLldpInfo = $null
            $physicalNic  = $null
            $pNic         = $null
            $objNicLldp   = @()
            $vmHostApi    = $null

            Write-Debug -Message "[$PSCmdlet.MyInvocation.MyCommand.Name][DEBUG] Start of Foreach Loop. 'VMHostName' has value {$Name}"
            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Working on {$Name}"
            try {

                <# The 'QueryNetworkHint()' method is only available for use via the results of $hostNicQuery, which is why we need
                    to split the query in to two parts; we will use the first part to call methods, later #>

                $vmHostApi    = $vmHost.ExtensionData
                $hostNicQuery = Get-View $vmHostApi.ConfigManager.NetworkSystem -ErrorAction 'Stop'
                $physicalNic  = $hostNicQuery.NetworkInfo.Pnic

            } catch {

                throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Error during View Operations. $_"

            } # end try/catch


            try {

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Gathering physical NIC details"
                foreach ($pNic in $physicalNic) {

                    $switchPortFormat = $null
                    $pNicMeta         = $null
                    $lldpSwitchName   = $null
                    $pNicLldpInfo     = $hostNicQuery.QueryNetworkHint($pNic.Device)

                    if ($pNicLldpInfo.LLdpInfo) {

                        # split out the returned Port ID so we can customize the format
                        #$switchPortFormat = ($pNicLldpInfo.LldpInfo.PortId).Split(' ')

                        # match the current vmnic to data returned from another API so we can include other useful metadata about the pNIC
                        $pNicMeta = $vmHostApi.Config.Network.Pnic | Where-Object {$_.Device -eq $pNic.Device}

                        # switch name, if it exists
                        $lldpSwitchName = $pNicLldpInfo.LldpInfo.Parameter | Where-Object {$_.Key -eq 'System Name'}

                        <#
                            had to comment out the 'Networks' and 'VLANs' properties due to inconsistent errors that kept being thrown.
                            All thing considered, it's more concise without the output that these properties report, anyway.
                            Change was made on: 3/28/2017 (K. Kirkpatrick)
                        #>
                        [PSCustomObject] @{
                            VMHost           = $vmhost.Name
                            HostName         = ($vmhost.NetworkInfo.HostName).Trim()
                            pNIC             = $pNic.Device
                            pNicMACAddress   = $pNicMeta.Mac
                            pNicLinkSpeedMB  = $pNicMeta.LinkSpeed.SpeedMb
                            SwitchPortId     = $pNicLldpInfo.LldpInfo.PortId
                            #Networks        = if ($pNicLldpInfo.Subnet.IpSubnet) { $pNicLldpInfo.Subnet.IpSubnet -Join '|' } else { $null } # end if/else
                            #VLANs           = $pNicLldpInfo.Subnet.VlanID -Join '|'
                            #SwitchPortType  = $switchPortFormat[0].Trim()
                            #SwitchPort      = $switchPortFormat[1].Trim()
                            SwitchName       = if($lldpSwitchName){$lldpSwitchName.Value}else{$null}
                            SwitchMacAddress = $pNicLldpInfo.LldpInfo.ChassisId
                        } # end [PSCustomObject]

                    } # end if

                } # end foreach $pNic

            } catch {

                # custom error message
                $errorText = $null
                $errorText = "`r
VMHost:     $($vmhost.Name) `r
HostName:   $(($vmhost.NetworkInfo.Hostname).Trim()) `r
pNIC:       $($pNic.Device) `r
Error:      $($_) `r
"

                Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] $errorText"

            } # end try/catch

        } # end foreach

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-VMHostLLDPInfo
