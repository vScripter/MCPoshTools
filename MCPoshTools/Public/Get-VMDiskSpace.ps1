function Get-VMDiskSpace {

<#
.SYNOPSIS
    Gather guest OS partition details from a VMware vSphere environment
.DESCRIPTION
    This script/function will return individual partition space details for VMware guests operating systems.

    The script/function is geared towards the virtualization administrator that may not have the necessary guest OS credentials or
    privileges to query partion level disk space details across a heterogeneous guest environment.

    This script/function pulls the information that is provided by VMware Tools, within the each guest OS. As such, VMware Tools
    must be installed to query this level of detail via the vSphere API.


    Sample output:

Name             : WINSERVER01
Partition        : C:\
CapacityInGB     : 50
SpaceUsedInGB    : 24
SpaceFreeInGB    : 26
PercentFree      : 51

Name             : WINSERVER01
Partition        : E:\
CapacityInGB     : 50
SpaceUsedInGB    : 26
SpaceFreeInGB    : 24
PercentFree      : 47

.PARAMETER Name
    Virtual Machine/Guest Object
.INPUTS
    VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine
.OUTPUTS
    System.Management.Automation.PSCustomObject
.EXAMPLE
    Get-VMDiskSpace -VM (Get-VM WINSRV01,WINSRV02,REDHAT01) | Format-Table -AutoSize
.EXAMPLE
    Get-VM WINSRV01,WINSRV02,REDHAT01 | Get-VMDiskSpace -Verbose | Out-GridView
.NOTES
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20161207
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Simplified code
    - Only supports input from Get-VM
    - Added [OutputType()]
    - Added default parameter set name
#>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [cmdletbinding(DefaultParameterSetName = "Default")]
    param (
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'default')]
        [alias('VM', 'Guest')]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $Name
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

    } # end BEGIN block

    PROCESS {

        foreach ($guest in $Name) {

            $ErrorActionPreference = 'Stop'

            $guestVcenter = $null
            $guestName    = $null

            $guestVcenter = ($guest.Uid.split('@'))[1].split(':')[0].ToLower()
            $guestName    = $guest.Name

            try {

                # call/set variables and variable types
                $vmViewData           = $null
                $diskInfo             = $null
                [int]$diskCapacity    = $null
                [int]$diskSpaceUsed   = $null
                [int]$diskSpaceFree   = $null
                [int]$diskPercentFree = $null

                $vmViewData = $guest.ExtensionData

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Guest { $guestName }"

                if ($vmViewData.Summary.Runtime.PowerState -eq 'PoweredOff') {

                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Guest { $guestName } managed by vCenter { $guestVcenter } is Powered Off"

                } elseif ($vmViewData.Summary.Runtime.PowerState -eq $null) {

                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Could not determine PowerState for guest { $guestName } managed by vCenter { $guestVcenter }"

                } else {

                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Gathering disk partition details for guest { $guestName }"

                    $diskInfo = $vmViewData.Guest.Disk

                    if ($diskInfo -eq $null) {

                        Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] No disk information was returned for guest { $guestName } managed by vCenter { $guestVcenter }"

                    } else {

                        foreach ($disk in $diskInfo) {

                            if ($disk.Capacity -eq 0) {

                                Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Disk capacity is zero; zeroing all values for the { $($disk.Diskpath) } partition on { $guestName }"
                                $diskCapacity    = 0
                                $diskSpaceUsed   = 0
                                $diskSpaceFree   = 0
                                $diskPercentFree = 0

                            } else {

                                $diskCapacity    = $disk.Capacity / 1GB
                                $diskSpaceUsed   = ($disk.Capacity - $disk.FreeSpace) / 1GB
                                $diskSpaceFree   = $disk.FreeSpace / 1GB
                                $diskPercentFree = ($disk.FreeSpace / $disk.Capacity) * 100

                            } # end if/else

                            [PSCustomObject] @{
                                Name          = $guestName
                                Partition     = $disk.DiskPath
                                CapacityInGB  = $diskCapacity
                                SpaceUsedInGB = $diskSpaceUsed
                                SpaceFreeInGB = $diskSpaceFree
                                PercentFree   = $diskPercentFree
                                vCenterServer = $guestVcenter
                            } # end  [PSCustomObject]

                        } # end foreach $disk

                    } # end if/else ($diskInfo -eq $null)

                } # end if/elseif/else ($Name.Summary.Runtime.PowerState -eq 'PoweredOff')

            } catch {

                Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][Error] Could not process guest { $guestName } managed by vCenter { $guestVcenter }. $_"

            } # end try/catch

            $ErrorActionPreference = 'Continue'

        } # end foreach $Name

    } # end PROCESS

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END

} # end function Get-VMDiskSpace
