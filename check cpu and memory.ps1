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

    # Get CPU and memory utilization
    $cpuUtil = Invoke-Command -ComputerName $server -ScriptBlock {
        (Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
    }
    $memUtil = Invoke-Command -ComputerName $server -ScriptBlock {
        (Get-Counter -Counter "\Memory\% Committed Bytes In Use" -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
    }

    # Display results
    Write-Host ("CPU utilization on {0}: {1}%" -f $server, $cpuUtil)
    Write-Host ("Memory utilization on {0}: {1}%" -f $server, $memUtil)

    Write-Host "Completed processing server: $server"
    Write-Host ""
}