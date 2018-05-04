function Get-VMToolsBuildToVersionMapping {

<#
.SYNOPSIS
    Get VMware's installed guest toolset (VMware Tools) build-to-version mapping information from VMware's provided mapping file using Invoke-WebRequest
.DESCRIPTION
    This function will return build and version information that will help correlate the two when querying for VMware Tools versions and builds.
    For example, if you are looking at the version of VM Tools within a particular guest OS, that is going to differ from what is returned from a query from PowerCLI.
    You can use the build/version map to make that correlation, and even automate the reference to your liking.
.PARAMETER File
    Path and name of file you wish to save the information to
.PARAMETER URI
    Web URI where the VMware provided build sheet is located
.INPUTS
    System.String
.OUTPUTS
    System.Management.Automation.PSCustomObject
.EXAMPLE
    Get-VMToolsBuildToVersionMapping -Verbose | Format-Table -AutoSize

VIVersion ESXiServerVersion GuestToolsVersion ESXiBuildNumber
--------- ----------------- ----------------- ---------------
9354      esx/5.5ep05       9.4.10            2143827
9354      esx/5.5p03        9.4.10            2143827
9354      esx/5.5u2         9.4.10            2068190
9350      esx/5.5p02        9.4.6             1892794
9349      esx/5.5ep04       9.4.5             1881737
9349      esx/5.5ep03       9.4.5             1746974
9349      esx/5.5ep02       9.4.5             1750340
9349      esx/5.5u1         9.4.5             1623387
9344      esx/5.5p01        9.4.0             1474528
9344      esx/5.5           9.4.0             1331820
9231      esx/5.1u3         9.0.15            2323236
9229      esx/5.1p06        9.0.13            2126665
9228      esx/5.1p05        9.0.12            1897911
9227      esx/5.1ep05       9.0.11            1900470
9227      esx/5.1p04        9.0.11            1743533
9226      esx/5.1ep04       9.0.10            1612806
9226      esx/5.1u2         9.0.10            1483097
9221      esx/5.1p03        9.0.5             1312873
9221      esx/5.1p02        9.0.5             1157734
....[Truncated for example]....
.EXAMPLE
    Get-VMToolsBuildToVersionMapping -Verbose | Where-Object { $_.VIVersion -eq 9354 } | Format-Table -AutoSize
.NOTES
    Author: Kevin Kirkpatrick
    Email: See About_MCPoshTools for contact information
    Last Updated: 20161211
    Last Updated By: K. Kirkpatrick
    Last Update Notes:
    - Fixed some parsing syntax to ensure file header comments are skipped, regardless if the number of lines changes
    - Improved syntax coverage
    - Updated Verbose messaging
    - Udpate CBH
    - Removed saving PSCustomObject to variable and then calling variable; now spews straight to pipeline
    -

#>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param (
        [parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'default')]
        [validatescript({ (Invoke-WebRequest -Uri $_).StatusCode -eq 200 })]
        [System.String]
        $URI = 'http://packages.vmware.com/tools/versions',

        [parameter(
            Mandatory = $false,
            Position = 1,
            ParameterSetName = 'default')]
        [validatescript({ Test-Path -LiteralPath (Split-Path -LiteralPath $_) -PathType Container })]
        [System.String]
        $ExportFile = "$ENV:TEMP\vmToolsBVMap.txt"
    )

    BEGIN {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Exporting source data from URI { $URI }"
        try {

            Invoke-RestMethod -Method Get -Uri $URI -ErrorAction 'Stop' | Out-File $ExportFile -Encoding utf8 -ErrorAction 'Stop' -Force

        } catch {

            throw "[$(PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not export source data from URI { $URI }. $_"

        } # end try/catch

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Reading data from file { $ExportFile }"
        try {

            $vmToolsBVMap = Get-Content $ExportFile -ErrorAction 'Stop' | Where-Object {$_ -notlike '#*'}

        } catch {

            throw "[$(PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not import data from file { $ExportFile }"

        } # end try/catch

    } # end END block

    PROCESS {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Parsing content"

        foreach ($line in $vmToolsBVMap) {

            $splitLine = $line -split '\s+'

            [PSCustomObject] @{
                VIVersion         = $splitLine[0]
                ESXiServerVersion = $splitLine[1]
                GuestToolsVersion = $splitLine[2]
                ESXiBuildNumber   = $splitLine[3]
            } # end [PSCustomObject]

        } # end foreach $line

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-VMToolsBuildToVersionMapping
