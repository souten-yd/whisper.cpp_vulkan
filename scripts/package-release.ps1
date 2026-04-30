[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Version)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
$buildDir = Join-Path $root 'third_party/whisper.cpp/build-vulkan'
$exe = Get-ChildItem -Recurse $buildDir -Filter 'whisper-cli.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $exe) { $exe = Get-ChildItem -Recurse $buildDir -Filter 'main.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 }
if (-not $exe) { throw 'Executable not found in build-vulkan.' }
$staging = Join-Path $root 'release'
if (Test-Path $staging) { Remove-Item -Recurse -Force $staging }
New-Item -ItemType Directory -Force -Path (Join-Path $staging 'scripts') | Out-Null
Copy-Item $exe.FullName $staging -Force
Get-ChildItem $exe.DirectoryName -Filter '*.dll' -ErrorAction SilentlyContinue | ForEach-Object { Copy-Item $_.FullName $staging -Force }
Copy-Item (Join-Path $root 'README.md') $staging -Force
Copy-Item (Join-Path $root 'WHISPER_CPP_COMMIT.txt') $staging -Force
Copy-Item (Join-Path $root 'scripts/test-ja.ps1') (Join-Path $staging 'scripts') -Force
Copy-Item (Join-Path $root 'scripts/diagnose.ps1') (Join-Path $staging 'scripts') -Force
$zip = Join-Path (Join-Path $root 'dist') "whisper-vulkan-windows-amd-$Version.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $zip -Force
Write-Host "Created $zip"
