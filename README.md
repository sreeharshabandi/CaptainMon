# CaptainMon
CaptainMon! - Process Spawning tool.
This tool can be used to spwan the newly created processes and gives an option to either Suspend or Resume it, during analysing of a Malware sample. Built using WMI EventWatcher.


In this post we will be looking at my recent develpment on <strong>Windows Process Spawning using [CaptainMon][linktocaptainmon].</strong>

<strong>Prior knowledge on the following topics are required:</strong>
1. <code class="highlighter-rouge">Windows Management Instumentation.</code>
2. <code class="highlighter-rouge">WQLEventQuery.</code>
3. <code class="highlighter-rouge">ManagementScope.</code>

```c#
if(fail to have the above required knowledge)
{
    Write-host "Don't worry, you can learn that in this post:";
}
```

<p><strong><code class="highlighter-rouge">Windows Management Instrumentation:</code></strong></p>

<p>Windows Management Instrumentation (WMI) is the infrastructure for management data and operations on Windows-based operating systems. You can use WMI from client applications and scripts. It provides an infrastructure that makes it easy to both discover and perform management tasks. In addition, you can add to the set of possible management tasks by creating your own WMI providers.</P>

![alt text](https://github.com/sreeharshabandi/images/blob/main/wmi.jpg)

<p><strong><code class="highlighter-rouge">WQLEventQuery:</code></strong></p>

<p>Represents a WMI event query in WQL format. Following Constructor related to WQLEventQuery is used in CaptainMon.</P>

<code class="highlighter-rouge">WqlEventQuery(String, String, TimeSpan):</code> This initializes a new instance of the WqlEventQuery class with the specified event class name, condition, and grouping interval.

<p>Following implementation is made in CaptainMon for defining an Event Query object in powershell:</P>

```c#
$query = New-Object System.Management.WQLEventQuery("__InstanceCreationEvent",$new_process_check_interval,"TargetInstance ISA 'Win32_Process'" );
```
Implementation of the same in c# is shown below:

```c#
WqlEventQuery query = new WqlEventQuery("__InstanceCreationEvent", new TimeSpan(0,0,1), "TargetInstance isa \"Win32_Process\"");
```
Note: WMI-query in-c# does not work on non-english machine.

<p><strong><code class="highlighter-rouge">ManagementScope:</code></strong></p>

<p>Represents a scope (namespace) for management operations. Used to make a connection to a remote computer, following Constructor related to ManagementScope is used in CaptainMon.</p>

<code class="highlighter-rouge">ManagementScope(ManagementPath):</code> This initializes a new instance of the ManagementScope class representing the specified scope path.

<p>Implemention of ManagementScope() object in CaptainMon:</P>

```c#
$scope = New-Object System.Management.ManagementScope("\DESKTOPJ3BH2\.\root\cimV2");
```

Implementation of the same in c# is shown below:

```C#
ManagementScope scope =
            new ManagementScope(
            "\\\\FullComputerName\\root\\cimv2");
```

<p>Summing up the Object implementation together by including the Culture in Powershell:</P>

```c#
$scope = New-Object System.Management.ManagementScope("\DESKTOPJ3BH2\.\root\cimV2");
$query = New-Object System.Management.WQLEventQuery("__InstanceCreationEvent",$new_process_check_interval,"TargetInstance ISA 'Win32_Process'" );
$watcher = New-Object System.Management.ManagementEventWatcher($scope,$query);
```

<p>Now Spawning the new processes repetedly by incrementing the counter and using a Sychronous call for the watcher:</p>

```c#
$scope = New-Object System.Management.ManagementScope("\DESKTOPJ3BH2\.\root\cimV2");
$query = New-Object System.Management.WQLEventQuery("__InstanceCreationEvent",$new_process_check_interval,"TargetInstance ISA 'Win32_Process'" );
$watcher = New-Object System.Management.ManagementEventWatcher($scope,$query);

$capatainmon=1;
do
{
    captainmon += 1;
}
while($true)
```
<p>Now Spawning the newly arrived event:</p>

```c#
$NEvent = $watcher.WaitForNextEvent();
$Ti = $NEvent.TargetInstance;
$processName=[string]$Ti.Name;
```
<p>Writing Parent_Process to the host:</p>

```c#
$parent_process=''; 
	try 
	{
		$proc=(Get-Process -id $Ti.ParentProcessID -ea stop); 
		$parent_process=$proc.ProcessName;
	} 
	catch 
	{
		$parent_process='Unknown';
	}
```
<p><strong><code class="highlighter-rouge">Suspending the Process:</code></strong></p>

```c#
function Sp($processID) {
	if(($pProc -ne [IntPtr]::Zero){
		Write-Host "Trying to suspend process: $processID"

		$result = Sp($pProc)
		if($result -ne 0) {
			Write-Error "Failed to suspend. SuspendProcess returned: $result"
			return $False
		}
		CloseHandle($pProc) | out-null;
	} else {
		Write-Error "Unable to open process. Not elevated? Process doesn't exist anymore?"
		return $False
	}
	return $True
}
if (-not ($ignoredProcesses -match $processName))
	{
		if(Suspend-Process -processID $Ti.ProcessId)
		{
			Write-Host "Process is suspended";
		}
	}
```
<p><strong><code class="highlighter-rouge">Resuming the Process:</code></strong></p>

```c#
function Rp($processID) {
	if(($pProc -ne [IntPtr]::Zero){
		Write-Host "Trying to resume process: $processID"
		Write-Host ""
		$result = Rp($pProc)
		if($result -ne 0) {
			Write-Error "Failed to resume. ResumeProcess returned: $result"
		}
		[Threader]::CloseHandle($pProc) | out-null
	} else {
		Write-Error "Unable to open process. Process doesn't exist anymore?"
	}
}
```

<p>Finally writing the output to the host:</p>

```c#
Write-host "";
	$Ti.processName, $Ti.ProcessId, $Ti.ParentProcessID, $parent_process | Out-File - FilePath .\Output.json
```

<p><strong>Thanks For Reading!</strong></p>

[linktocaptainmon]: https://github.com/sreeharshabandi/CaptainMon
