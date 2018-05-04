function Get-TSUserSession {

    <#
    .SYNOPSIS
        Retrieves terminal services user session information from a local or remote system
    .DESCRIPTION
        Retrieves terminal services user session information from a local or remote system

        This script/function parses the output from the 'quser.exe' command, and formats it into a proper PSObject
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
        - [KMK] Created
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
        [string[]]$ComputerName = 'localhost'
    )

    BEGIN {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Started"

    } # end BEGIN block

    PROCESS {

        foreach ($c in $ComputerName) {

            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][$c] Gathering logged on users"

            $sessions = $null
            $sessions = query user /server:$c

            # skip the first session; it's essentially the header when running qwinsta; we want don't care about parsing this and using it
            foreach ($session in ($sessions | Select-Object -Skip 1)) {

                [PSCustomObject] @{
                    ComputerName = $c
                    UserName     = $session.Substring(1, 22).Trim()
                    SessionName  = $session.Substring(23, 19).Trim()
                    ID           = $session.Substring(42, 4).Trim()
                    State        = $session.Substring(46, 8).Trim()
                    IdleTime     = $session.Substring(54, 11).Trim()
                    LogonTime    = $session.Substring(65).Trim()
                } # end $objSession

            } # end foreach $session

        } # end foreach $c

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-TSUserSessions
