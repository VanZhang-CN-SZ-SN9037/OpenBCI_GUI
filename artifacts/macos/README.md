# macOS arm64 本地导出

与本机 `OpenBCI_GUI-master` 参考工程一致的做法：不修改 OpenBCI_GUI 源码，使用 Processing 4.2 的 Java 模式命令行把 sketch 导出为 macOS arm64 应用，再用 `hdiutil` 打包为 DMG。

## 工具链

- Processing 4.2 macOS aarch64（内置 JVM 17.0.6）
  - 本机路径：`/Users/zdeer/Development/zdeer_works/.tools/processing-4.2/Processing.app`
  - 版本必须选 4.2：4.3 内置 JVM 17.0.8，与参考工程日志中的 17.0.6 不一致
- Xcode Command Line Tools（`codesign`、`lipo`、`hdiutil`）

## 执行

```bash
bash artifacts/macos/export-macos-arm64.sh \
  /Users/zdeer/Development/zdeer_works/.tools/processing-4.2/Processing.app \
  /Users/zdeer/Desktop/OpenBCI_GUI \
  /Users/zdeer/Desktop/OpenBCI_GUI/artifacts/macos/OpenBCI_GUI-v6.0.0-beta.1-macOS-arm64.dmg
```

导出过程使用临时 `user.home` 和临时 sketchbook，不污染本机 `~/Documents/Processing`；应用采用 ad-hoc 签名，DMG 使用 UDZO 压缩。

## 校验

```bash
shasum -a 256 -c artifacts/macos/OpenBCI_GUI-v6.0.0-beta.1-macOS-arm64.dmg.sha256
```

## 启动冒烟测试

从 DMG 挂载应用、校验 arm64/ad-hoc 签名、用隔离的 `user.home` 启动 35 秒，抓取应用自己的 Console 日志后退出：

```bash
bash artifacts/macos/launch-smoke.sh \
  /Users/zdeer/Desktop/OpenBCI_GUI/artifacts/macos/OpenBCI_GUI-v6.0.0-beta.1-macOS-arm64.dmg \
  /Users/zdeer/Desktop/OpenBCI_GUI/artifacts/macos/launch-smoke.log
```

日志应包含 `JVM Version: 17.0.6`、`BrainFlow Version: 5.10.0` 和 `OpenBCI_GUI::Setup: Setup is complete!`。

## 本机构建记录（2026-11-22）

- 分支：`build/macos-arm64-export`
- 输出：`OpenBCI_GUI-v6.0.0-beta.1-macOS-arm64.dmg`（260 MB）
- SHA-256：`f706a18f40818f5845f88bf87eb15bac4da60a6739837c99ae802989b0c884d1`
- 导出应用：`arm64`，ad-hoc 签名，`codesign --verify --deep --strict` 通过
- 总耗时：4 分 36 秒
- 冒烟测试：`Setup is complete!`，BrainFlow 5.10.0、音频加载正常（见 `launch-smoke.log`）

> DMG 体积 260 MB，超过 GitHub 单文件 100 MB 限制，已在 `.gitignore` 中排除；脚本、校验和与冒烟日志进入版本库。

> 本机 DiskImages 服务在某些时段异常慢，单个 `hdiutil create`/`attach` 可能需要 4 分钟以上。这是系统服务延迟，不是死锁；等待即可，不要设置 60 秒级短超时，否则会把正常构建误杀。若长时间无进展，可执行 `hdiutil detach <挂载点> -force` 清理残留挂载后重试。

