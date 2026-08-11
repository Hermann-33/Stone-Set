param(
  [Parameter(Mandatory = $true)]
  [ValidateRange(1, 2099999999)]
  [int] $BuildNumber
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$definesFile = Join-Path $repoRoot 'config\dart_defines.release.json'
$requiredEnvironment = @(
  'STONE_SET_RELEASE_KEYSTORE_PATH',
  'STONE_SET_RELEASE_STORE_PASSWORD',
  'STONE_SET_RELEASE_KEY_ALIAS',
  'STONE_SET_RELEASE_KEY_PASSWORD'
)

if (-not (Test-Path $definesFile)) {
  throw "Missing release defines: $definesFile"
}

foreach ($name in $requiredEnvironment) {
  $value = [Environment]::GetEnvironmentVariable($name)
  if ([string]::IsNullOrWhiteSpace($value)) {
    throw "Missing permanent release-signing environment value: $name"
  }
}

$keystorePath = [Environment]::GetEnvironmentVariable('STONE_SET_RELEASE_KEYSTORE_PATH')
if (-not (Test-Path -LiteralPath $keystorePath)) {
  throw 'The configured permanent release keystore does not exist.'
}

Push-Location $repoRoot
try {
  dart pub get --enforce-lockfile
  dart run bin/stone_set.dart stage-rank-assets

  Push-Location (Join-Path $repoRoot 'apps\mobile')
  try {
    flutter build apk --release --build-number=$BuildNumber --dart-define-from-file=$definesFile
  }
  finally {
    Pop-Location
  }

  $apk = Join-Path $repoRoot 'apps\mobile\build\app\outputs\flutter-apk\app-release.apk'
  if (-not (Test-Path -LiteralPath $apk)) {
    throw 'The signed release APK was not produced.'
  }

  $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $apk).Hash
  $size = (Get-Item -LiteralPath $apk).Length
  Write-Host 'Permanent-signed Android release built successfully.'
  Write-Host "APK:     $apk"
  Write-Host "Bytes:   $size"
  Write-Host "SHA-256: $hash"
  Write-Host 'Use Firebase App Distribution for phone delivery; do not publish this APK.'
}
finally {
  Pop-Location
}
