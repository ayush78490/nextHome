# Install Android SDK CLI Tools (No Android Studio needed)
# Run as: powershell -ExecutionPolicy Bypass -File .\install_android_sdk.ps1

param(
    [string]$SdkRoot = "C:\android-sdk"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Write-Step($msg) { Write-Host "`n[STEP] $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[  OK] $msg" -ForegroundColor Green }
function Write-WARN($msg) { Write-Host "[ WARN] $msg" -ForegroundColor Yellow }
function Write-FAIL($msg) { Write-Host "[ FAIL] $msg" -ForegroundColor Red; exit 1 }

# Step 1: Detect Java
Write-Step "Checking Java installation..."
$JavaHome = $env:JAVA_HOME
if (-not $JavaHome) {
    $javaLocations = @(
        "C:\Program Files\Microsoft\jdk-17*",
        "C:\Program Files\Eclipse Adoptium\jdk-17*",
        "C:\Program Files\Java\jdk-17*",
        "C:\Program Files\Microsoft\jdk-21*"
    )
    foreach ($loc in $javaLocations) {
        $found = Get-Item $loc -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $JavaHome = $found.FullName; break }
    }
}

if (-not $JavaHome -or -(Test-Path "$JavaHome\bin\java.exe")) {
    Write-WARN "Java 17+ not found. Installing via winget..."
    winget install --id Microsoft.OpenJDK.17 --accept-source-agreements --accept-package-agreements -e
    $JavaHome = (Get-Item "C:\Program Files\Microsoft\jdk-17*" -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
    if (-not $JavaHome) { Write-FAIL "Java installation failed. Install JDK 17+ manually." }
}

Write-OK "Using Java at: $JavaHome"
[Environment]::SetEnvironmentVariable("JAVA_HOME", $JavaHome, "User")
$env:JAVA_HOME = $JavaHome

# Step 2: Create SDK root
Write-Step "Creating SDK root: $SdkRoot"
New-Item -ItemType Directory -Path $SdkRoot -Force | Out-Null
New-Item -ItemType Directory -Path "$SdkRoot\cmdline-tools" -Force | Out-Null

# Step 3: Download Android command-line tools
Write-Step "Downloading Android command-line tools..."
$cliToolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$cliToolsZip = "$env:TEMP\android-cmdline-tools.zip"
$cliToolsDest = "$SdkRoot\cmdline-tools"

Invoke-WebRequest -Uri $cliToolsUrl -OutFile $cliToolsZip -UseBasicParsing
Write-OK "Download complete"

# Step 4: Extract
Write-Step "Extracting command-line tools..."
Expand-Archive -Path $cliToolsZip -DestinationPath $cliToolsDest -Force
$extracted = "$cliToolsDest\cmdline-tools"
if (Test-Path $extracted) {
    Move-Item -Path $extracted -Destination "$cliToolsDest\latest" -Force
}
Remove-Item $cliToolsZip -Force
Write-OK "Extracted to $cliToolsDest\latest"

# Step 5: Set environment variables
Write-Step "Setting environment variables..."
[Environment]::SetEnvironmentVariable("ANDROID_HOME",     $SdkRoot, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $SdkRoot, "User")
$env:ANDROID_HOME     = $SdkRoot
$env:ANDROID_SDK_ROOT = $SdkRoot

$sdkmanagerPath = "$SdkRoot\cmdline-tools\latest\bin"
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$additions = @($sdkmanagerPath, "$SdkRoot\platform-tools", "$SdkRoot\emulator")
foreach ($add in $additions) {
    if ($currentPath -notlike "*$add*") { $currentPath += ";$add" }
}
[Environment]::SetEnvironmentVariable("PATH", $currentPath, "User")
$env:PATH += ";$sdkmanagerPath;$SdkRoot\platform-tools;$SdkRoot\emulator"
Write-OK "Environment variables set"

# Step 6: Accept licenses
Write-Step "Accepting Android SDK licenses..."
$sdkmanager = "$sdkmanagerPath\sdkmanager.bat"
"y`ny`ny`ny`ny`ny`ny" | & $sdkmanager --sdk_root="$SdkRoot" --licenses
Write-OK "Licenses accepted"

# Step 7: Install SDK packages
Write-Step "Installing SDK packages (this takes several minutes)..."
$packages = @(
    "platform-tools",
    "platforms;android-35",
    "build-tools;35.0.0",
    "system-images;android-35;google_apis;x86_64",
    "emulator"
)
foreach ($pkg in $packages) {
    Write-Host "  Installing: $pkg" -ForegroundColor Gray
    & $sdkmanager --sdk_root="$SdkRoot" $pkg
}
Write-OK "SDK packages installed"

# Step 8: Create default AVD
Write-Step "Creating AVD: Pixel6_API35..."
$avdmanager = "$sdkmanagerPath\avdmanager.bat"
echo "no" | & $avdmanager create avd -n "Pixel6_API35" -k "system-images;android-35;google_apis;x86_64" --device "pixel_6" --force 2>$null
Write-OK "AVD created: Pixel6_API35"

# Step 9: Configure Flutter
Write-Step "Configuring Flutter Android SDK path..."
if (Test-Path "C:\flutter\bin\flutter.bat") {
    & "C:\flutter\bin\flutter.bat" config --android-sdk $SdkRoot
    Write-OK "Flutter configured with Android SDK at $SdkRoot"
} else {
    Write-WARN "Flutter not found at C:\flutter"
    Write-Host "  After Flutter is installed, run:" -ForegroundColor Gray
    Write-Host "  flutter config --android-sdk $SdkRoot" -ForegroundColor Gray
}

Write-Host ""
Write-OK "Android SDK installed at $SdkRoot"
Write-WARN "Open a new PowerShell window for PATH changes to take effect."
Write-Host "  Then run: flutter doctor" -ForegroundColor Gray
