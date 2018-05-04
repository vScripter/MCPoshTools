function Get-DecryptedSecureString {

<#
    .SYNOPSIS
        Attempt to quickly decrypt a secure string
    .DESCRIPTION
        Attempt to quickly decrypt a secure string.

        This function assumes that you are attempting to decrypt a secure string from the account & computer that was used to
        encrypt it, using the .NET Data-Protection API (DPAPI).

    .PARAMETER  SecureString
        Secure string object to decrypt
    .EXAMPLE
        $Cred = Get-Credential
        PS C:\> Get-DecryptedSecureString -SecureString $Cred.Password

    .INPUTS
        System.Security.SecureString
    .OUTPUTS
        System.String
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Version: 1.1
        Last Updated: 20161205
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Added [OutputType()]
        - Added default param set name
#>
    [OutputType([System.String])]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Default')]
        [System.Security.SecureString]$SecureString
    )

    BEGIN {

        #Requires -Version 3

        # setting EA pref global since we are working with raw .NET code
        $ErrorActionPreference = 'Stop'

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[Get-DecryptedSecureString] Attempting to Decrypt input"
        try {

            $plainText = $null

            # decrypt secure string. Method referenced from: https://github.com/PoshCode/PowerShellPracticeAndStyle/blob/master/Best%20Practices/Security.md
            $BSTR      = [System.Runtime.InteropServices.marshal]::SecureStringToBSTR($SecureString)
            $plainText = [System.Runtime.InteropServices.marshal]::PtrToStringAuto($BSTR); [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
            $plaintext

        } catch {

            Write-Warning -Message "[Get-DecryptedSecureString][ERROR] Could not decrypt input. $_ "

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[Get-DecryptedSecureString] Processing Complete"

    } # end END block

} # end function Get-DecryptedSecureString
