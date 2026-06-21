# Download and install Flutter SDK on Windows
# Run as: powershell -ExecutionPolicy Bypass -File .\install_flutter.ps1

param(
    [string]$InstallPath    = "C:\flutter",
    [string]$FlutterVersion = "3.32.2"
)

$ErrorActionPreference = "Stop"
$ProgressPreference    = "SilentlyContinue"

function Write-Step($msg) { Write-Host "`n[STEP] $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[  OK] $msg" -ForegroundColor Green }
function Write-WARN($msg) { Write-Host "[ WARN] $msg" -ForegroundColor Yellow }
function Write-FAIL($msg) { Write-Host "[ FAIL] $msg" -ForegroundColor Red; exit 1 }

# Step 1: Check existing installation
Write-Step "Checking existing Flutter installation..."
if (Test-Path "$InstallPath\bin\flutter.bat") {
    Write-OK "Flutter already found at $InstallPath"
    & "$InstallPath\bin\flutter.bat" --version
    exit 0
}

# Step 2: Download
Write-Step "Downloading Flutter $FlutterVersion SDK..."
$zipUrl  = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_${FlutterVersion}-stable.zip"
$zipPath = "$env:TEMP\flutter_windows.zip"
Write-Host "  URL: $zipUrl" -ForegroundColor Gray
Write-Host "  Destination: $zipPath" -ForegroundColor Gray

try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    Write-OK "Download complete"
} catch {
    Write-WARN "Direct download failed. Fetching latest stable release info..."
    $releaseUrl = "https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json"
    $releases   = Invoke-RestMethod -Uri $releaseUrl
    $latest     = ($releases.releases | Where-Object { $_.channel -eq "stable" } | Select-Object -First 1)
    $zipUrl     = "$($releases.base_url)$($latest.archive)"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    Write-OK "Download complete (latest stable: $($latest.version))"
}

# Step 3: Extract
Write-Step "Extracting to $InstallPath..."
$parentPath = Split-Path $InstallPath -Parent
if (!(Test-Path $parentPath)) { New-Item -ItemType Directory -Path $parentPath -Force | Out-Null }

Expand-Archive -Path $zipPath -DestinationPath $parentPath -Force

$extractedPath = Join-Path $parentPath "flutter"
if ($extractedPath -ne $InstallPath -and (Test-Path $extractedPath)) {
    Rename-Item -Path $extractedPath -NewName (Split-Path $InstallPath -Leaf) -Force
}
Remove-Item $zipPath -Force
Write-OK "Extraction complete"

# Step 4: Add to PATH
Write-Step "Adding Flutter to User PATH..."
$flutterBin  = "$InstallPath\bin"
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$flutterBin*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$flutterBin", "User")
    $env:PATH += ";$flutterBin"
    Write-OK "Added $flutterBin to PATH"
} else {
    Write-OK "PATH already contains Flutter bin"
}

# Step 5: Set PUB_CACHE
[Environment]::SetEnvironmentVariable("PUB_CACHE", "C:\flutter\.pub-cache", "User")

# Step 6: Disable analytics
Write-Step "Disabling Flutter analytics..."
& "$InstallPath\bin\flutter.bat" config --no-analytics 2>$null
Write-OK "Analytics disabled"

# Step 7: Run flutter doctor
Write-Step "Running flutter doctor..."
Write-Host ""
& "$InstallPath\bin\flutter.bat" doctor
Write-Host ""
Write-OK "Flutter SDK installed at $InstallPath"
Write-Host ""
Write-WARN "IMPORTANT: Open a new PowerShell window for PATH to take effect."
Write-Host "  Run 'flutter doctor' to see remaining setup steps." -ForegroundColor Gray
