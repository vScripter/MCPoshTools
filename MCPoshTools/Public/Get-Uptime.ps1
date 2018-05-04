function Get-Uptime {

    <#
    .SYNOPSIS
        Returns the current system uptime.
    .DESCRIPTION
        Returns the current system uptime.
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .EXAMPLE
        Get-Uptime
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20161222
        Last Update Notes:
        - Minor formatting updates
    #>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param (
        [parameter(
            Mandatory = $false,
            ParameterSetName = 'Default',
            Position = 0,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ Test-Connection -ComputerName $_ -Count 1 -Quiet })]
        [alias('Comp', 'Name', 'DNSHostName')]
        [System.String[]]
        $ComputerName = "$env:COMPUTERNAME"
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

    } # end BEGIN block

    PROCESS {

        foreach ($computer in $ComputerName) {

            $uptimeData        = $null

            Write-Verbose -Message "[Get-Uptime] Gathering uptime detail for Computer {$computer}"
            try {

                $UTQuery    = $null
                $UptimeData = $null

                #$UTQuery    = Get-WmiObject -Query "SELECT LastBootuptime FROM win32_operatingsystem" -ComputerName $computer -ErrorAction Stop
                $UTQuery    = Get-CimInstance -ComputerName $computer -ClassName win32_operatingsystem -Property LastBootuptime -ErrorAction Stop
                $UptimeData = (Get-Date) - (Get-Date $UTQuery.lastbootuptime)

              [PSCustomObject]@{
                  ComputerName  = $computer
                  UptimeDays    = $UptimeData.Days
                  UptimeHours   = $UptimeData.Hours
                  UptimeMinutes = $UptimeData.Minutes
                  UptimeSeconds = $UptimeData.Seconds
                }

            } catch {

                throw "[Get-Uptime][ERROR] Could not gather or calculate uptime for Computer {$computer}. $_"

            } # end try/catch

        } # end foreach

    } # end PROCESS block

    END {

        Write-Verbose -Message "[Get-Uptime] Processing Complete"

    } # end END block

} # end function Get-Uptime
