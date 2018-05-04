function Export-Credential {
    <#
    .SYNOPSIS
        Export an encrypted PS credential to a file for later use
    .DESCRIPTION
        Export an encrypted PS credential to a file for later use.

        The password is encrypted using the .NET Data Protection API (DPAPI).

        The only way the password can be decrypted is from the account that used to encrypt it with, from the same system it was encrypted on. There are
        some situations where the machine requirement would not be required, such as if you enable roaming profiles or roaming credentials.
    .PARAMETER Path
        Path to where you wish to export the credential file to
    .PARAMETER Credential
        Credential to be saved
    .INPUTS
        System.String
        System.Management.Automation.PSCredential
    .EXAMPLE
        Export-Credential -Path C:\User123Credential.xml -Credential (Get-Credential)
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Version: 1.0
        Last Updated: 20150612
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Added to module
    #>

    [OutputType([System.String])]
    [cmdletbinding(DefaultParameterSetName = 'default')]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]$Path,

        [Parameter(Mandatory = $true, Position = 1)]
        [System.Management.Automation.PSCredential]$Credential
    )

    BEGIN {

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[Export-Credential] Exporting credential to credential file {$Path}"
        try {

            $CredentialCopy = $Credential | Select-Object *
            $CredentialCopy.Password = $CredentialCopy.Password | ConvertFrom-SecureString -ErrorAction 'Stop'
            $CredentialCopy | Export-Clixml $Path -ErrorAction 'Stop'

        } catch {

            Write-Warning -Message "[Export-Credential][ERROR] Could not export credential. $_"

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message '[Export-Credential] Processing Complete.'

    } # end END block

} # end function Export-Credential
