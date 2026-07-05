AppDynamics Machine Agent Maintenance & Server Health Check Scripts
------------------------------------------------------------------
PowerShell scripts for managing AppDynamics Machine Agent monitoring extension folders and validating CPU/memory utilization across multiple Windows servers.


Overview
--------
This repository contains two PowerShell scripts designed to support Windows server administration and AppDynamics Machine Agent maintenance activities.
The first script performs a controlled maintenance operation on multiple remote servers by stopping the AppDynamics Machine Agent service, moving specific monitoring extension folders out of the monitors directory, restarting the service, and then checking CPU and memory utilization.
The second script is a lightweight server health check utility that only collects CPU and memory utilization from a list of remote Windows servers.
These scripts are useful for infrastructure teams managing AppDynamics agents across multiple servers during maintenance, troubleshooting, migration, or monitoring configuration cleanup activities.

Scripts Included
-----------------
1. AppDynamics Machine Agent Maintenance Script
This script performs the following actions on each server from the input list:

Reads server names from a .txt file
Connects to each server using PowerShell Remoting
Stops the AppDynamics Machine Agent service
Kills existing PowerShell processes on the remote server except the current session
Moves AppDynamics monitoring extension folders from the monitors directory to the main Machine Agent bundle directory
Starts the AppDynamics Machine Agent service again
Validates whether the service is running
Captures CPU utilization
Captures memory utilization
Displays progress and status for each server


2. CPU and Memory Utilization Check Script
This script performs a basic health check across multiple servers.
It reads server names from a .txt file and collects:

CPU utilization
Memory utilization

This is useful when you only want to validate current resource usage without making any service or folder changes on the target servers.

Features
-----------
✅ Graphical file picker for selecting server list
✅ Bulk processing of multiple Windows servers
✅ Remote execution using PowerShell Remoting
✅ AppDynamics Machine Agent service stop/start operation
✅ Monitoring extension folder movement
✅ Remote PowerShell process cleanup
✅ CPU utilization check
✅ Memory utilization check
✅ Console-based progress reporting
✅ Simple server health validation

Prerequisites
--------------
Before running these scripts, ensure the following requirements are met.
Administrator Access
Run PowerShell as Administrator.
The account executing the script should have administrative permissions on the target servers.

PowerShell Remoting Enabled
PowerShell Remoting must be enabled on all target servers.
You can enable it using:
PowerShellEnable-PSRemoting -ForceShow more lines

Network Connectivity
The machine running the script must be able to connect to the target servers over WinRM.
The target servers should be reachable by hostname.

Required Service
The maintenance script expects the following service to exist on the remote servers:
Plain TextAppdynamics Machine AgentShow more lines
If the service name is different in your environment, update the script accordingly.

Expected AppDynamics Path
The maintenance script uses the following AppDynamics Machine Agent path:
Plain TextC:\Program Files\AppDynamics\MachineAgent\machineagent-bundle-64bit-windows-22.3.0.3296`Show more lines
The script moves these folders:
Plain Textwindowsevents-monitoring-extension-rel-1.0.0windowsservice-monitoring-extension-rel-1.0.0Show more lines
From:
Plain TextC:\Program Files\AppDynamics\MachineAgent\machineagent-bundle-64bit-windows-22.3.0.3296\monitorsShow more lines
To:
Plain TextC:\Program Files\AppDynamics\MachineAgent\machineagent-bundle-64bit-windows-22.3.0.3296Show more lines
If your AppDynamics version or folder structure is different, update the source and destination paths before running the script.

Server List Format
Create a text file with one server name per line.
Example:
Plain TextSERVER01SERVER02SERVER03SERVER04SERVER05Show more lines
Save the file as:
Plain TextServers.txtShow more lines
When the script runs, it opens a file browser window where you can select this file.

How the Maintenance Script Works
--------------------------------
Step 1 – Select Server List
The script launches a graphical file picker.
Select the .txt file containing the list of servers.

Step 2 – Process Each Server
The script loops through each server in the file.
Example output:
Plain TextProcessing server: SERVER01Show more lines

Step 3 – Stop AppDynamics Machine Agent Service
The script remotely stops the service:
PowerShellStop-Service -Name "Appdynamics Machine Agent" -ForceShow more lines
It then validates the service status.
Example successful output:
Plain TextAppDynamics Machine Agent service stopped successfully on SERVER01Show more lines
If the service does not stop successfully, the script displays:
Plain TextFailed to stop AppDynamics Machine Agent service on SERVER01Show more lines

Step 4 – Stop Other PowerShell Processes
The script stops other PowerShell processes running on the remote server, except the current session.
PowerShellGet-Process | Where-Object {$_.ProcessName -eq "powershell" -and $_.Id -ne $PID} | Stop-Process -ForceShow more lines
Example output:
Plain TextAll PowerShell instances killed on SERVER01 (except this one)Show more lines

Step 5 – Move AppDynamics Monitoring Extension Folders
The script moves the following extension folders out of the monitors directory:
Plain Textwindowsevents-monitoring-extension-rel-1.0.0windowsservice-monitoring-extension-rel-1.0.0Show more lines
Example output:
Plain TextFolders moved successfully on SERVER01Show more lines

Step 6 – Restart AppDynamics Machine Agent Service
The script starts the service again:
PowerShellStart-Service -Name "Appdynamics Machine Agent"Show more lines
It then validates whether the service is running.
Example successful output:
Plain TextAppDynamics Machine Agent service started successfully on SERVER01Show more lines

Step 7 – Capture CPU and Memory Utilization
After completing the maintenance activity, the script captures server resource utilization.
CPU utilization is collected using:
PowerShell\Processor(_Total)\% Processor TimeShow more lines
Memory utilization is collected using:
PowerShell\Memory\% Committed Bytes In UseShow more lines
Example output:
Plain TextCPU utilization on SERVER01: 12.3456%Memory utilization on SERVER01: 65.4321%Show more lines

Step 8 – Completion Message
After processing each server, the script displays:
Plain TextCompleted processing server: SERVER01Show more lines

How the Health Check Script Works
-----------------------------------
The second script is used only for checking CPU and memory utilization.
It does not stop services, move folders, or modify the server.
Step 1 – Select Server List
A graphical file picker opens.
Select the text file containing the server names.

Step 2 – Collect CPU Utilization
The script collects CPU usage from each remote server.
Example:
Plain TextCPU utilization on SERVER01: 18.245%Show more lines

Step 3 – Collect Memory Utilization
The script collects memory usage from each remote server.
Example:
Plain TextMemory utilization on SERVER01: 72.354%Show more lines

Step 4 – Display Completion Status
Example:
Plain TextCompleted processing server: SERVER01Show more lines

Usage
Clone the Repository
PowerShellgit clone https://github.com/sundaramgaur21/AppDynamics-Agent-Maintenance-and-HealthCheck.gitShow more lines

Run the AppDynamics Maintenance Script
Use this script when you need to stop the AppDynamics Machine Agent service, move monitoring extension folders, restart the service, and validate server utilization.
PowerShell.\AppDynamics-Agent-Maintenance.ps1Show more lines

Run the CPU and Memory Health Check Script
Use this script when you only want to check CPU and memory utilization.
PowerShell.\Server-CPU-Memory-HealthCheck.ps1Show more lines

Example Maintenance Output
Plain TextProcessing server: SERVER01AppDynamics Machine Agent service stopped successfully on SERVER01All PowerShell instances killed on SERVER01 (except this one)Folders moved successfully on SERVER01AppDynamics Machine Agent service started successfully on SERVER01CPU utilization on SERVER01: 10.45%Memory utilization on SERVER01: 61.22%Completed processing server: SERVER01Show more lines

Example Health Check Output
Plain TextProcessing server: SERVER01CPU utilization on SERVER01: 15.87%Memory utilization on SERVER01: 70.14%Completed processing server: SERVER01Show more lines

Recommended Workflow
For AppDynamics Machine Agent maintenance:

Prepare a server list in .txt format.
Run the maintenance script from an elevated PowerShell window.
Select the server list file.
Monitor console output for each server.
Confirm the AppDynamics Machine Agent service restarts successfully.
Review CPU and memory utilization after the change.
Investigate any server showing service failure or high resource usage.

For basic server health validation:

Prepare a server list.
Run the CPU/memory health check script.
Select the server list file.
Review utilization output for each server.


Important Notes
-----------------
The maintenance script makes changes on remote servers.
Validate the AppDynamics installation path before running.
Confirm the service name matches your environment.
Test on a small set of non-production servers before running at scale.
Ensure proper change approval is in place before using this in production.
The health check script is read-only and does not modify server configuration.


Limitations
------------
Scripts rely on PowerShell Remoting.
Scripts assume the same AppDynamics installation path exists on all servers.
Scripts do not currently export results to CSV or Excel.
Scripts do not include retry logic.
Scripts do not currently handle missing folders gracefully.
Scripts do not include detailed error logging.
CPU and memory values are displayed in console only.


Future Enhancements
----------------------
Potential improvements include:

Export results to CSV
Add timestamped log file
Add error handling with try/catch blocks
Add folder existence validation before moving folders
Add service existence validation
Add retry logic for failed remote connections
Add parallel processing for faster execution
Add email report after completion
Add HTML report output
Add parameter-based execution instead of file picker only

Author
-------
Sundaram Gaur
Senior Systems Engineer | Windows Server | PowerShell Automation | Infrastructure Operations

Disclaimer
-----------
These scripts are intended for authorized administrative use only. The AppDynamics maintenance script modifies remote server configuration by stopping services and moving folders. Review the script carefully, validate all paths, and test thoroughly before running in production environments.
