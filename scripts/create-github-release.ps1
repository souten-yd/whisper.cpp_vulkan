[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Version)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
Set-Location $root
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw 'gh CLI not found. Install GitHub CLI and run gh auth login.' }
$zip = Join-Path $root "dist/whisper-vulkan-windows-amd-$Version.zip"
if (-not (Test-Path $zip)) { throw "Missing release zip: $zip" }
if (-not (Test-Path (Join-Path $root 'WHISPER_CPP_COMMIT.txt'))) { throw 'Missing WHISPER_CPP_COMMIT.txt' }
$dirty = git status --porcelain
if ($dirty) { throw 'Working tree is not clean. Commit or stash changes before release.' }
$tagExists = git tag --list $Version
if ($tagExists) { throw "Tag already exists: $Version" }
$commit = (Select-String -Path WHISPER_CPP_COMMIT.txt -Pattern '^commit:' | ForEach-Object { $_.Line.Split(':')[1].Trim() })
$notes = @"
Windows AMD Vulkan build of whisper.cpp.

Backend: Vulkan
Build: Windows x64, Visual Studio 2022, GGML_VULKAN=1
Included: whisper-cli.exe, helper scripts, WHISPER_CPP_COMMIT.txt
Not included: Whisper model files, audio samples
whisper.cpp source:
Repository: https://github.com/ggml-org/whisper.cpp
Commit: $commit
"@
git tag $Version
git push origin $Version
gh release create $Version $zip --title $Version --notes $notes
