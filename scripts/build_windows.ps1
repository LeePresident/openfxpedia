param(
    [ValidateSet('release', 'debug')]
    [string]$Mode = 'release'
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir '..')
$installerRoot = Join-Path $repoRoot 'build/windows/installer'
$portableRoot = Join-Path $repoRoot 'build/windows/portable'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "flutter not found in PATH. Install Flutter and ensure 'flutter' is available."
    exit 1
}

function Get-MakensisPath {
    $makensisCommand = Get-Command makensis -ErrorAction SilentlyContinue
    if ($null -ne $makensisCommand) {
        return $makensisCommand.Source
    }

    $candidatePaths = @(
        (Join-Path $env:ProgramFiles 'NSIS\makensis.exe')
        (Join-Path ${env:ProgramFiles(x86)} 'NSIS\makensis.exe')
    )

    foreach ($candidatePath in $candidatePaths) {
        if ($candidatePath -and (Test-Path $candidatePath)) {
            return $candidatePath
        }
    }

    return $null
}

$makensisPath = $null
if ($Mode -eq 'release') {
    $makensisPath = Get-MakensisPath
    if (-not $makensisPath) {
        Write-Error "makensis not found. Install NSIS or add makensis to PATH. Checked PATH, `$env:ProgramFiles\NSIS\makensis.exe, and `$env:ProgramFiles(x86)\NSIS\makensis.exe."
        exit 2
    }
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

    $runnerOutputDir = Join-Path $repoRoot "build/windows/x64/runner/$buildFolder"
    $sourceExe = Join-Path $runnerOutputDir 'openfxpedia.exe'
    if (-not (Test-Path $sourceExe)) {
        Write-Error "Expected EXE not found: $sourceExe"
        exit 4
    }

    New-Item -ItemType Directory -Force -Path $installerRoot | Out-Null
    New-Item -ItemType Directory -Force -Path $portableRoot | Out-Null

    if ($Mode -eq 'release') {
        $portableExeName = "openfxpedia_$appVersion.exe"
    }
    else {
        $portableExeName = "openfxpedia_${appVersion}_debug.exe"
    }

    $portableExe = Join-Path $portableRoot $portableExeName
    Copy-Item -Path $sourceExe -Destination $portableExe -Force

    if ($Mode -eq 'release') {
        $stagingRoot = Join-Path $installerRoot 'staging'
        $installerScript = Join-Path $installerRoot "openfxpedia_${appVersion}_installer.nsi"
        $installerExe = Join-Path $installerRoot "openfxpedia_${appVersion}_setup.exe"
        $iconPath = Join-Path $repoRoot 'windows/runner/resources/app_icon.ico'

        if (Test-Path $stagingRoot) {
            Remove-Item -Recurse -Force $stagingRoot
        }

        New-Item -ItemType Directory -Force -Path $stagingRoot | Out-Null
        Copy-Item -Path (Join-Path $runnerOutputDir '*') -Destination $stagingRoot -Recurse -Force

        $nsiTemplate = @'
Unicode true
Name "OpenFXpedia"
OutFile "__INSTALLER_EXE__"
InstallDir "$LOCALAPPDATA\Programs\OpenFXpedia"
InstallDirRegKey HKCU "Software\OpenFXpedia" "InstallDir"
RequestExecutionLevel user
ShowInstDetails show
ShowUninstDetails show
SetCompressor /SOLID lzma

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "StrFunc.nsh"
${Using:StrFunc} StrStr
!define MUI_ABORTWARNING
!define MUI_ICON "__ICON_PATH__"
!define MUI_UNICON "__ICON_PATH__"

Function .onInit
    nsExec::ExecToStack 'tasklist /FI "IMAGENAME eq openfxpedia.exe" /FO CSV /NH'
    Pop $0
    Pop $1
    ${StrStr} $2 $1 '"openfxpedia.exe"'
    StrCmp $2 "" done

    MessageBox MB_YESNO|MB_ICONEXCLAMATION "OpenFXpedia is currently running. Close it now so the installation can continue?" IDYES close IDNO cancel

close:
    nsExec::ExecToStack '"$SYSDIR\taskkill.exe" /IM openfxpedia.exe /T /F'
    Pop $0
    Pop $1
    StrCpy $3 0

wait_for_close:
    nsExec::ExecToStack 'tasklist /FI "IMAGENAME eq openfxpedia.exe" /FO CSV /NH'
    Pop $0
    Pop $1
    ${StrStr} $2 $1 '"openfxpedia.exe"'
    StrCmp $2 "" done
    IntOp $3 $3 + 1
    IntCmp $3 10 give_up wait_for_close give_up
    Sleep 500
    Goto wait_for_close

give_up:
    MessageBox MB_OK|MB_ICONSTOP "OpenFXpedia could not be closed. Please close it manually and run the installer again."

cancel:
    Abort

done:
FunctionEnd

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Section "OpenFXpedia" SecMain
    SetShellVarContext current
  SetOutPath "$INSTDIR"
    Delete "$INSTDIR\*.exe"
  File /r "__STAGING_ROOT__\*"
  WriteRegStr HKCU "Software\OpenFXpedia" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenFXpedia" "DisplayName" "OpenFXpedia"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenFXpedia" "DisplayVersion" "__APP_VERSION__"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenFXpedia" "Publisher" "OpenFXpedia"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenFXpedia" "InstallLocation" "$INSTDIR"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenFXpedia" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenFXpedia" "NoModify" 1
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenFXpedia" "NoRepair" 1
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateDirectory "$SMPROGRAMS\OpenFXpedia"
  CreateShortCut "$SMPROGRAMS\OpenFXpedia\OpenFXpedia.lnk" "$INSTDIR\openfxpedia.exe" "" "$INSTDIR\openfxpedia.exe" 0
  CreateShortCut "$SMPROGRAMS\OpenFXpedia\Uninstall OpenFXpedia.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
    SetShellVarContext current
  Delete "$SMPROGRAMS\OpenFXpedia\OpenFXpedia.lnk"
  Delete "$SMPROGRAMS\OpenFXpedia\Uninstall OpenFXpedia.lnk"
  RMDir "$SMPROGRAMS\OpenFXpedia"
    Delete "$INSTDIR\*.exe"
    Delete "$INSTDIR\flutter_windows.dll"
    Delete "$INSTDIR\data\*.*"
    RMDir /r "$INSTDIR\data"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenFXpedia"
  DeleteRegKey HKCU "Software\OpenFXpedia"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir /r "$INSTDIR"
SectionEnd
'@

        $installerScriptContent = $nsiTemplate.Replace('__INSTALLER_EXE__', $installerExe)
        $installerScriptContent = $installerScriptContent.Replace('__STAGING_ROOT__', $stagingRoot)
        $installerScriptContent = $installerScriptContent.Replace('__ICON_PATH__', $iconPath)
        $installerScriptContent = $installerScriptContent.Replace('__APP_VERSION__', $appVersion)

        Set-Content -Path $installerScript -Value $installerScriptContent -Encoding ASCII

        Write-Host '==> Building NSIS installer'
        & $makensisPath $installerScript
        if ($LASTEXITCODE -ne 0) {
            Write-Error "NSIS failed to build the installer (exit code $LASTEXITCODE)."
            exit 5
        }

        if (-not (Test-Path $installerExe)) {
            Write-Error "Expected installer not found: $installerExe"
            exit 5
        }
    }

    Write-Host "Windows build completed ($Mode)."
    Write-Host "Portable EXE: $portableExe"
    if ($Mode -eq 'release') {
        Write-Host "Installer: $installerExe"
    }
}
finally {
    Pop-Location
}
