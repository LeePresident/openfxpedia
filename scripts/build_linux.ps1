param(
    [ValidateSet('release', 'debug')]
    [string]$Mode = 'release'
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir '..')).Path
$runtimeInformation = [System.Runtime.InteropServices.RuntimeInformation]

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "flutter not found in PATH. Install Flutter and ensure 'flutter' is available." -ErrorAction Continue
    exit 1
}

if (-not $runtimeInformation::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)) {
    Write-Error 'Linux build requires a Linux host with the desktop toolchain.' -ErrorAction Continue
    exit 6
}

if ($runtimeInformation::ProcessArchitecture -ne [System.Runtime.InteropServices.Architecture]::X64) {
    Write-Error 'Linux build currently supports x86_64 hosts only.' -ErrorAction Continue
    exit 7
}

if ($Mode -eq 'release' -and -not (Get-Command tar -ErrorAction SilentlyContinue)) {
    Write-Error 'tar not found in PATH; it is required to package the release bundle.' -ErrorAction Continue
    exit 8
}

Push-Location $repoRoot
$stageRoot = $null
try {
    $pubspec = Get-Content -Raw 'pubspec.yaml'
    $versionMatch = [regex]::Match($pubspec, '(?m)^version:\s*([^\s]+)')
    if (-not $versionMatch.Success) {
        Write-Error 'Unable to read version from pubspec.yaml' -ErrorAction Continue
        exit 3
    }
    $appVersion = $versionMatch.Groups[1].Value.Split('+')[0]

    Write-Host '==> Flutter pub get'
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    Write-Host '==> Enable Linux desktop support'
    flutter config --enable-linux-desktop
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    Write-Host "==> Building Linux $Mode"
    flutter build linux "--$Mode"
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    if ($Mode -eq 'release') {
        $sourceBundle = Join-Path $repoRoot 'build/linux/x64/release/bundle'
        if (-not (Test-Path $sourceBundle -PathType Container)) {
            Write-Error "Expected Linux bundle not found: $sourceBundle" -ErrorAction Continue
            exit 4
        }

        $outputDir = Join-Path $repoRoot 'build/linux'
        New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
        $packageName = "openfxpedia_${appVersion}_linux_x64"
        $stageRoot = Join-Path $outputDir "openfxpedia-${appVersion}-$([guid]::NewGuid().ToString('N'))"
        $packageDir = Join-Path $stageRoot $packageName
        New-Item -ItemType Directory -Force -Path $packageDir | Out-Null
        Copy-Item -Path (Join-Path $sourceBundle '*') -Destination $packageDir -Recurse -Force

        $archivePath = Join-Path $outputDir "$packageName.tar.gz"
        tar -czf $archivePath -C $stageRoot $packageName
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to create Linux release archive: $archivePath" -ErrorAction Continue
            exit $LASTEXITCODE
        }

        Write-Host 'Linux release build completed.'
        Write-Host "Archive: $archivePath"
    }
    else {
        Write-Host 'Linux debug build completed.'
        Write-Host "Bundle: $(Join-Path $repoRoot 'build/linux/x64/debug/bundle')"
    }
}
finally {
    if ($stageRoot -and (Test-Path $stageRoot -PathType Container)) {
        Remove-Item -LiteralPath $stageRoot -Recurse -Force
    }
    Pop-Location
}
