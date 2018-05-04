$parentPath        = Split-Path $PSScriptRoot -Parent
$projectPath       = Split-Path $parentPath -Parent
$moduleName        = Split-Path $projectPath -Leaf
$publicCommandPath = "$projectPath\$moduleName\Public"
$scriptName        = ($MyInvocation.MyCommand.Name) -Replace ".Tests",""
$scriptPath        = Join-Path $publicCommandPath $scriptName
$commandName       = ($scriptName).Split('.')[0]

. $scriptPath

describe "Unit Tests for command { $commandName }" -Tags "Unit","Non-PowerCLI" {

    it 'Returns a PSCustomObject' {
        $uptime = Get-Uptime
        $uptime.GetType().FullName | should be 'System.Management.Automation.PSCustomObject'
    }

    it 'Returns a value'{
        $uptime = Get-Uptime -ErrorAction 'SilentlyContinue'
        $uptime.ComputerName  | should not beNullOrEmpty
        $uptime.UptimeDays    | should not beNullOrEmpty
        $uptime.UptimeHours   | should not beNullOrEmpty
        $uptime.UptimeMinutes | should not beNullOrEmpty
        $uptime.UptimeSeconds | should not beNullOrEmpty
    }

} # end context "Unit Tests for command { $commandName }"