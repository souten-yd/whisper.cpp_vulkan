[CmdletBinding()]
param(
  [switch]$SkipUpdate
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
Set-Location $root

if (-not $SkipUpdate) {
  & (Join-Path $root 'scripts/update-whisper.ps1')
}

if (-not $env:VULKAN_SDK) {
  Write-Warning 'VULKAN_SDK is not set. Install Vulkan SDK and reopen PowerShell.'
}

$buildDir = Join-Path $root 'third_party/whisper.cpp/build-vulkan'
if (Test-Path $buildDir) { Remove-Item -Recurse -Force $buildDir }

cmake -S third_party/whisper.cpp -B third_party/whisper.cpp/build-vulkan -G "Visual Studio 17 2022" -A x64 -DGGML_VULKAN=1 -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF
if ($LASTEXITCODE -ne 0) { throw 'CMake configure failed.' }

cmake --build third_party/whisper.cpp/build-vulkan --config Release -j
if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }

$exe = Get-ChildItem -Recurse $buildDir -Filter 'whisper-cli.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $exe) { $exe = Get-ChildItem -Recurse $buildDir -Filter 'main.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 }
if (-not $exe) { throw 'whisper-cli.exe/main.exe not found after build. Run diagnose.ps1.' }
Write-Host "Built executable: $($exe.FullName)"
if (Test-Path WHISPER_CPP_COMMIT.txt) { Get-Content WHISPER_CPP_COMMIT.txt }
