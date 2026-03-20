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

    Write-Host '==> Flutter pub get'
    flutter pub get

    Write-Host '==> Enable Windows desktop support'
    flutter config --enable-windows-desktop

    if ($Mode -eq 'release') {
        Write-Host '==> Building Windows release'
        flutter build windows --release
        $buildFolder = 'Release'
    }
    else {
        Write-Host '==> Building Windows debug'
        flutter build windows --debug
        $buildFolder = 'Debug'
    }

    $sourceExe = Join-Path $repoRoot "build/windows/x64/runner/$buildFolder/openfxpedia.exe"
    if (-not (Test-Path $sourceExe)) {
        Write-Error "Expected EXE not found: $sourceExe"
        exit 4
    }

    if ($Mode -eq 'release') {
        $targetName = "openfxpedia_$appVersion.exe"
    }
    else {
        $targetName = "openfxpedia_${appVersion}_debug.exe"
    }

    $targetExe = Join-Path $repoRoot "build/windows/x64/runner/$buildFolder/$targetName"
    Move-Item -Path $sourceExe -Destination $targetExe -Force

    Write-Host "Windows build completed ($Mode)."
    Write-Host "EXE: $targetExe"
}
finally {
    Pop-Location
}
