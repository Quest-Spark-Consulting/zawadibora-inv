$appDir = "C:\Users\USER\OneDrive\Desktop\Sunday\inventory_live"
$logFile = "$appDir\restart.log"
$python = "python"

function Write-Log {
    param([string]$msg)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time $msg" | Out-File -FilePath $logFile -Encoding utf8 -Append
}

Write-Log "Starting inventory server monitor..."

while ($true) {
    $proc = Get-Process -Name python -ErrorAction SilentlyContinue | Where-Object {
        try { $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine; $cmd -match 'app.py' } catch { $false }
    }
    if (-not $proc) {
        Write-Log "Server not running. Starting..."
        Start-Process -FilePath $python -ArgumentList "app.py" -WorkingDirectory $appDir -WindowStyle Hidden
        Write-Log "Server started. PID: $((Get-Process -Name python | Select-Object -Last 1).Id)"
    }
    Start-Sleep -Seconds 15
}
