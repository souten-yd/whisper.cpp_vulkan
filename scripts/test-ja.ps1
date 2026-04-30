[CmdletBinding()]
param(
  [string]$Audio = 'samples/test.wav',
  [string]$Model = 'models/ggml-large-v3-turbo.bin'
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
$buildDir = Join-Path $root 'third_party/whisper.cpp/build-vulkan'
$exe = Get-ChildItem -Recurse $buildDir -Filter 'whisper-cli.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $exe) { $exe = Get-ChildItem -Recurse $buildDir -Filter 'main.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 }
if (-not $exe) { throw 'Executable not found. Run scripts\build-windows-vulkan.ps1 first.' }
$modelPath = Join-Path $root $Model
$audioPath = Join-Path $root $Audio
if (-not (Test-Path $modelPath)) { throw "Model not found: $modelPath. Run scripts\download-model.ps1 -Model large-v3-turbo" }
if (-not (Test-Path $audioPath)) { throw "Audio not found: $audioPath. Place samples\test.wav or pass -Audio." }
Write-Host "exe: $($exe.FullName)"; Write-Host "model: $modelPath"; Write-Host "audio: $audioPath"
& $exe.FullName -m $modelPath -f $audioPath -l ja
