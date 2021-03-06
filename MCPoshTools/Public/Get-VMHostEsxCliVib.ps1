function Get-VMHostEsxCliVib {

    <#
.SYNOPSIS
    Get details on a specific ESXi VIB
.DESCRIPTION
    Get details on a specific ESXi VIB.

    This can be usefule if you are looking for version information about a given package on an ESXi host.

    This script/function is best utilized when sending a host object to it via the pipeline; see examples for more detail.
.INPUTS
    VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl
.PARAMETER VMHost
    Name of ESXi host
.PARAMETER VIBName
    Name of vib package you wish to query detail for
.EXAMPLE
    PS C:\> Get-VMHost | Get-VMHostEsxCliVib -VIBName hp-ams
.EXAMPLE
    PS C:\> Get-VMHost esxihost01.company.com | Get-VMHostEsxCliVib -VIBName hp-ams

Host             : esxihost01.company.com
Name             : hp-ams
Version          : 550.10.0.1-07.1198610
Vendor           : Hewlett-Packard
InstallDate      : 2014-10-03
ID               : Hewlett-Packard_bootbank_hp-ams_550.10.0.1-07.1198610
CreationDate     : 2014-09-09
Status           :
HostVersion      : 5.5.0
HostVersionBuild : 1892794
HostMfg          : HP
HostModel        : ProLiant BL460c Gen8

.NOTES
    Author: Kevin Kirkpatrick (CSC)
   Email: See About_MCPoshTools for contact information
   Last Updated: 20150406
   Last Update Notes:
       - [KMK] Added to module


#>

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param
    (
        [Parameter(ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 0)]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]
        $VMHost,

        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $false,
                   ValueFromPipelineByPropertyName = $false,
                   Position = 1)]
        [string]$VIBName
    )

    BEGIN {

        #Requires -Version 3

    } # BEGIN

    PROCESS {

        try {
            Write-Verbose -Message "Working on $($_.Name)..."

            # Clear/set variables
            $esxcli = $null
            $softwareList = $null

            # Assign vmhost query objects to a variable to be called later
            $esxcli = Get-EsxCli -VMHost $VMHost
            $softwareList = $esxcli.software.vib.list() | Where-Object { $_.Name -like "*$VIBName*" }

            # get uptime details
            $bootTime = ($VMHost | Get-View).runtime.boottime
            $calcUptime = ((Get-Date) - $bootTime)

            # Create custom object to store host/vib information
            $objHpVib = [PSCustomObject] @{
                Host = $_.Name
                VibName = $softwareList.Name
                VibVersion = $softwareList.Version
                VibVendor = $softwareList.Vendor
                VibInstallDate = $softwareList.InstallDate
                VibID = $softwareList.ID
                VibCreationDate = $softwareList.CreationDate
                VibStatus = $softwareList.Status
                HostUptimeDays = $calcUptime.Days
                HostVersion = $_.Version
                HostVersionBuild = $_.Build
                HostMfg = $_.Manufacturer
                HostModel = $_.Model
                Status = $null
            } # $objHpVib

            $objHpVib

        } catch {

            Write-Warning -Message "Error gathering detail from $VMHost"

            # clear/set the $colError array
            $objError = @()

            # create new object to store error detail
            $objError = [PSCustomObject] @{
                Host = $_.Name
                VibName = $null
                VibVersion = $null
                VibVendor = $null
                VibInstallDate = $null
                VibID = $null
                VibCreationDate = $null
                VibStatus = $null
                HostUptimeDays = $null
                HostVersion = $null
                HostVersionBuild = $null
                HostMfg = $null
                HostModel = $null
                Status = "$_"
            } # $objError

            $objError

        } # try/catch

    } # PROCESS

    END {

    } # END

} # end function Get-VMHostEsxCliVib
