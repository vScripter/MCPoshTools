function Get-ProcessOwner {

    <#
    .SYNOPSIS
        Return windows process owner information and memory useage for a given process
    .DESCRIPTION
        Return windows process owner information and memory useage for a given process.

        The process name must include .exe

        You can use the -ComputerName to execute a WMI query against a remote machine process.

        If querying the local system, a '(C)' will appear next to the process ID, which signifies the current powershell.exe process that you are running the function in
    .PARAMETER ComputerName
        Name of remote computer you wish to query
    .PARAMETER ProcessName
        Name of process you want to gather owner information from
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .EXAMPLE
        Get-ProcessOwner -ProcessName powershell.exe | Format-Table -AutoSize
    .EXAMPLE
        Get-ProcessOwner -ComputerName 'server1.corp.com' -ProcessName powershell.exe | Format-Table -AutoSize
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Version: 1.1
        Last Updated: 20151022
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Moved the '(C)' to the right of the process ID
    #>

    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(Mandatory = $false, Position = 1)]
        [ValidateScript({ Test-Connection -ComputerName $_ -Count 1 -Quiet })]
        [System.String]$ComputerName,

        [parameter(Mandatory = $true, Position = 0)]
        [System.String]$ProcessName
    )

    BEGIN {


    } # end BEGIN block

    PROCESS {

        if ($ComputerName) {

            Write-Verbose -Message "[Get-ProcessOwner] Gathering process owner information for process {$ProcessName} on {$ComputerName}"

            Get-WmiObject -ComputerName $ComputerName -Query "SELECT * FROM win32_process WHERE name='$processName'" | ForEach-Object {
                <# convert $_.ProcessID from uInt32 to Int32 for consistency; handle $_.workingsetsize math here and then format in the property
                declaration. #>
                [System.Int32]$processID = $null
                [double]$workingSetSize = $null

                $processID = $_.ProcessID
                $workingSetSize = $_.workingsetsize/1MB

                $obj = @()
                $obj = [PSCustomObject]@{
                    Name = $_.Name
                    Owner = "$(($_).getowner().Domain)" + '\' + "$(($_).getowner().User)"
                    PID = if ($processID -eq $PID) { "$processID (C)" } else { $processID }
                    WorkingSetMB = "{0:N2}" -f $workingSetSize
                } # end $obj
                $obj

            } # end foreach

        } else {

            Write-Verbose -Message "[Get-ProcessOwner] Gathering process owner information for process { $ProcessName }"

            Get-WmiObject -Query "SELECT * FROM win32_process WHERE name='$processName'" | ForEach-Object {
                <# convert $_.ProcessID from uInt32 to Int32 for consistency; handle $_.workingsetsize math here and then format in the property
                declaration. #>
                [System.Int32]$processID = $null
                [double]$workingSetSize = $null

                $processID = $_.ProcessID
                $workingSetSize = $_.workingsetsize/1MB

                $obj = @()
                $obj = [PSCustomObject]@{
                    Name = $_.Name
                    Owner = "$(($_).getowner().Domain)" + '\' + "$(($_).getowner().User)"
                    PID = if ($processID -eq $PID) { "$processID (C)" } else { $processID }
                    WorkingSetMB = "{0:N2}" -f $workingSetSize
                } # end $obj
                $obj

            } # end foreach

        } # end if/else

    } # end PROCESS block

    END {

        Write-Verbose -Message '[Get-ProcessOwner] Processing Complete.'

    } # end END block

} # end function Get-ProcessOwner
