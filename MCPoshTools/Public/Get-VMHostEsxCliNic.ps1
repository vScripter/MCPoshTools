function Get-VMHostEsxCliNic {

    <#
.SYNOPSIS
    Return the the same results of running 'esxcli network nic list' on a host, with the addition of a validation check, for each interface, that the
    PCI device number matches the vmnic name.
.DESCRIPTION
    Return the the same results of running 'esxcli network nic list' on a host, with the addition of a validation check, for each interface, that the
    PCI device number matches the vmnic name. This can be important due to naming standards and how interfaces are mapped within the vDS.

    The 'MatchCheck' property returns a bollean value based on a comparison of the last charater in the 'vmnic' value and the last character in the PCIDevice
    value. If configured correctly, these values should match.
.PARAMETER Cluster
.PARAMETER VMHost
.INPUTS
    VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl
.OUTPUTS
    System.Management.Automation.PSCustomObject
.EXAMPLE
    Get-Cluster Cluser-XYZ | Get-VMHost | Get-VMHostEsxCliNic | Out-GridView
.EXAMPLE
    Get-Cluster Cluser-XYZ | Get-VMHost | Get-VMHostEsxCliNic | Export-Csv C:\HostVibReport.csv -NoTypeInformation
.NOTES
    Author: Kevin Kirkpatrick (CSC)
   Email: See About_MCPoshTools for contact information
   Last Updated: 20150406
   Last Update Notes:
       - [KMK] Created
#>

    [cmdletbinding()]
    param (
        [parameter(Mandatory = $false,
                   ParameterSetName = 'VMHost',
                   ValueFromPipeline = $true,
                   DefaultParameterSetName = 'default')]
        [alias('Name')]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]
        $VMHost
    )

    BEGIN {



    } # end BEGIN block


    PROCESS {

        foreach ($vmhostName in $VMHost) {

            $esxcliQuery = $null

            Write-Verbose -Message "[$($vmhostName.Name)] Gathering Esx-Cli NIC Information"

            try {

                $esxcliQuery = ($vmhostName | Get-EsxCli -ErrorAction 'Stop').Network.NIC.List()

                foreach ($interface in $esxcliQuery) {

                    $objEsxCli = @()
                    $vmnicMatchCheck = $null
                    $pciMatchCheck = $null
                    [bool]$matchResult = $null

                    $vmnicMatchCheck = $interface.Name
                    $vmnicMatchCheck = $vmnicMatchCheck.substring($vmnicMatchCheck.length - 1)
                    $pciMatchCheck = $interface.PciDevice
                    $pciMatchCheck = $pciMatchCheck.substring($pciMatchCheck.length - 1)

                    if ($vmnicMatchCheck -ne $pciMatchCheck) {

                        $matchResult = $false

                    } elseif ($vmnicMatchCheck -eq $pciMatchCheck) {

                        $matchResult = $true

                    } # end if/elseif


                    $objEsxCli = [PSCustomObject] @{
                        VMHost = $vmhostName.Name
                        NICName = $interface.Name
                        PCIDevice = $interface.PCiDevice
                        MatchCheck = $matchResult
                        MTU = $interface.MTU
                        Speed = $interface.Speed
                        LinkStatus = $interface.Link
                        Duplex = $interface.Duplex
                        MACAddress = $interface.MACAddress
                        Description = $interface.Description
                    } # end $objEsxCli

                    $objEsxCli

                } # end foreach interface

            } catch {

                Write-Warning -Message "[$($vmhostName.Name)][Gathering ESXCLI Information][ERROR] $_ "

                $objEsxCli = [PSCustomObject] @{
                    VMHost = $vmhostName.Name
                    NICName = "[Gathering ESXCLI Information][ERROR] $_"
                    PCIDevice = $null
                    MatchCheck = $null
                    MTU = $null
                    Speed = $null
                    LinkStatus = $null
                    Duplex = $null
                    MACAddress = $null
                    Description = $null
                } # end $objEsxCli

                $objEsxCli

            } # end try/catch

        } # end foreach $vmh

    } # end PROCESS block


    END {

    } # end END block

} # end function Get-VMHostEsxCliNic
