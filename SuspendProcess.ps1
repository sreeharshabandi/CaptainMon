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