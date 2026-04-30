# AGENTS

- This repository is for Windows + AMD GPU + Vulkan + whisper.cpp build workflows.
- ROCm / CUDA / DirectML additions are out of scope.
- Avoid large modifications to whisper.cpp itself.
- Manage whisper.cpp as a git submodule.
- Do not commit model files or audio sample files.
- PowerShell scripts should work in both Windows PowerShell and PowerShell 7.
- Error messages must explain next steps for users.
- Keep build and release responsibilities separate.
- Build scripts must never create tags or GitHub Releases automatically.
- Only `scripts/create-github-release.ps1` should create tags/releases when explicitly executed.

## CI policy
- GitHub Actions performs Windows-runner Vulkan-enabled builds.
- GitHub Actions does not perform AMD GPU runtime validation.
- CI validates successful `-DGGML_VULKAN=1` build and `whisper-cli.exe` (or `main.exe`) generation.
- Release assets must not include model files or audio sample files.
- GitHub Release creation from CI is only on tag push (`v*`).
- `workflow_dispatch` runs build/package and artifact upload only.
