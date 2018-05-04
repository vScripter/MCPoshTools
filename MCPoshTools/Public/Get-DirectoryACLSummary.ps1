function Get-DirectoryACLSummary {

    <#
    .SYNOPSIS
        Recurse through a directory structure, starting at a specified path, and report details on ACE/ACL inheritance.
    .DESCRIPTION
        Recurse through a directory structure, starting at a specified path, and report details on ACE/ACL inheritance

        This script will produce inaccurate results if you do not have access to all directories and sub directories.

        Running SubInAcl may be required.
    .PARAMETER Path

    .PARAMETER Depth

    .EXAMPLE
        Get-DirectoryACLSummary -Path D:\Some\Dir\Path -Verbose | Out-GridView

    .EXAMPLE
        Get-DirectoryACLSummary -Path D:\Some\Dir\Path -Verbose | Export-CSV -NoTypeInformation -Path $home\Desktop\Dir-ACL-Report.csv -Force

    .EXAMPLE
        Get-DirectoryACLSummary -Path D:\Some\Dir\Path -Depth 3

        This will only go three levels deep in the directory structure.

    .INPUTS
        System.String
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .NOTES

        --------------------------------
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20171025
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Minor spacing fixes
    #>

    [cmdletbinding(DefaultParameterSetName = 'Default')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [parameter(mandatory = $true, Position = 0, ParameterSetName = 'Default')]
        [parameter(mandatory = $true, Position = 0, ParameterSetName = 'Depth')]
        [Alias('RootPath')]
        [System.String]
        $Path,

        [parameter(mandatory = $true, Position = 1, ParameterSetName = 'Depth')]
        [System.Int32]
        $Depth
    )

    BEGIN {

        #Requires -Version 3

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Started"

    } # end BEGIN block

    PROCESS {

        if ($psCmdlet.ParameterSetName -eq 'Depth') {

            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Recursing directory structure { $Depth } layers deep, for all directories under root path { $Path }."

            try {

                # Use Get-ChildItem to recurse through the directories under the selected root path and pass the 'directory' attribute through the pipeline
                # to the select statement/hash tables and then export the data to .csv
                Get-ChildItem -Attributes Directory -Recurse $Path -Depth $Depth -ErrorAction Stop | foreach {

                    [PSCustomObject]@{
                        FullPath      = $_.FullName
                        Inheritance   = $_.getaccesscontrol().AreAccessRulesProtected
                        LastWriteTime = $_.LastWriteTime
                        Permission    = (($_.getaccesscontrol().Access) |
                                Select-Object FileSystemRights, AccessControlType, IdentityReference, IsInherited, InheritanceFlags, PropagationFlags |
                                Format-List | Out-String).Trim()
                    } # end obj

                } # end foreach

            } catch {

                Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not gather information from directory { $($_.FullName) }. $_ "

            } # end try/catch

        } else {

            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Recursing directory structure under root path { $Path }."

            try {

                # Use Get-ChildItem to recurse through the directories under the selected root path and pass the 'directory' attribute through the pipeline
                # to the select statement/hash tables and then export the data to .csv
                Get-ChildItem -Attributes Directory -Recurse $Path -ErrorAction Stop | foreach {

                    [PSCustomObject]@{
                        FullPath      = $_.FullName
                        Inheritance   = $_.getaccesscontrol().AreAccessRulesProtected
                        LastWriteTime = $_.LastWriteTime
                        Permission    = (($_.getaccesscontrol().Access) |
                                Select-Object FileSystemRights, AccessControlType, IdentityReference, IsInherited, InheritanceFlags, PropagationFlags |
                                Format-List | Out-String).Trim()
                    } # end obj

                } # end foreach

            } catch {

                Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not gather information from directory { $($_.FullName) }. $_ "

            } # end try/catch

        } # end if/else $pscmdlet

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function
