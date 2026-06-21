# ============================================================
# Next Home – Format Script
# Formats both backend (Prettier+ESLint) and mobile (dart format)
# Usage: powershell -ExecutionPolicy Bypass -File .\scripts\format.ps1
# ============================================================

function Write-Step($msg) { Write-Host "`n[FMT] $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[  ✓] $msg"  -ForegroundColor Green }

Write-Host ""
Write-Host "  Next Home – Code Formatter" -ForegroundColor Magenta
Write-Host ""

# ── Backend ───────────────────────────────────────────────────────────────────
Write-Step "Formatting backend (Prettier + ESLint)..."
Push-Location backend
npx prettier --write "src/**/*.js" "tests/**/*.js" --log-level warn
npx eslint "src/**/*.js" --fix --quiet
Write-OK "Backend formatted"
Pop-Location

# ── Mobile ────────────────────────────────────────────────────────────────────
Write-Step "Formatting Flutter code (dart format)..."
Push-Location mobile
dart format lib/ test/ --line-length 100
Write-OK "Flutter code formatted"
Pop-Location

# ── Infrastructure ────────────────────────────────────────────────────────────
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    Write-Step "Formatting Terraform files..."
    Push-Location infrastructure\terraform
    terraform fmt -recursive
    Write-OK "Terraform formatted"
    Pop-Location
}

Write-Host ""
Write-Host "  All files formatted ✓" -ForegroundColor Green
