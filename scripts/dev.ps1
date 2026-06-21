# ============================================================
# Next Home – Development Script
# Starts all required services for local development
# Usage: powershell -ExecutionPolicy Bypass -File .\scripts\dev.ps1
# ============================================================

param(
    [switch]$SkipDocker,
    [switch]$SkipBackend,
    [switch]$OpenEmulator
)

$ErrorActionPreference = "Continue"

function Write-Step($msg) { Write-Host "`n[▶] $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[✓] $msg"  -ForegroundColor Green }
function Write-WARN($msg) { Write-Host "[!] $msg"  -ForegroundColor Yellow }

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║     Next Home – Development Server               ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta

# ── 1. Check .env ─────────────────────────────────────────────────────────────
if (!(Test-Path "backend\.env")) {
    Write-WARN "backend\.env not found – copying from .env.example"
    Copy-Item "backend\.env.example" "backend\.env"
    Write-WARN "Please fill in backend\.env with your actual credentials before continuing."
}

# ── 2. Docker services ────────────────────────────────────────────────────────
if (!$SkipDocker) {
    Write-Step "Starting Docker services (Oracle DB + Redis)..."
    $dockerRunning = docker info 2>&1 | Select-String "Containers"
    if (!$dockerRunning) {
        Write-WARN "Docker is not running. Please start Docker Desktop and try again."
        exit 1
    }
    docker compose -f docker\docker-compose.yml up -d oracle-db redis
    Write-OK "Docker services started"
    Write-Host "  Oracle DB: localhost:1521  (SID: XEPDB1)" -ForegroundColor Gray
    Write-Host "  Redis:     localhost:6379"                  -ForegroundColor Gray
    Write-Host "  Wait ~60s for Oracle XE to initialize on first run" -ForegroundColor DarkYellow
}

# ── 3. Backend ────────────────────────────────────────────────────────────────
if (!$SkipBackend) {
    Write-Step "Installing backend dependencies..."
    if (!(Test-Path "backend\node_modules")) {
        Push-Location backend
        npm install
        Pop-Location
    }

    Write-Step "Starting Node.js backend (nodemon)..."
    $backendJob = Start-Job -Name "NextHome-Backend" -ScriptBlock {
        Set-Location $using:PWD\backend
        npm run dev
    }
    Write-OK "Backend starting at http://localhost:3000"
    Write-Host "  Debug port: 9229 (attach VSCode debugger)" -ForegroundColor Gray
    Write-Host "  Socket.IO:  http://localhost:3001"         -ForegroundColor Gray
    Write-Host "  Health:     http://localhost:3000/health"  -ForegroundColor Gray
}

# ── 4. Flutter pub get ────────────────────────────────────────────────────────
Write-Step "Checking Flutter dependencies..."
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Push-Location mobile
    flutter pub get | Out-Null
    Pop-Location
    Write-OK "Flutter packages ready"

    if ($OpenEmulator) {
        Write-Step "Launching Android emulator..."
        Start-Process -NoNewWindow "emulator" -ArgumentList "-avd Pixel6_API35 -no-snapshot-load"
        Start-Sleep -Seconds 10
        Write-OK "Emulator launching..."
    }

    Write-Host ""
    Write-Host "  Run Flutter app:" -ForegroundColor White
    Write-Host "  cd mobile && flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1" -ForegroundColor Gray
} else {
    Write-WARN "Flutter not found. Run .\scripts\setup\install_flutter.ps1 first."
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Dev environment ready!" -ForegroundColor Green
Write-Host ""
Write-Host "  Press Ctrl+C to stop the backend, then run:" -ForegroundColor Gray
Write-Host "  docker compose -f docker\docker-compose.yml down" -ForegroundColor Gray
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Cyan

# Keep the script running to show backend logs
if (!$SkipBackend -and $backendJob) {
    Write-Host ""
    Write-Host "  [Backend logs – press Ctrl+C to stop]" -ForegroundColor DarkGray
    Receive-Job -Job $backendJob -Wait
}
