function Get-TSSession {

    <#
    .SYNOPSIS
        Retrieves terminal services session information from a local or remote system
    .DESCRIPTION
        Retrieves terminal services session information from a local or remote system

        This script/function parses the output from the 'qwinsta.exe' command, and formats it into a proper PSObject
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .PARAMETER ComputerName
        Name of computer/s
    .EXAMPLE
    Get-TSSession -ComputerName "server1"
    .EXAMPLE
    Get-TSSession -ComputerName (Get-Content C:\ComputerList.txt)
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20150519
        Last Update Notes:
        - [KMK] Renamed functon to Get-TSSession from Get-LoggedOnUser
    #>

    [cmdletbinding(
                   DefaultParameterSetName = 'session',
                   ConfirmImpact = 'low'
                   )]
    Param (
        [Parameter(
                   Mandatory = $false,
                   Position = 0,
                   ValueFromPipelineByPropertyName = $True)]
        [alias('HostName')]
        [string[]]$ComputerName = "$ENV:COMPUTERNAME"
    )

    BEGIN {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Started"

    } # end BEGIN block

    PROCESS {

        foreach ($c in $ComputerName) {

            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$c] Gathering logged on users"

            $sessions = $null
            $sessions = query session /server:$c

            # skip the first session; it's essentially the header when running qwinsta; we want don't care about parsing this and using it
            foreach ($session in ($sessions | Select-Object -Skip 1)) {

                [PSCustomObject] @{
                    ComputerName = $c
                    SessionName  = $session.Substring(1, 18).Trim()
                    UserName     = $session.Substring(19, 20).Trim()
                    ID           = $session.Substring(39, 9).Trim()
                    State        = $session.Substring(48, 8).Trim()
                    Type         = $session.Substring(56, 12).Trim()
                    Device       = $session.Substring(68).Trim()
                } # end $objSession

            } # end foreach $session

        } # end foreach $c

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-TSSessions
