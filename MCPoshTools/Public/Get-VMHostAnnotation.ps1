function Get-VMHostAnnotation {

<#
    .SYNOPSIS
        Get the annotation fields and their values for a VMHost
    .DESCRIPTION
        Get the annotation fields and their values for a VMHost

        A vCenter server does not need to be provided; it is extacted from input data and used where necessary to maximize processing time.
    .PARAMETER  Name
        Proper VMware VMHost object. See Inputs
    .EXAMPLE
        Get-VMHostAnnotation -Name (Get-VMHost -Name esxi01.corp.com)
    .EXAMPLE
        Get-VMHost esxi01,esxi02 | Get-VMHostAnnotation | Out-GridView
    .EXAMPLE
        Get-VMHostAnnotation -Name (Get-VMHost esxi01,esxi02 | Get-View) | Out-GridView
    .INPUTS
        VMware.Vim.HostSystem
        VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20161207
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Minor formatting changes
        - Added [OutputType()] & Strict Mode declarations
#>

    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding(DefaultParameterSetName = 'default')]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            ParameterSetName = 'default')]
        [alias('VMHost')]
        $Name
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Validating input type"
        $inputTypeCheck = $null
        $inputTypeCheck = $Name.GetType().FullName

        if (-not ($inputTypeCheck -eq 'VMware.Vim.HostSystem' -or $inputTypeCheck -eq 'VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl')) {

            Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Input type is not correct. $_ "
            break

        } # end if

        switch ($inputTypeCheck) {

            'VMware.Vim.HostSystem' {

                foreach ($vmHostSystem in $Name) {

                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Gathering annotation detail for VMHost { $($vmHostSystem.Name) }"
                    try {

                        $values = $null
                        $keys = $null

                        $values = $vmHostSystem.Value
                        $keys = $vmHostSystem.AvailableField

                        foreach ($k in $keys) {

                            $obj = @()
                            $obj = [PSCustomObject] @{
                                VM = $vmHostSystem.Name
                                CustomAttribute = $k.Name
                                Value = ($values | Where-Object { $k.key -eq $_.key }).Value
                            }
                            $obj

                        } # end foreach

                    } catch {

                        Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not gather View data from VMHost { $($vmHostSystem.Name) }. $_ "
                        continue

                    } # end try/catch

                } # end foreach $guest


            } # end 'VMware.Vim.HostSystem'



            'VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl' {

                foreach ($vmHostSystem in $Name) {

                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Gathering annotation detail for VMHost { $($vmHostSystem.Name) }"
                    try {

                        $vmHostVcenter = $null
                        $vmHostView = $null
                        $values = $null
                        $keys = $null

                        $vmHostVcenter = ($vmHostSystem.uid.split('@')[1]).Split(':')[0]
                        $vmHostView = Get-View -Server $vmHostVcenter -ViewType HostSystem -Property Name, Value, AvailableField -Filter @{ 'Name' = "$($vmHostSystem.Name)" } -ErrorAction 'Stop'

                        $values = $vmHostView.Value
                        $keys = $vmHostView.AvailableField

                        foreach ($k in $keys) {

                            $obj = @()
                            $obj = [PSCustomObject] @{
                                VM = $vmHostSystem.Name
                                CustomAttribute = $k.Name
                                Value = ($values | Where-Object { $k.key -eq $_.key }).Value
                            }
                            $obj

                        } # end foreach

                    } catch {

                        Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not gather View data from VMHost { $($vmHostSystem.Name) }. $_ "
                        continue

                    } # end try/catch

                } # end foreach $guest

            } # end 'VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl'

        } # end switch



    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-VMHostAnnotation
