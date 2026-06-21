# ============================================================
# check_prerequisites.ps1 – Next Home Dev Environment Checker
# Run as: powershell -ExecutionPolicy Bypass -File .\check_prerequisites.ps1
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

function Write-Header($msg) {
    Write-Host ""
    Write-Host "  $msg" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host ""
}

function Check-Tool {
    param($Name, $Command, $MinVersion, $VersionPattern)
    try {
        $output = Invoke-Expression $Command 2>&1 | Out-String
        $version = if ($VersionPattern) { ($output | Select-String $VersionPattern).Matches[0].Value } else { $output.Trim().Split("`n")[0] }
        Write-Host "  [PASS] $Name" -ForegroundColor Green -NoNewline
        Write-Host " ($version)" -ForegroundColor DarkGray
        return $true
    } catch {
        Write-Host "  [MISS] $Name not found" -ForegroundColor Red
        return $false
    }
}

function Check-EnvVar {
    param($Name, $ExpectedSubstring)
    $val = [Environment]::GetEnvironmentVariable($Name, "User")
    if (!$val) { $val = [Environment]::GetEnvironmentVariable($Name, "Machine") }
    if ($val -and ($ExpectedSubstring -eq "" -or $val -like "*$ExpectedSubstring*")) {
        Write-Host "  [PASS] $Name" -ForegroundColor Green -NoNewline
        Write-Host " = $val" -ForegroundColor DarkGray
        return $true
    } else {
        Write-Host "  [MISS] $Name not set" -ForegroundColor Red
        return $false
    }
}

$allPass = $true

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Next Home – Prerequisites Checker                 ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# ── Core Tools ────────────────────────────────────────────────────────────────
Write-Header "Core Tools"
$allPass = (Check-Tool "Git"       "git --version"    "2.x" "[\d]+\.[\d]+\.[\d]+") -and $allPass
$allPass = (Check-Tool "Node.js"   "node --version"   "18"  "v[\d]+\.[\d]+\.[\d]+") -and $allPass
$allPass = (Check-Tool "npm"       "npm --version"    "9"   "[\d]+\.[\d]+\.[\d]+") -and $allPass

# ── Flutter & Dart ────────────────────────────────────────────────────────────
Write-Header "Flutter & Dart"
$flutterOk = Check-Tool "Flutter" "flutter --version" "3.x" "Flutter [\d]+\.[\d]+\.[\d]+"
$dartOk    = Check-Tool "Dart"    "dart --version"    "3.x" "Dart SDK version: [\d]+\.[\d]+"
if (!$flutterOk) {
    Write-Host "  → Run: .\scripts\setup\install_flutter.ps1" -ForegroundColor Yellow
}
$allPass = $flutterOk -and $dartOk -and $allPass

# ── Java ──────────────────────────────────────────────────────────────────────
Write-Header "Java (required for Android SDK)"
$javaOk = Check-Tool "Java 17+" "java -version" "17" "version `"[\d]+"
if (!$javaOk) {
    Write-Host "  → Install: winget install --id Microsoft.OpenJDK.17" -ForegroundColor Yellow
}
$allPass = $javaOk -and $allPass

# ── Android SDK ───────────────────────────────────────────────────────────────
Write-Header "Android SDK"
$adbOk  = Check-Tool "adb (platform-tools)" "adb version" ""  "Android Debug Bridge"
$avdOk  = Check-Tool "avdmanager"           "(if (Test-Path 'C:\android-sdk\cmdline-tools\latest\bin\avdmanager.bat') { 'found' } else { throw })" "" "found"
if (!$adbOk) {
    Write-Host "  → Run: .\scripts\setup\install_android_sdk.ps1" -ForegroundColor Yellow
}
$allPass = $adbOk -and $allPass

# ── Environment Variables ──────────────────────────────────────────────────────
Write-Header "Environment Variables"
$allPass = (Check-EnvVar "ANDROID_HOME"     "android-sdk") -and $allPass
$allPass = (Check-EnvVar "ANDROID_SDK_ROOT" "android-sdk") -and $allPass
$allPass = (Check-EnvVar "JAVA_HOME"        "")            -and $allPass

# ── Docker ────────────────────────────────────────────────────────────────────
Write-Header "Docker"
$dockerOk = Check-Tool "Docker" "docker --version" "" "Docker version [\d]+"
if (!$dockerOk) {
    Write-Host "  → Install Docker Desktop: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
}
$allPass = $dockerOk -and $allPass

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
if ($allPass) {
    Write-Host "  ALL CHECKS PASSED – Dev environment is ready!" -ForegroundColor Green
} else {
    Write-Host "  SOME CHECKS FAILED – Follow the hints above to fix." -ForegroundColor Red
}
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
