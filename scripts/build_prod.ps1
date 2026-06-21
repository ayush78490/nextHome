# ============================================================
# Next Home – Production Build Script
# Builds APK, Docker image, and pushes to registry
# Usage: powershell -ExecutionPolicy Bypass -File .\scripts\build_prod.ps1
# ============================================================

param(
    [string]$Version       = "1.0.0",
    [string]$Registry      = "container-registry.oracle.com/nexthome",
    [string]$ApiUrl        = "https://api.nexthome.app/api/v1",
    [switch]$SkipMobile,
    [switch]$SkipDocker,
    [switch]$SkipPush
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "`n[BUILD] $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[  OK ] $msg"  -ForegroundColor Green }
function Write-FAIL($msg) { Write-Host "[ FAIL] $msg"  -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║     Next Home – Production Build v$Version       ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Yellow

# ── 1. Load production env ────────────────────────────────────────────────────
if (Test-Path ".env.prod") {
    Get-Content ".env.prod" | ForEach-Object {
        if ($_ -match "^([^#=]+)=(.*)$") {
            [System.Environment]::SetEnvironmentVariable($Matches[1].Trim(), $Matches[2].Trim(), "Process")
        }
    }
    Write-OK "Production env loaded from .env.prod"
} else {
    Write-Host "  [WARN] .env.prod not found – using environment variables" -ForegroundColor Yellow
}

# ── 2. Flutter APK (Release) ─────────────────────────────────────────────────
if (!$SkipMobile) {
    Write-Step "Building Flutter APK (release)..."
    Push-Location mobile
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    flutter build apk --release `
        "--dart-define=API_BASE_URL=$ApiUrl" `
        "--dart-define=SOCKET_URL=$($ApiUrl -replace '/api/v1', ':3001')" `
        "--dart-define=GOOGLE_MAPS_API_KEY=$env:GOOGLE_MAPS_API_KEY" `
        "--dart-define=RAZORPAY_KEY_ID=$env:RAZORPAY_KEY_ID" `
        "--dart-define=STRIPE_PUBLISHABLE_KEY=$env:STRIPE_PUBLISHABLE_KEY"
    Pop-Location

    $apkPath = "mobile\build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $apkPath) {
        $size = [math]::Round((Get-Item $apkPath).Length / 1MB, 1)
        Write-OK "APK built: $apkPath ($size MB)"
    } else {
        Write-FAIL "APK build failed – file not found"
    }

    # iOS archive (macOS only)
    Write-Host "  [INFO] iOS build requires macOS – skipped on Windows" -ForegroundColor Gray
}

# ── 3. Docker Backend Image ───────────────────────────────────────────────────
if (!$SkipDocker) {
    Write-Step "Building Docker image (backend)..."
    $imageName = "$Registry/backend"
    $imageTag  = "${imageName}:$Version"
    $imageLatest = "${imageName}:latest"

    docker build `
        --target production `
        -f docker\backend\Dockerfile `
        -t $imageTag `
        -t $imageLatest `
        --build-arg BUILD_VERSION=$Version `
        backend\

    Write-OK "Docker image built: $imageTag"

    if (!$SkipPush) {
        Write-Step "Pushing to registry: $Registry..."
        docker push $imageTag
        docker push $imageLatest
        Write-OK "Image pushed: $imageTag"
    }
}

# ── 4. Summary ────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  Production build complete! v$Version" -ForegroundColor Green
if (!$SkipMobile) { Write-Host "  APK: mobile\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Gray }
if (!$SkipDocker) { Write-Host "  Docker: $Registry/backend:$Version" -ForegroundColor Gray }
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Yellow
