$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptDir '..')

Set-Location $projectRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter n''est pas disponible dans PATH. Installez Flutter puis relancez ce script.'
}

Write-Host 'Construction de l''application Windows en mode release...'
flutter build windows --release

if (-not (Get-Command iscc.exe -ErrorAction SilentlyContinue)) {
    throw 'Inno Setup n''est pas installé. Installez Inno Setup puis relancez ce script.'
}

New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot 'windows/installer/dist') | Out-Null

Write-Host 'Génération de l''installeur Windows...'
iscc.exe (Join-Path $projectRoot 'windows/installer/PharmaOne.iss')

Write-Host "Installeur produit dans : $projectRoot/windows/installer/dist"
