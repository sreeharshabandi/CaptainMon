$scope = New-Object System.Management.ManagementScope("\DESKTOPJ3BH2\.\root\cimV2");
$query = New-Object System.Management.WQLEventQuery("__InstanceCreationEvent",$new_process_check_interval,"TargetInstance ISA 'Win32_Process'" );
$watcher = New-Object System.Management.ManagementEventWatcher($scope,$query);

$captainmon=1;
do
{
	$NEvent = $watcher.WaitForNextEvent(); 
	$Ti = $NEvent.TargetInstance;
	Write-Host "($processSpawnCounter) New process spawned:";

	$processName=[string]$Ti.Name;
	Write-host "PID:`t`t" $Ti.ProcessId;
	Write-host "Name:`t`t" $processName;
	Write-host "PPID:`t`t" $Ti.ParentProcessID; 
	
	$parent_process=''; 
	try 
	{
		$proc=(Get-Process -id $Ti.ParentProcessID -ea stop); 
		$parent_process=$proc.ProcessName;
	} 
	catch 
	{
		$parent_process='unknown';
	}
	Write-host "Parent name:`t" $parent_process; 
	Write-host "CommandLine:`t" $Ti.CommandLine;

	if (-not ($ignoredProcesses -match $processName))
	{
		if(Suspend-Process -processID $Ti.ProcessId)
		{
			Write-Host "Process is suspended.";
		}
	}
	else
	{
		Write-Host "Error while suspending";
	}

	Write-host "";
	$Ti.processName, $Ti.ProcessId, $Ti.ParentProcessID, $parent_process | Out-File - FilePath .\Output.json

	$captainmon += 1;
} while ($true)