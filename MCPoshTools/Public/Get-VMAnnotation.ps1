function Get-VMAnnotation {

<#
    .SYNOPSIS
        Get the annotation fields and their values for a virtual machine
    .DESCRIPTION
        Get the annotation fields and their values for a virtual machine.

        This function also returns any information in the 'Notes' field, as a seperate property.

        A vCenter server does not need to be provided; it is extacted from input data and used where necessary to maximize processing time.
    .PARAMETER  Name
        Proper VMware virtual machine object. See Inputs
    .EXAMPLE
        Get-VM server01,server02 | Get-VMAnnotation | Out-GridView
    .EXAMPLE
        Get-VMAnnotation -Name (Get-VM server01,server02) | Out-GridView
    .INPUTS
        VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    .NOTES
        Author: Kevin Kirkpatrick
        Email: See About_MCPoshTools for contact information
        Last Updated: 20161207
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Removed all code that tried to calculate the input TypeName
        - Only supports input from Get-VM
        - Removed adding object data to a variable; all output now goes stright to the pipeline
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
        [alias('VM')]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $Name
    )

    BEGIN {

        #Requires -Version 3
        Set-StrictMode -Version Latest

    } # end BEGIN block

    PROCESS {

        foreach ($guest in $Name) {

            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Gathering annotation detail for VM { $($guest.Name) }"
            try {

                $guestVcenter = $null
                $guestView    = $null
                $values       = $null
                $keys         = $null

                $guestVcenter = ($guest.uid.split('@')[1]).Split(':')[0]
                #$guestView   = Get-View -Server $guestVcenter -ViewType VirtualMachine -Property Name, Value, AvailableField, Summary -Filter @{ 'Name' = "$($guest.Name)" } -ErrorAction 'Stop'
                $guestView    = $guest.ExtensionData
                $values       = $guestView.Value
                $keys         = $guestView.AvailableField

                foreach ($k in $keys) {

                   [PSCustomObject] @{
                        VM              = $guest.Name
                        CustomAttribute = $k.Name
                        Value           = ($values | Where-Object { $k.key -eq $_.key }).Value
                    } # end [PSCustomObject]

                } # end foreach

                # add notes field as a custom attribute; add to array
                [PSCustomObject] @{
                    VM              = $guest.Name
                    CustomAttribute = 'Notes'
                    Value           = $guestView.Summary.Config.Annotation
                } # end [PSCustomObject]

            } catch {

                Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not gather data from VM { $($guest.Name) }. $_ "

            } # end try/catch

        } # end foreach $guest

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete"

    } # end END block

} # end function Get-VMAnnotation
