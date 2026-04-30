[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
  $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
  return (Resolve-Path (Join-Path $scriptDir '..')).Path
}

$root = Get-RepoRoot
Set-Location $root

Write-Host 'Initializing submodules...'
git submodule update --init --recursive
if ($LASTEXITCODE -ne 0) { throw 'Failed to initialize submodules. Run: git submodule update --init --recursive' }

$submodulePath = Join-Path $root 'third_party/whisper.cpp'
if (-not (Test-Path $submodulePath)) { throw 'Missing third_party/whisper.cpp. Check submodule configuration.' }

$status = git -C $submodulePath status --porcelain
if ($status) { throw 'Uncommitted changes found in third_party/whisper.cpp. Commit/stash them before update.' }

Write-Host 'Fetching origin...'
git -C $submodulePath fetch origin
if ($LASTEXITCODE -ne 0) { throw 'git fetch origin failed for submodule.' }

$defaultBranch = 'main'
$originHead = git -C $submodulePath symbolic-ref --short refs/remotes/origin/HEAD 2>$null
if ($LASTEXITCODE -eq 0 -and $originHead) {
  $defaultBranch = ($originHead -split '/')[1]
}

Write-Host "Using default branch: $defaultBranch"
git -C $submodulePath checkout $defaultBranch
if ($LASTEXITCODE -ne 0) { throw "Failed to checkout $defaultBranch in submodule." }

git -C $submodulePath pull --ff-only origin $defaultBranch
if ($LASTEXITCODE -ne 0) {
  throw "git pull --ff-only failed. Local divergence or branch mismatch may exist. Inspect third_party/whisper.cpp and resolve manually."
}

$commit = (git -C $submodulePath rev-parse HEAD).Trim()
$updated = (Get-Date).ToUniversalTime().ToString('o')

@"
whisper.cpp repository: https://github.com/ggml-org/whisper.cpp
branch: $defaultBranch
commit: $commit
updated_at: $updated
"@ | Set-Content -Path (Join-Path $root 'WHISPER_CPP_COMMIT.txt') -Encoding UTF8

Write-Host 'Updated WHISPER_CPP_COMMIT.txt'
Get-Content (Join-Path $root 'WHISPER_CPP_COMMIT.txt')
