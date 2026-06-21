# Post-install setup: runs after Flutter + Android SDK are installed
# Triggered automatically by dev.ps1 or run manually

param(
    [string]$FlutterPath = "C:\flutter",
    [string]$AndroidSdk  = "C:\android-sdk"
)

$ErrorActionPreference = "Continue"
$flutter = "$FlutterPath\bin\flutter.bat"
$dart    = "$FlutterPath\bin\dart.bat"

function Write-Step($msg) { Write-Host "`n[POST] $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[  OK] $msg" -ForegroundColor Green }
function Write-WARN($msg) { Write-Host "[ WARN] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "  Next Home - Post-Install Configuration" -ForegroundColor Magenta
Write-Host ""

# Step 1: Verify Flutter
Write-Step "Verifying Flutter installation..."
if (!(Test-Path $flutter)) {
    Write-WARN "Flutter not found at $FlutterPath. Run install_flutter.ps1 first."
    exit 1
}
& $flutter --version
Write-OK "Flutter verified"

# Step 2: Configure Android SDK
Write-Step "Configuring Flutter with Android SDK..."
if (Test-Path "$AndroidSdk\cmdline-tools\latest\bin\sdkmanager.bat") {
    & $flutter config --android-sdk $AndroidSdk
    Write-OK "Flutter configured with Android SDK at $AndroidSdk"
} else {
    Write-WARN "Android SDK not found at $AndroidSdk. Run install_android_sdk.ps1 first."
}

# Step 3: Accept Android licenses
Write-Step "Accepting Android licenses via Flutter..."
echo "y" | & $flutter doctor --android-licenses 2>$null
Write-OK "Android licenses accepted"

# Step 4: Flutter pub get
Write-Step "Running flutter pub get..."
Push-Location "d:\next-home\mobile"
& $flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-OK "Flutter packages installed"
} else {
    Write-WARN "flutter pub get encountered issues - check output above"
}
Pop-Location

# Step 5: Build runner (code generation)
Write-Step "Running build_runner (Freezed + JSON serialization)..."
Push-Location "d:\next-home\mobile"
& $dart run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -eq 0) {
    Write-OK "Code generation complete"
} else {
    Write-WARN "build_runner encountered issues - check output above"
}
Pop-Location

# Step 6: Install FlutterFire CLI
Write-Step "Installing FlutterFire CLI (for Firebase config)..."
& $dart pub global activate flutterfire_cli
Write-OK "FlutterFire CLI installed"
Write-Host "  To configure Firebase, run:" -ForegroundColor Gray
Write-Host "  flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID" -ForegroundColor Gray

# Step 7: Flutter doctor summary
Write-Step "Running flutter doctor..."
& $flutter doctor -v
Write-Host ""

# Step 8: Commit updated files
Write-Step "Committing generated files..."
Push-Location "d:\next-home"
git add mobile\lib\firebase_options.dart
git add mobile\pubspec.yaml
git add mobile\assets\
git add backend\.env.example
git add scripts\setup\
git commit -m "chore: post-install updates - firebase_options placeholder, google_fonts, asset dirs" 2>$null
Pop-Location

Write-Host ""
Write-Host "  Post-install setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "  1. Configure Firebase: flutterfire configure --project=YOUR_PROJECT_ID" -ForegroundColor Gray
Write-Host "  2. Install Docker Desktop: https://docker.com/products/docker-desktop" -ForegroundColor Gray
Write-Host "  3. Start dev: powershell scripts\dev.ps1" -ForegroundColor Gray
Write-Host "  4. Run app:   cd mobile; flutter run" -ForegroundColor Gray
