# Tur İzim — lightweight live smoke test (no extra dependencies)
# Usage: .\scripts\smoke-test-live.ps1

$ErrorActionPreference = "Stop"

$BackendBase = "https://tur-izim-production.up.railway.app"
$FrontendUrl = "https://tur-izim-live.vercel.app"

$passed = 0
$failed = 0

function Write-Result {
    param(
        [string]$Name,
        [bool]$Ok,
        [string]$Detail = ""
    )
    if ($Ok) {
        Write-Host "[PASS] $Name" -ForegroundColor Green
        if ($Detail) { Write-Host "       $Detail" -ForegroundColor DarkGray }
        $script:passed++
    } else {
        Write-Host "[FAIL] $Name" -ForegroundColor Red
        if ($Detail) { Write-Host "       $Detail" -ForegroundColor Yellow }
        $script:failed++
    }
}

Write-Host ""
Write-Host "Tur Izim Live Smoke Test" -ForegroundColor Cyan
Write-Host "Backend:  $BackendBase"
Write-Host "Frontend: $FrontendUrl"
Write-Host ""

# --- Health ---
try {
    $healthUrl = "$BackendBase/api/health"
    $resp = Invoke-WebRequest -Uri $healthUrl -Method GET -UseBasicParsing -TimeoutSec 30
    $ok = $resp.StatusCode -eq 200
    $status = $null
    if ($resp.Content) {
        try {
            $json = $resp.Content | ConvertFrom-Json
            $status = $json.status
            if ($status) {
                $normalized = $status.ToString().ToLower()
                if ($normalized -ne "ok" -and $normalized -ne "up") {
                    $ok = $false
                }
            }
        } catch {
            $ok = $false
        }
    }
    Write-Result -Name "GET /api/health" -Ok $ok -Detail "HTTP $($resp.StatusCode); status=$status"
} catch {
    Write-Result -Name "GET /api/health" -Ok $false -Detail $_.Exception.Message
}

# --- Plans ---
try {
    $plansUrl = "$BackendBase/api/billing/agency/plans"
    $resp = Invoke-WebRequest -Uri $plansUrl -Method GET -UseBasicParsing -TimeoutSec 30
    $ok = $resp.StatusCode -eq 200
    $planCount = 0
    $codes = @()
    if ($resp.Content) {
        try {
            $plans = $resp.Content | ConvertFrom-Json
            if ($plans -is [System.Array]) {
                $planCount = $plans.Count
                $codes = @($plans | ForEach-Object { $_.planCode })
            } else {
                $ok = $false
            }
        } catch {
            $ok = $false
        }
    }
    $hasExpected = ($codes -contains "FREE") -and ($codes -contains "AGENCY_PRO") -and ($codes -contains "AGENCY_GROWTH")
    if (-not $hasExpected) { $ok = $false }
    Write-Result -Name "GET /api/billing/agency/plans" -Ok $ok -Detail "HTTP $($resp.StatusCode); plans=$planCount; codes=$($codes -join ', ')"
} catch {
    Write-Result -Name "GET /api/billing/agency/plans" -Ok $false -Detail $_.Exception.Message
}

# --- Frontend (optional) ---
try {
    $resp = Invoke-WebRequest -Uri $FrontendUrl -Method GET -UseBasicParsing -TimeoutSec 45
    $ok = $resp.StatusCode -ge 200 -and $resp.StatusCode -lt 400
    $hasFlutter = $resp.Content -match "flutter" -or $resp.Content -match "main\.dart\.js" -or $resp.Content -match "<!DOCTYPE html>"
    if (-not $hasFlutter) { $ok = $false }
    Write-Result -Name "GET frontend (Vercel)" -Ok $ok -Detail "HTTP $($resp.StatusCode)"
} catch {
    Write-Result -Name "GET frontend (Vercel)" -Ok $false -Detail $_.Exception.Message
}

Write-Host ""
Write-Host "Summary: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($failed -gt 0) {
    exit 1
}
exit 0
