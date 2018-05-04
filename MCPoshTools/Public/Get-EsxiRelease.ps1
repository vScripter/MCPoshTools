function Get-EsxiRelease {

    <#
    .SYNOPSIS
        Return information about ESXi release information
    .DESCRIPTION
        Return information about ESXi release information

        Information is pulled from an external source, which is maintained by an unofficial 3rd party from VMware (http://www.virten.net/repo/esxiReleases.json)
    .PARAMETER InputPath
        Path to input file that contians build information
    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .EXAMPLE
        Get-EsxiRelease -Verbose
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20161219
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Added -Raw parameter when reading json file; it creates errors in PS v4 if you don't use it
    #>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [cmdletbinding(DefaultParameterSetName = 'defaut')]
    param (
        [parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = 'default')]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        $InputPath = "$PSScriptRoot\..\Inputs\esxiReleases.json"
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Started"

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Querying database file"
        try {

            $json = $null
            $json = Get-Content -Path $InputPath -Raw -ErrorAction 'Stop' | ConvertFrom-Json -ErrorAction 'Stop'

            $lastUpdate = $null
            $lastUpdate = ([datetime]'1/1/1970').AddSeconds("$($json.timestamp)")

            foreach ($entry in $json.data.esxiReleases) {

                [PSCustomObject] @{
                    Build           = $entry.Build
                    MinorRelease    = $entry.MinorRelease
                    UpdateRelease   = $entry.UpdateRelease
                    ReleaseLevel    = $entry.ReleaseLevel
                    ReleaseFullName = $entry.ReleaseFullName
                    FriendlyName    = $entry.FriendlyName
                    PatchRelease    = $entry.PatchRelease
                    ReleaseDate     = $entry.ReleaseDate
                    ImageProfile    = $entry.ImageProfile
                    LastUpdate      = $lastUpdate
                } # end obj

            } # end foreach

        } catch {

            throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not get information from file { $InputPath }. $_"

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-EsxiRelease
