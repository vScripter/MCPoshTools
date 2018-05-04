function Get-AgedItem {

<#
    .SYNOPSIS
        Gather aged files or folders from a given path
    .DESCRIPTION
        Gather/return files or folders that have a LastWriteTime older than the number of specified days. The default number of days is 14.

        This could be used to quickly gather things like log files and return their full path name, which can easily be used
        to pass along to the removal/archival method of your choosing.

        By default, if -File or -Folder is not specified, both will be returned in the results
    .PARAMETER  Path
        Path where you wish to query files
    .PARAMETER  Filter
        A filter you wish to apply to search for a common prefix, suffix, etc. Must use a '*' for wildcard
    .PARAMETER File
        Use this switch parameter to only return files
    .PARAMETER Directory
        Use this switch parameter to only return directories
    .PARAMETER Recurse
        use this swith to recurse through a directory structure
    .PARAMETER  AgeInDays
        The number of days you want to use as the start date for the query. Results will return files that are older than this date. The default value is 14
    .EXAMPLE
        Get-AgedItem -Path C:\Logs -AgeInDays 28
    .EXAMPLE
        Get-AgedItem -Path C:\Logs -Filter SystemLog*
    .INPUTS
        System.String,System.Int32
    .OUTPUTS
        System.String
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Version: 1.0
        Last Updated: 20150701
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Added -File, -Directory and -Recurse switch parameters
        - Renamed function to Get-Ageditem so that it would return files, folders, or both, depending on what you want
        - Added support for recurive searches
#>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [System.String]$Path,

        [Parameter(Position = 1, Mandatory = $false)]
        [System.Int32]$AgeInDays = 14,

        [Parameter(Position = 2, Mandatory = $false)]
        [System.String]$Filter = '*',

        [Parameter(Position = 3, Mandatory = $false, ParameterSetName = 'File')]
        [switch]$File,

        [Parameter(Position = 4, Mandatory = $false, ParameterSetName = 'Directory')]
        [switch]$Directory,

        [Parameter(Position = 5, Mandatory = $false)]
        [switch]$Recurse

    )

    BEGIN {

        $typeHashTable = @{
            Name = 'ItemType'
            Expression = {
                if ($_.PSIsContainer -eq $true) { 'Directory' } else { 'File' }
            } # end expression
        } # end $typeHashTable


    } # end BEGIN block

    PROCESS {

        try {

            $gciParameters = $null

            if ($File) {

                if ($Recurse) {

                    Write-Verbose -Message "[Get-AgedItem] Gathering files older than {$AgeInDays} days, recursively, from root path {$Path}"

                    $gciParameters = @{
                        LiteralPath = $Path
                        Filter = $Filter
                        ErrorAction = 'Stop'
                        File = $true
                        Recurse = $true
                    }

                    Get-ChildItem @gciParameters |
                    Where-Object { $psitem.lastwritetime -lt ((Get-Date).AddDays(- $AgeInDays)) } |
                    Select-Object FullName, LastWriteTime, $typeHashTable

                } else {

                    Write-Verbose -Message "[Get-AgedItem] Gathering files older than {$AgeInDays} days, from path {$Path}"

                    $gciParameters = @{
                        LiteralPath = $Path
                        Filter = $Filter
                        ErrorAction = 'Stop'
                        File = $true
                    }

                    Get-ChildItem @gciParameters |
                    Where-Object { $psitem.lastwritetime -lt ((Get-Date).AddDays(- $AgeInDays)) } |
                    Select-Object FullName, LastWriteTime, $typeHashTable

                } # end if/else $Recurse

            } elseif ($Directory) {

                if ($Recurse) {

                    Write-Verbose -Message "[Get-AgedItem] Gathering directories older than {$AgeInDays} days, recursively, from root path {$Path}"

                    $gciParameters = @{
                        LiteralPath = $Path
                        Filter = $Filter
                        ErrorAction = 'Stop'
                        Directory = $true
                        Recurse = $true
                    }

                    Get-ChildItem @gciParameters |
                    Where-Object { $psitem.lastwritetime -lt ((Get-Date).AddDays(- $AgeInDays)) } |
                    Select-Object FullName, LastWriteTime, $typeHashTable

                } else {

                    Write-Verbose -Message "[Get-AgedItem] Gathering directories older than {$AgeInDays} days, from path {$Path}"

                    $gciParameters = @{
                        LiteralPath = $Path
                        Filter = $Filter
                        ErrorAction = 'Stop'
                        Directory = $true
                    }

                    Get-ChildItem @gciParameters |
                    Where-Object { $psitem.lastwritetime -lt ((Get-Date).AddDays(- $AgeInDays)) } |
                    Select-Object FullName, LastWriteTime, $typeHashTable


                } # end if/else $Recurse

            } else {

                if ($Recurse) {

                    Write-Verbose -Message "[Get-AgedItem] Gathering files and directories older than {$AgeInDays} days, recursively, from root path {$Path}"

                    $gciParameters = @{
                        LiteralPath = $Path
                        Filter = $Filter
                        ErrorAction = 'Stop'
                        Recurse = $true
                    }

                    Get-ChildItem @gciParameters |
                    Where-Object { $psitem.lastwritetime -lt ((Get-Date).AddDays(- $AgeInDays)) } |
                    Select-Object FullName, LastWriteTime, $typeHashTable

                } else {

                    Write-Verbose -Message "[Get-AgedItem] Gathering files and directories older than {$AgeInDays} days, from path {$Path}"

                    $gciParameters = @{
                        LiteralPath = $Path
                        Filter = $Filter
                        ErrorAction = 'Stop'
                    }

                    Get-ChildItem @gciParameters |
                    Where-Object { $psitem.lastwritetime -lt ((Get-Date).AddDays(- $AgeInDays)) } |
                    Select-Object FullName, LastWriteTime, $typeHashTable


                } # end if/else $Recurse

            } # end if/else/elseif

        } catch {

            Write-Warning -Message "[Get-AgedItem][ERROR] I ran into issues gathering files older than {$AgeInDays} days, from path {$Path}. $_"

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[Get-AgedItem] Processing Complete"

    } # end END block

} # end function Get-AgedItem
