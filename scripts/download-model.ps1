[CmdletBinding()]
param(
  [string]$Model = 'large-v3-turbo',
  [switch]$Force
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
$destDir = Join-Path $root 'models'
$destModel = Join-Path $destDir ("ggml-$Model.bin")
if ((Test-Path $destModel) -and -not $Force) { Write-Host "Model already exists: $destModel"; exit 0 }

$cmd = Join-Path $root 'third_party/whisper.cpp/models/download-ggml-model.cmd'
if (-not (Test-Path $cmd)) { throw 'download-ggml-model.cmd not found. Initialize submodule first.' }

Push-Location (Split-Path $cmd -Parent)
cmd /c "download-ggml-model.cmd $Model"
if ($LASTEXITCODE -ne 0) { Pop-Location; throw 'Model download failed.' }
Pop-Location

$source = Join-Path $root "third_party/whisper.cpp/models/ggml-$Model.bin"
if (-not (Test-Path $source)) { throw "Downloaded model not found: $source" }
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
Copy-Item $source $destModel -Force
Write-Host "Model ready: $destModel"
