function Get-VMHostEsxCliIscsiParam {

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

    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param (
        [parameter(Mandatory = $false,
                   Position = 0,
                   ValueFromPipeline = $true)]
        [alias('Name')]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]
        $VMHost,

        [parameter(Mandatory = $false,
                   Position = 1)]
        [System.String]$iSCSIAdapterName = 'vmhba32'
    )

    BEGIN {



    } # end BEGIN block


    PROCESS {

        foreach ($vmhostName in $VMHost) {

            $esxcliQuery = $null

            Write-Verbose -Message "[$($vmhostName.Name)] Gathering Esx-Cli NIC Information"

            try {

                $esxcliQuery = ($vmhostName | Get-EsxCli -ErrorAction 'Stop').iscsi.adapter.param.get("$iSCSIAdapterName")

                foreach ($iscsiParam in $esxcliQuery) {

                    $objEsxCli = @()

                    $objEsxCli = [PSCustomObject] @{
                        VMHost = $vmhostName.Name
                        Current = $iscsiParam.Current
                        Default = $iscsiParam.Default
                        ID = $iscsiParam.ID
                        Inherit = $iscsiParam.Inherit
                        Max = $iscsiParam.Max
                        Min = $iscsiParam.Min
                        Name = $iscsiParam.Name
                        Settable = $iscsiParam.Settable
                    } # end $objEsxCli

                    $objEsxCli

                } # end foreach interface

            } catch {

                Write-Warning -Message "[$($vmhostName.Name)][Gathering ESXCLI Information][ERROR] $_ "

                $objEsxCli = [PSCustomObject] @{
                    VMHost = $vmhostName.Name
                    Current = $null
                    Default = $null
                    ID = $null
                    Inherit = $null
                    Max = $null
                    Min = $null
                    Name = $null
                    Settable = $null
                } # end $objEsxCli

                $objEsxCli

            } # end try/catch

        } # end foreach $vmh

    } # end PROCESS block


    END {

    } # end END block

} # end function Get-VMHostEsxCliIscsiParam
