# --- Configuration ---
# Hardcoded download URL and local file name
$DownloadUrl = "https://github.com/NetKillX/netkillx.github.io/releases/download/2.0/main.exe"
$FileName    = "main.exe"
# ---------------------

# The entire logic is wrapped in a self-invoking script block (& { ... }) for clean execution.
& {
    $TempDir = "$env:TEMP"
    # Local path for the cached executable
    $ExePath = Join-Path -Path $TempDir -ChildPath $FileName
    $ExitCode = 0
    
    Write-Host "Local cache path: $ExePath" -ForegroundColor DarkGray
    
    # --- Caching and Download Logic ---
    if (Test-Path $ExePath) {
        Write-Host "✅ Found cached file: $FileName. Skipping download." -ForegroundColor Green
    }
    else {
        # File not found, proceed with download
        $WebClient = New-Object System.Net.WebClient
        
        Write-Host "Starting download from $DownloadUrl..." -ForegroundColor Cyan

        try {
            # FIX: Correct type name is [Net.SecurityProtocolType]
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
            
            # Download the file
            $WebClient.DownloadFile($DownloadUrl, $ExePath)
            Write-Host "Download complete. File saved to: $ExePath" -ForegroundColor Green
        }
        catch {
            Write-Host "An error occurred during download: $($_.Exception.Message)" -ForegroundColor Red
            # Exit the script block on download failure
            return 
        }
    }

    # --- Execution Logic ---
    if (Test-Path $ExePath) {
        Write-Host "Executing $FileName in the current terminal..." -ForegroundColor Yellow
        
        try {
            # Use the call operator (&) to execute the file
            & $ExePath
            $ExitCode = $LASTEXITCODE
            Write-Host "Program execution finished. Exit Code: $ExitCode" -ForegroundColor Green
        }
        catch {
            Write-Host "An error occurred during execution: $($_.Exception.Message)" -ForegroundColor Red
            $ExitCode = 1
        }
    }
    else {
        Write-Host "Cannot execute. The file was not found locally." -ForegroundColor Red
        $ExitCode = 1
    }

    # Return the program's exit code to the shell
    exit $ExitCode
}
