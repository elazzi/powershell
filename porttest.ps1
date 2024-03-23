Workflow Test-WF{
    param([string[]]$iprange)
	
	[int32[]]$arrayofports = 80,8080,443

    foreach -parallel($ip in $iprange)
    {	foreach -parallel($port in $arrayofports)
    {
        #"testing: $ip"
		Test-Port $ip $port

    }}
}

function Test-Port
{
		Param( [string]$srv,[int]$port=80,[int]$timeout=300)
		# Test-Port.ps1
		# Does a TCP connection on specified port (135 by default)

		$ErrorActionPreference = "SilentlyContinue"
		$verbose=[bool]::Parse('false')
		# Create TCP Client
		$tcpclient = new-Object system.Net.Sockets.TcpClient

		# Tell TCP Client to connect to machine on Port
		$iar = $tcpclient.BeginConnect($srv,$port,$null,$null)

		# Set the wait time
		$wait = $iar.AsyncWaitHandle.WaitOne($timeout,$false)

		# Check to see if the connection is done
		if(!$wait)
		{
			# Close the connection and report timeout
			$tcpclient.Close()
			if($verbose){Write-Host "testing: $srv port $port failed "}
			$failed = $true
			#Return $false
		}
		else
		{
			# Close the connection and report the error if there is one
			$error.Clear()
			$tcpclient.EndConnect($iar) | out-Null
			if(!$?){if($verbose){write-host $error[0]};$failed = $true}
			$tcpclient.Close()
		}

		# Return $true if connection Establish else $False
		if($failed){
			#"testing: $srv port $port failed "
			#return $false
			}
		else{
			"testing: $srv port $port open "
		$url = "http://${srv}:${port}"
		$result = Invoke-WebRequest -Method HEAD -Uri $url -UseBasicParsing
		$result.RawContent

		$result.Headers
			return $true 
			}

}
Test-WF -iprange (1..254 | % {"192.168.50."+$_})
