$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$definesFile = Join-Path $repoRoot 'config\dart_defines.production.json'

if (-not (Test-Path $definesFile)) {
  throw "Missing production defines: $definesFile"
}

Push-Location $repoRoot
try {
  dart pub get --enforce-lockfile
  dart run bin/stone_set.dart stage-rank-assets

  Push-Location (Join-Path $repoRoot 'apps\mobile')
  try {
    flutter build apk --release --dart-define-from-file=$definesFile
  }
  finally {
    Pop-Location
  }

  Push-Location (Join-Path $repoRoot 'apps\dashboard')
  try {
    flutter build web --release --dart-define-from-file=$definesFile
    Copy-Item -Force 'vercel.json' 'build\web\vercel.json'
  }
  finally {
    Pop-Location
  }

  Write-Host ''
  Write-Host 'Private release built successfully.'
  Write-Host "APK:       $repoRoot\apps\mobile\build\app\outputs\flutter-apk\app-release.apk"
  Write-Host "Dashboard: $repoRoot\apps\dashboard\build\web"
  Write-Host ''
  Write-Host 'For Android update installs, prefer building future APKs on this same Windows account/machine so the existing debug signing key remains consistent.'
}
finally {
  Pop-Location
}
