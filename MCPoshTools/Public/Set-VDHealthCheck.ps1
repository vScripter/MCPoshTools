function Set-VDHealthCheck {

    <#
    .SYNOPSIS
        Enable/Disable VDS Health Check for a given switch
    .DESCRIPTION
        Enable/Disable VDS Health Check for a given switch

        Currently, it only supports enabling/disabled of both of the available health check options:
        - VLAN & MTU
        - Teaming
    .PARAMETER Name
        Object of one, or more, desired switches
    .PARAMETER Enable
        Switch parameter to enable Health Check
    .PARAMETER Disable
        Switch parameter to disable Health Check
    .INPUTS
        VMware.VimAutomation.Vds.Types.V1.VmwareVDSwitch
    .OUTPUTS
        N/A
    .EXAMPLE
        Get-VDSwitch vds-prod-01 | Set-VDHealthCheck -Enabled -Verbose
    .EXAMPLE
        Get-VDSwitch vds-prod-01 | Set-VDHealthCheck -Disabled -Verbose
    .EXAMPLE
        Set-VDHealthCheck -Name (Get-VDSwitch *prod*) -Disable -Verbose
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20170221
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Changed "DVS" to "VDS" in verbose output messaging
    #>

    [OutputType()]
    [cmdletbinding(DefaultParameterSetName = 'defaut')]
    param (
        [parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'default',
            ValueFromPipeline = $true)]
        [Alias('VDS','VDSwitch')]
        [parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'enable',
            ValueFromPipeline = $true)]
        [parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'disable',
            ValueFromPipeline = $true)]
        [VMware.VimAutomation.Vds.Types.V1.VmwareVDSwitch[]]
        $Name,

        [parameter(
            Position = 1,
            Mandatory = $false,
            ParameterSetName = 'enable')]
        [Switch]
        $Enable,

        [parameter(
            Position = 1,
            Mandatory = $false,
            ParameterSetName = 'disable')]
        [Switch]
        $Disable
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Started"

    } # end BEGIN block

    PROCESS {

        foreach ($item in $Name) {

            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Working on VDS { $item }"
            try {

                $viewData = $null
                $viewData = $item.ExtensionData

                $healthCheckConfig = $null
                $healthCheckConfig = $viewData.Config.HealthCheckConfig


                if ($PSBoundParameters.Keys.Contains('Enable')){

                    $viewData | Foreach-Object {

                        $_.UpdateDVSHealthCheckConfig(

                            @(
                                (New-Object Vmware.Vim.VMwareDVSVlanMtuHealthCheckConfig -Property @{enable=1;interval="1"}),
                                (New-Object Vmware.Vim.VMwareDVSTeamingHealthCheckConfig -Property @{enable=1;interval="1"})
                            )# end array

                        ) # end method

                    } # end foreach

                } # end if

                if ($PSBoundParameters.Keys.Contains('Disable')){

                    $viewData | Foreach-Object {

                        $_.UpdateDVSHealthCheckConfig(

                            @(
                                (New-Object Vmware.Vim.VMwareDVSVlanMtuHealthCheckConfig -Property @{enable=0;interval="1"}),
                                (New-Object Vmware.Vim.VMwareDVSTeamingHealthCheckConfig -Property @{enable=0;interval="1"})
                            )# end array

                        ) # end method

                    } # end foreach-Object

                } # end if

            } catch {

                throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not apply Health Check confugruation. $_"

            } # end try/catch

        } # end foreach-Object $item

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Set-VDHealthCheck
