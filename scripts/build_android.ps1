param(
    [ValidateSet('release', 'debug')]
    [string]$Mode = 'release'
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir '..')

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "flutter not found in PATH. Install Flutter and ensure 'flutter' is available."
    exit 1
}

Push-Location $repoRoot
try {
    $pubspec = Get-Content -Raw 'pubspec.yaml'
    $versionMatch = [regex]::Match($pubspec, '(?m)^version:\s*([^\s]+)')
    if (-not $versionMatch.Success) {
        Write-Error 'Unable to read version from pubspec.yaml'
        exit 3
    }
    $versionRaw = $versionMatch.Groups[1].Value
    $appVersion = $versionRaw.Split('+')[0]

    Write-Host '==> flutter pub get'
    flutter pub get

    if ($Mode -eq 'release') {
        Write-Host '==> Building Android APK (release)'
        flutter build apk --release
    }
    else {
        Write-Host '==> Building Android APK (debug)'
        flutter build apk --debug
    }

    $sourceApk = Join-Path $repoRoot "build/app/outputs/flutter-apk/app-$Mode.apk"
    if (-not (Test-Path $sourceApk)) {
        Write-Error "Expected APK not found: $sourceApk"
        exit 4
    }

    $sourceSha1 = "$sourceApk.sha1"

    if ($Mode -eq 'release') {
        $targetName = "openfxpedia_$appVersion.apk"
    }
    else {
        $targetName = "openfxpedia_${appVersion}_debug.apk"
    }

    $targetApk = Join-Path $repoRoot "build/app/outputs/flutter-apk/$targetName"
    Move-Item -Path $sourceApk -Destination $targetApk -Force

    if (Test-Path $sourceSha1) {
        Remove-Item -Path $sourceSha1 -Force
    }

    $hash = (Get-FileHash -Path $targetApk -Algorithm SHA1).Hash.ToLowerInvariant()
    $targetSha1 = "$targetApk.sha1"
    Set-Content -Path $targetSha1 -Value "$hash  $targetName"

    Write-Host "Android build completed ($Mode)."
    Write-Host "APK: $targetApk"
    Write-Host "SHA1: $targetSha1"
}
finally {
    Pop-Location
}
