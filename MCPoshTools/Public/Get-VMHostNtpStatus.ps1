function Get-VMHostNtpStatus {

    <#
    .SYNOPSIS
        Return service and configuration information for NTP on the provided ESXi Host Systems
    .DESCRIPTION
        Return service and configuration information for NTP on the provided ESXi Host Systems.

        This function accepts pipeline input from the 'Get-VMHost' cmdlet, which is part of PowerCLI.

        Queries against host system IP addresses will not work.

        This function also already assumes that you are connected to one or most ESXi Hosts or vCenter Servers. If connected to multiple hosts/vCenters, filter
        what you wish to run the function against, using 'Get-VMHost'.
    .PARAMETER VMHost
        VMHost system/s you wish to run the command against
    .INPUTS
        VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .EXAMPLE
        Get-VMHost | Get-VMHostNtpStatus -Verbose
    .EXAMPLE
        Get-VMHostNtpStatus -VMHost (Get-VMHost) -Verbose
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20161222
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - [PSCustomObject] is now returned without saving to a variable, before calling
        - Minor syntax updates
    #>

    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param (
        [parameter(Mandatory = $true,
                   Position = 0,
                   ValueFromPipelineByPropertyName = $true,
                   ValueFromPipeline = $true)]
        [alias('Name')]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]
        $VMHost
    )

    BEGIN {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Begin Processing"

    } # end BEGIN block

    PROCESS {

        foreach ($esx in $VMHost) {

            try {

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Gathering NTP configuration data from host {$($esx.Name)}"

                $esxApi      = $null
                $esxHostName = $null
                $ntpConfig   = $null
                $ntpSvc      = $null

                $esxApi      = $esx.ExtensionData
                $esxHostName = $esxApi.Name
                $ntpConfig   = ($esxApi.Config.DateTimeInfo.NtpConfig.Server) -Join '|'
                $ntpSvc      = $esxApi.Config.Service.Service | Where-Object { $_.Key -eq 'ntpd' }

                [PSCustomObject] @{
                    VMHost      = $esxHostName
                    Service     = $ntpSvc.Key
                    Running     = $ntpSvc.Running
                    Policy      = $ntpSvc.Policy
                    NTPServers  = $ntpConfig
                    TimeZone    = $esxApi.Config.DateTimeInfo.TimeZone.Name
                    Description = $ntpSvc.Label
                    Required    = $ntpSvc.Required
                } # end [PSCustomObject]


            } catch {

                Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not process {$($esx.Nam)}. $_ "

            } # end try/catch

        } # end foreach $system

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-VMHostNtpStatus
