# ============================================================
# Next Home – Test Runner Script
# Usage: powershell -ExecutionPolicy Bypass -File .\scripts\test.ps1
# ============================================================

param(
    [switch]$BackendOnly,
    [switch]$FlutterOnly,
    [switch]$Coverage
)

$ErrorActionPreference = "Continue"
$allPassed = $true

function Write-Step($msg) { Write-Host "`n[TEST] $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[PASS] $msg"  -ForegroundColor Green }
function Write-FAIL($msg) { Write-Host "[FAIL] $msg"  -ForegroundColor Red }

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║     Next Home – Test Suite                        ║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Blue

# ── Backend Tests ─────────────────────────────────────────────────────────────
if (!$FlutterOnly) {
    Write-Step "Running backend unit & integration tests..."
    Push-Location backend
    if ($Coverage) {
        npm test -- --coverage 2>&1
    } else {
        npm run test:unit 2>&1
    }
    if ($LASTEXITCODE -ne 0) {
        Write-FAIL "Backend tests FAILED"
        $allPassed = $false
    } else {
        Write-OK "Backend tests PASSED"
        if ($Coverage -and (Test-Path "coverage/lcov-report/index.html")) {
            Write-Host "  Coverage report: backend\coverage\lcov-report\index.html" -ForegroundColor Gray
        }
    }
    Pop-Location
}

# ── Flutter Tests ─────────────────────────────────────────────────────────────
if (!$BackendOnly) {
    Write-Step "Running Flutter unit & widget tests..."
    Push-Location mobile
    if ($Coverage) {
        flutter test --coverage 2>&1
        if ($LASTEXITCODE -eq 0 -and (Get-Command genhtml -ErrorAction SilentlyContinue)) {
            genhtml coverage/lcov.info -o coverage/html --quiet
            Write-Host "  Coverage report: mobile\coverage\html\index.html" -ForegroundColor Gray
        }
    } else {
        flutter test 2>&1
    }
    if ($LASTEXITCODE -ne 0) {
        Write-FAIL "Flutter tests FAILED"
        $allPassed = $false
    } else {
        Write-OK "Flutter tests PASSED"
    }
    Pop-Location

    # Flutter analyze
    Write-Step "Running Flutter static analysis..."
    Push-Location mobile
    flutter analyze 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-FAIL "Flutter analyze found issues"
        $allPassed = $false
    } else {
        Write-OK "Flutter analyze PASSED"
    }
    Pop-Location
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Blue
if ($allPassed) {
    Write-Host "  ALL TESTS PASSED ✓" -ForegroundColor Green
    exit 0
} else {
    Write-Host "  SOME TESTS FAILED ✗" -ForegroundColor Red
    exit 1
}
