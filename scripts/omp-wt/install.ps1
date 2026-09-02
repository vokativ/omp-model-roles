<#
.SYNOPSIS
    Installs omp-wt in Windows PowerShell.
#>

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourcePs1 = Join-Path $ScriptDir "omp-wt.ps1"
$TargetDir = Join-Path $HOME ".local\bin"

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

$TargetPs1 = Join-Path $TargetDir "omp-wt.ps1"
Copy-Item -Path $SourcePs1 -Destination $TargetPs1 -Force

Write-Host "Copied omp-wt.ps1 to: $TargetPs1" -ForegroundColor Green

# Add alias/function to PowerShell profile
$ProfileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$ProfileContent = Get-Content $PROFILE -Raw 2>$null
$FunctionSnippet = @"

# OMP Git Worktree Launcher
function Invoke-OmpWt { & "$TargetPs1" @args }
Set-Alias -Name omp-wt -Value Invoke-OmpWt
"@

if ($ProfileContent -notmatch "omp-wt\.ps1") {
    Add-Content -Path $PROFILE -Value $FunctionSnippet
    Write-Host "Added 'omp-wt' alias to your PowerShell profile: $PROFILE" -ForegroundColor Green
} else {
    Write-Host "'omp-wt' already configured in your profile." -ForegroundColor Cyan
}

Write-Host "`nInstallation complete! Restart your PowerShell terminal or run:" -ForegroundColor Green
Write-Host "  . `$PROFILE" -ForegroundColor Yellow
Write-Host "  omp-wt -Guide" -ForegroundColor Yellow
