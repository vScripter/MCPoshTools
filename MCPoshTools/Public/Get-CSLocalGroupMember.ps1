function Get-CSLocalGroupMember {

    <#
    .SYNOPSIS
        List the group members of a local group
    .DESCRIPTION
        List the group members of a local group.

        This can be used to audit what groups and accounts are in a local computer group.

        By default, members of the 'Administrators' group will be returned.

    .PARAMETER  ComputerName
        name of computer you wish to query group membership
    .PARAMETER  LocalGroupName
        Name of local group you wish to query group membership
    .EXAMPLE
        Get-CSLocalGroupMember -ComputerName SERVER01,SERVER02 -Verbose | Format-Table -AutoSize
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Version: 1.1
        Last Updated: 20161205
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Added [OutputType()]
        - Updated CBH
        - Added default param set name
        - Renamed to Get-CSLocalGroupMember so that it wouldn't collide with MSFT native cmdlet
#>
    [OutputType([System.Management.Automation.PSCustomObject])]
    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(Mandatory = $false, Position = 0, ParameterSetName = 'default')]
        [System.String[]]$ComputerName = "$env:computername",

        [parameter(Mandatory = $false, Position = 1, ParameterSetName = 'default')]
        [System.String]$LocalGroupName = 'Administrators'
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

    }

    PROCESS {

        foreach ($computer in $ComputerName) {

            if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {

                if ([ADSI]::Exists("WinNT://$computer/$localGroupName,group")) {

                    try {

                        $groupQuery = $null

                        Write-Verbose -Message "[Get-LocalGroupMember] Processing group members from local group {$LocalGroupName} on computer {$computer}."

                        $groupQuery = [ADSI]("WinNT://$computer/$localGroupName,group")

                        $GroupQuery.Members() | ForEach-Object {

                            $adPath = $null
                            $parseUserName = $null
                            $userName = $null
                            $userDomain = $null
                            $class = $null
                            $formattedUserName = $null

                            $adsPath = $_.GetType().InvokeMember("Adspath", 'GetProperty', $null, $_, $null)
                            # Domain members will have an ADSPath like WinNT://DomainName/UserName.
                            # Local accounts will have a value like WinNT://DomainName/ComputerName/UserName.

                            $parseUserName = $AdsPath.split('/', [StringSplitOptions]::RemoveEmptyEntries)
                            $userName = $parseUserName[-1]
                            $userDomain = $parseUserName[-2]
                            $class = $_.GetType().InvokeMember("Class", 'GetProperty', $null, $_, $null)

                            $formattedUserName = "$userDomain\$userName"

                            $objGroupMember = [PSCustomObject] @{
                                ComputerName = $computer
                                GroupName = $LocalGroupName
                                Domain = $userDomain
                                UserName = $userName
                                NTAccountName = $formattedUserName
                            }
                            $objGroupMember

                        } # end foreach

                    } catch {

                        Write-Warning -Message "[Get-LocalGroupMember][ERROR] Could not gather group members from local group {$LocalGroupName} on computer {$computer}. $_"

                    } # end try/catch

                } else {

                    Write-Warning -Message "[Get-LocalGroupMember][ERROR] Local Group {$LocalGroupName} was not found on computer {$computer}"

                } # end if/else ADSI

            } else {

                Write-Warning -Message "[Get-LocalGroupMember][ERROR] Computer {$computer} was unreachable via ping"

            } # end if/else Test-Connection

        } # end foreach $computer

    } # end PROCESS

    END {

        Write-Verbose -Message "[Get-LocalGroupMember] Processing Complete."

    } # end END block

} # end function Get-CSLocalGroupMember
