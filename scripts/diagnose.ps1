[CmdletBinding()] param()
$ErrorActionPreference = 'Continue'
$root = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path

function Check-Cmd([string]$name){ if (Get-Command $name -ErrorAction SilentlyContinue) {"OK: $name"} else {"MISSING: $name"} }
Check-Cmd git
Check-Cmd cmake
Check-Cmd cl
if ($env:VULKAN_SDK) { "OK: VULKAN_SDK=$env:VULKAN_SDK" } else { 'MISSING: VULKAN_SDK' }
if (Test-Path (Join-Path $root 'third_party/whisper.cpp')) { 'OK: submodule path exists' } else { 'MISSING: third_party/whisper.cpp' }
if (Test-Path (Join-Path $root 'WHISPER_CPP_COMMIT.txt')) { 'OK: WHISPER_CPP_COMMIT.txt exists' } else { 'MISSING: WHISPER_CPP_COMMIT.txt' }
Get-ChildItem -Recurse (Join-Path $root 'third_party/whisper.cpp/build-vulkan') -Filter '*.exe' -ErrorAction SilentlyContinue | Select-Object -First 5 FullName
Get-ChildItem (Join-Path $root 'models') -Filter 'ggml-*.bin' -ErrorAction SilentlyContinue | Select-Object Name
if (-not (Test-Path (Join-Path $root 'samples/test.wav'))) { 'MISSING: samples/test.wav' }
'Next steps: git submodule update --init --recursive; powershell -ExecutionPolicy Bypass -File scripts\build-windows-vulkan.ps1; powershell -ExecutionPolicy Bypass -File scripts\download-model.ps1 -Model large-v3-turbo'
