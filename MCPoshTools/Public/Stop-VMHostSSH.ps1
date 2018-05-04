function Stop-VMHostSSH {

<#
.SYNOPSIS
    Stop the SSH service on a VMHost
.DESCRIPTION
    Stop the SSH service on a VMHost
.PARAMETER  Name
    VMHost Object
.EXAMPLE
    Get-VMHost esx01.corp.com | Stop-VMHostSSH -Verbose
.EXAMPLE
    Get-Cluster 'mgmt-clus-01' | Get-VMHost | Stop-VMHostSSH -Verbose
.INPUTS
    VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl
.OUTPUTS
    N/A
.NOTES
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20170124
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Fixed calling display name for host in Verbose output
#>

   [OutputType()]
    [CmdletBinding(DefaultParameterSetName = 'default')]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'default',
            ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]
        $Name
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

    } # end BEGIN block

    PROCESS {

        foreach ($vmHost in $Name) {

            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Stopping SSH on VMHost { $($vmHost.Name) }"
            try {

                $serviceSystem = $null
                $serviceSystem = Get-View $vmHost.ExtensionData.ConfigManager.ServiceSystem -ErrorAction 'Stop'
                $serviceSystem.StopService('TSM-SSH')

            } catch {

                throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not Stop the SSH service on VMHost { $($vmHost.Name) }"

            } # end try/catch

        } # end foreach $vmHost

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block


} # end function Stop-VMHostSSH
