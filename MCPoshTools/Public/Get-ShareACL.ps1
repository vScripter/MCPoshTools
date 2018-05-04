function Get-ShareACL {

<#
.SYNOPSIS
    Returns NTFS and Share permissions for a provided UNC Path

.DESCRIPTION
    Returns NTFS and Share permissions for a provided UNC Path

    This script/function can be used to report on Share and NTFS permissions for the provided UNC path, multiple UNC paths, or a list of UNC paths.

    It requires the proper access to enumerate the shares and read all of the ACL information (typically administrative permissions are required on the remote system hosting the path)

    It uses WMI to gather share information, so SMB shares hosted on NON-windows systems will return an error.

.PARAMETER  UNCPath
    Valid UNC Path

.EXAMPLE
    PS C:> .\Get-ShareACL.ps1 -UNCPath \\servera.loc1.company.com\testshare | Format-Table -AutoSize
.EXAMPLE
    PS C:> .\Get-ShareACL.ps1 -UNCPath \\servera.loc1.company.com\testshare,\\serverb.loc1.company.com\share1$ | Out-Gridview
.EXAMPLE
    PS C:> .\Get-ShareACL.ps1 -UNCPath (Get-Content C:\UNCPathList.txt) | Export-Csv C:\ACLAudit.csv -NoTypeInformation -Force
.INPUTS
    System.String
.NOTES
    --------------------------------
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20141017
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Added to module
#>

    [cmdletbinding(DefaultParameterSetName = 'default')]
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [validatescript({ Test-Path $_ -PathType Container })]
        [string[]]$UNCPath
    )

    BEGIN {

        #Requires -Version 3

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Started"

    } # BEGIN


    PROCESS {

        foreach ($Path in $UNCPath){

            try    {

                $pathparts    = $path.split("\")
                $ComputerName = $pathparts[2]
                $ShareName    = $pathparts[3]

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Gathering NTFS Permissions"

                $acl = Get-Acl $path -ErrorAction Stop

                foreach ($accessRule in $acl.Access) {

                    [PSCustomObject] @{
                        ComputerName = $ComputerName
                        ACLType      = "NTFS"
                        ShareName    = $ShareName
                        Account      = $accessRule.IdentityReference
                        Permission   = $accessRule.FileSystemRights
                    } # obj

                } # foreach

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Gathering SMB/Share Permissions"

                $Share = Get-WmiObject win32_LogicalShareSecuritySetting -Filter "name='$ShareName'" -ComputerName $ComputerName -ErrorAction Stop

                if ($Share)    {

                    $ACLS = $Share.GetSecurityDescriptor().Descriptor.DACL

                    foreach ($ACL in $ACLS) {

                        $User = $ACL.Trustee.Name

                        if (!($user)) {
                            $user = $ACL.Trustee.SID
                        } # end if

                        $Domain = $ACL.Trustee.Domain

                        switch ($ACL.AccessMask) {
                            2032127 { $Perm = "Full Control" }
                            1245631 { $Perm = "Change" }
                            1179817 { $Perm = "Read" }
                        } # switch

                        $ntUser = "$Domain\$user"

                        [PSCustomObject] @{
                            ComputerName = $ComputerName
                            ACLType      = "SMB"
                            Account      = $ntUser
                            Permission   = $Perm
                        } # obj

                    } # end foreach $ACL

                } # end if $Share

            } catch {

                Write-Warning -Message "Error getting info from $Path"

            } # end try/catch

        } # end foreach $path

    }# PROCESS

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # END

} # end function
