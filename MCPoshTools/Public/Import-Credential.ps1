function Import-Credential {
    <#
    .SYNOPSIS
        Import an encrypted PS credential for use
    .DESCRIPTION
        Import an encrypted PS credential for use

    .PARAMETER Path
        Path to where you wish to import the credential file from
    .INPUTS
        System.String
    .EXAMPLE
        Import-Credential -Path C:\User123Credential.xml
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Version: 1.0
        Last Updated: 20150612
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Added to module
    #>

    [cmdletbinding(DefaultParameterSetName = 'default')]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [System.String]$Path
    )

    BEGIN {

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[Import-Credential] Importing credential from credential file {$Path}"
        try {

            $CredentialCopy = Import-Clixml $path -ErrorAction 'Stop'
            $CredentialCopy.password = $CredentialCopy.Password | ConvertTo-SecureString -ErrorAction 'Stop'
            New-Object System.Management.Automation.PSCredential($CredentialCopy.username, $CredentialCopy.password)

        } catch {

            Write-Warning -Message "[Import-Credential][ERROR] Could not import credential. $_"

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message '[Import-Credential] Processing Complete.'

    } # end END block

} # end function Import-Credential
