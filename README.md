# whisper-vulkan-build

Windows 11 + AMD GPU + Vulkan で whisper.cpp をビルドし、日本語 ASR を実行するためのラッパーリポジトリです。whisper.cpp は `third_party/whisper.cpp` の submodule として管理します。

## 必要ツール
- Git
- CMake
- Visual Studio 2022 Build Tools (C++ workload + Windows SDK)
- Vulkan SDK
- AMD GPU Driver
- GitHub CLI (`gh`, Release作成時のみ)

## 初回セットアップ
```powershell
git clone --recursive https://github.com/<your-name>/whisper-vulkan-build.git
cd whisper-vulkan-build
git submodule update --init --recursive
```

## 診断
```powershell
powershell -ExecutionPolicy Bypass -File scripts\diagnose.ps1
```

## 通常ビルド（最新 whisper.cpp 取得あり）
```powershell
powershell -ExecutionPolicy Bypass -File scripts\build-windows-vulkan.ps1
```

## 固定ビルド（更新スキップ）
```powershell
powershell -ExecutionPolicy Bypass -File scripts\build-windows-vulkan.ps1 -SkipUpdate
```

## モデルダウンロード
```powershell
powershell -ExecutionPolicy Bypass -File scripts\download-model.ps1 -Model large-v3-turbo
```

## 日本語 ASR テスト
`samples/test.wav` を配置後:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\test-ja.ps1
```

## Release zip 作成（ローカル）
```powershell
powershell -ExecutionPolicy Bypass -File scripts\package-release.ps1 -Version v0.1.0
```

## GitHub Release 作成（ローカル手動）
初回:
```powershell
gh auth login
```
実行:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\create-github-release.ps1 -Version v0.1.0
```

## GitHub Actions でビルドする
このリポジトリは GitHub Actions で Windows x64 + Vulkan SDK + MSVC による whisper.cpp Vulkan ビルドを実行できます。

注意:
- GitHub Actions の Windows runner には AMD GPU はありません。
- CI では GPU 実行確認ではなく、`-DGGML_VULKAN=1` のビルド成功と `whisper-cli.exe` 生成確認を行います。
- AMD GPU 実行確認はローカル Windows 11 環境で行ってください。

手動実行:
1. GitHub Actions タブを開く
2. **Build Windows Vulkan** を選択
3. **Run workflow**
4. Artifacts から `whisper-vulkan-windows-amd` を取得

tag push で Release 作成:
```powershell
git tag v0.1.0
git push origin v0.1.0
```

Release 添付物:
- `whisper-vulkan-windows-amd-v0.1.0.zip`

zip に含む:
- whisper-cli.exe（または main.exe）
- 必要 DLL
- README.md
- WHISPER_CPP_COMMIT.txt
- scripts/test-ja.ps1
- scripts/diagnose.ps1

zip に含めない:
- models/*.bin, models/*.gguf
- samples/*.wav, *.mp3, *.m4a
- third_party/whisper.cpp のソース全体
- build 中間ファイル

## CodeAgentPersonal / Echo ASR 連携例
```text
WHISPER_CPP_BIN=C:\path\to\whisper-vulkan-build\third_party\whisper.cpp\build-vulkan\bin\Release\whisper-cli.exe
WHISPER_CPP_MODEL=C:\path\to\whisper-vulkan-build\models\ggml-large-v3-turbo.bin
WHISPER_CPP_BACKEND=vulkan
```
