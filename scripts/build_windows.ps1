param(
    [ValidateSet('release', 'debug')]
    [string]$Mode = 'release'
)

$ErrorActionPreference = 'Stop'

Write-Host '==> Flutter pub get'
flutter pub get

Write-Host '==> Enable Windows desktop support'
flutter config --enable-windows-desktop

if ($Mode -eq 'release') {
    Write-Host '==> Building Windows release'
    flutter build windows --release
}
else {
    Write-Host '==> Building Windows debug'
    flutter build windows --debug
}

Write-Host 'Windows build completed.'
