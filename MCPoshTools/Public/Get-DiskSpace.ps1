function Get-DiskSpace {

    <#
.SYNOPSIS
    Return disk partition space details for a single or multiple computers
.DESCRIPTION
    Return disk partition space details for a single or multiple computers

    You can supply a single computer name, multiple computer names separated by a comma, or read in a list of computers from a .txt file
.PARAMETER ComputerName
    Name of computer/s you wish to query. FQDNs preferred.
.INPUTS
    System.String
.OUTPUTS
    System.Management.Automation.PSCustomObject
.EXAMPLE
    Get-DiskSpace -ComputerName SERVER01.corp.com, SERVER02.corp.com -Verbose | Format-Table -AutoSize
.EXAMPLE
    Get-DiskSpace -ComputerName (Get-Content C:\ServerList.txt) -Verbose | Where-Object {$_.PercentFree -lt 10} | Export-Csv C:\LowDiskSpaceReport.csv -NoTypeInformation
.NOTES
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20161205
    Last Update Notes:
    - Moved to CIM vs. WMI
    - Updated CBH
    - Added [OutputType]
    - Added default param set name
    - Minor syntax formatting
    - converted to dynamic creation/calling of object vs. saving to variable and then calling
#>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [cmdletbinding(DefaultParameterSetName = "Default")]
    param (
        [parameter(mandatory = $false,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 0,
                   ParameterSetName = 'default')]
        [alias('Comp', 'Name', 'DNSHostName')]
        [string[]]$ComputerName = "$ENV:COMPUTERNAME"
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        $sizeInGB = @{
            Name = "SizeGB"
            Expression = { [int]("{0:N2}" -f ($_.Size/1GB)) }
        }

        $freespaceInGB = @{
            Name = "FreespaceGB"
            Expression = { [int]("{0:N2}" -f ($_.Freespace/1GB)) }
        }

        $sizeUsedInGB = @{
            Name = "SizeUsedGB"
            Expression = { [int]("{0:N2}" -f (($_.Size/1GB) - ($_.Freespace/1GB))) }
        }

        $percentFree = @{
            name = "PercentFree"
            Expression = { [int](($_.FreeSpace/$_.Size) * 100) }
        }

    } # end BEGIN block

    PROCESS {

        foreach ($computer in $ComputerName) {

            if (Test-Connection -ComputerName $computer -Count 2 -Quiet) {

                try {

                    Write-Verbose -Message "[Get-DiskSpace] Gathering Disk Space Details for Computer {$computer}"

                    $diskQuery = $null
                    $diskQuery = Get-CimInstance -ComputerName $computer -Query "SELECT SystemName, Caption, VolumeName, Size, Freespace, DriveType FROM win32_logicaldisk WHERE drivetype = 3" -ErrorAction 'Stop' |
                    Select-Object SystemName, Caption, VolumeName, $sizeInGB, $freespaceInGB, $sizeUsedInGB, $percentFree

                    foreach ($disk in $diskQuery) {

                        [PSCustomObject] @{
                            SystemName  = $disk.SystemName
                            DriveLetter = $disk.Caption
                            VolumeName  = $disk.VolumeName
                            SizeGB      = $disk.SizeGB
                            SizeUsedGB  = $disk.SizeUsedGB
                            FreeSpaceGB = $disk.FreeSpaceGB
                            PercentFree = $disk.PercentFree
                        } # end [PSCustomObject]

                    } # foreach

                } catch {

                    Write-Warning -Message "[Get-DiskSpace][ERROR] Could not gather disk space detail for Computer {$computer}. $_"

                } # try/catch

            } else {

                Write-Warning -Message "[Get-DiskSpace][ERROR] Computer {$computer} was unreachable via ping"

            } # if/else

        } # foreach

    } # end PROCESS block

    END {

        Write-Verbose -Message "[Get-DiskSpace] Processing Complete."

    } # end END block

} # end function Get-DiskSpace
