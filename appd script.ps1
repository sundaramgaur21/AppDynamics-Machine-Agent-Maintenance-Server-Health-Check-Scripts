# Browse for input file
Add-Type -AssemblyName System.Windows.Forms
$FileDialog = New-Object System.Windows.Forms.OpenFileDialog
$FileDialog.Filter = "Text Files (*.txt)|*.txt"
$FileDialog.ShowDialog()
$inputFile = $FileDialog.FileName

# Read server list from input file
$servers = Get-Content -Path $inputFile

# Iterate through each server
foreach ($server in $servers) {
    Write-Host "Processing server: $server"

    # Stop AppDynamics Machine Agent service
    $service = Invoke-Command -ComputerName $server -ScriptBlock {
        Stop-Service -Name "Appdynamics Machine Agent" -Force
        Get-Service -Name "Appdynamics Machine Agent"
    }
    if ($service.Status -eq "Stopped") {
        Write-Host "AppDynamics Machine Agent service stopped successfully on $server"
    } else {
        Write-Host "Failed to stop AppDynamics Machine Agent service on $server"
    }

    # Stop all PowerShell instances except the current one
    Invoke-Command -ComputerName $server -ScriptBlock {
        Get-Process | Where-Object {$_.ProcessName -eq "powershell" -and $_.Id -ne $PID} | Stop-Process -Force
    }
    Write-Host "All PowerShell instances killed on $server (except this one)"

    # Move folders
    Invoke-Command -ComputerName $server -ScriptBlock {
        $source = "C:\Program Files\AppDynamics\MachineAgent\machineagent-bundle-64bit-windows-22.3.0.3296\monitors"
        $destination = "C:\Program Files\AppDynamics\MachineAgent\machineagent-bundle-64bit-windows-22.3.0.3296"
        Move-Item -Path "$source\windowsevents-monitoring-extension-rel-1.0.0" -Destination $destination
        Move-Item -Path "$source\windowsservice-monitoring-extension-rel-1.0.0" -Destination $destination
    }
    Write-Host "Folders moved successfully on $server"

    # Start AppDynamics Machine Agent service
    $service = Invoke-Command -ComputerName $server -ScriptBlock {
        Start-Service -Name "Appdynamics Machine Agent"
        Get-Service -Name "Appdynamics Machine Agent"
    }
    if ($service.Status -eq "Running") {
        Write-Host "AppDynamics Machine Agent service started successfully on $server"
    } else {
        Write-Host "Failed to start AppDynamics Machine Agent service on $server"
    }

    # Get CPU and memory utilization
    $cpuUtil = Invoke-Command -ComputerName $server -ScriptBlock {
        (Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
    }
    $memUtil = Invoke-Command -ComputerName $server -ScriptBlock {
        (Get-Counter -Counter "\Memory\% Committed Bytes In Use" -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
    }
    Write-Host ("CPU utilization on {0}: {1}%" -f $server, $cpuUtil)
    Write-Host ("Memory utilization on {0}: {1}%" -f $server, $memUtil)

    Write-Host "Completed processing server: $server"
    Write-Host ""
}