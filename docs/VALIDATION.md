# SoftNotch 1.0.0 验证记录

## 2026-10-27 — v1.0.0 Release 打包验证

沿用下方已验证的运行时代码，重新完成 Release / arm64 构建、本地签名和 ZIP 打包。版本为 `1.0.0`，构建号为 `20261016.1`；本轮打包脚本新增移除测试调试符号，并使 SHA-256 文件使用安装包文件名，便于下载后直接校验。

- `scripts/build.sh` 构建成功；`SOFTNOTCH_INSTALL=0 scripts/package.sh` 打包成功，没有覆盖本机已安装应用。
- ZIP CRC 与 SHA-256 校验通过；ZIP 解压后的应用通过 `codesign --verify --deep --strict`。签名校验在可访问 macOS 安全服务的正常执行环境下完成。
- 主程序与辅助程序均使用 `SoftNotch Local Development` 签名身份；没有修改系统证书信任，未做 Developer ID 公证。
- 主程序为 arm64，应用身份、版本、链接协议与源码一致；媒体框架符号链接完整。
- 包内不含测试 bundle、测试 dSYM 或私有签名材料。`LICENSE`、`CREDITS.md`、`SoftNotch-Guide.txt` 与当前源文件逐字节一致，Firebase 配置与仓库占位文件一致。
- 同一运行时代码此前的 22 项选定测试通过结果继续适用；本轮未新增 GUI、旧系统、设备或在线集成实测。

资产为 `SoftNotch-1.0.0-macOS-arm64.zip`（122,945,276 字节）及 `SHA256SUMS`，详见 [发行说明](releases/v1.0.0.md) 和 [机器可读验证记录](release-verification-v1.0.0.json)。本地日志：`build/release-v1.0.0-build-20261027.log`、`build/release-v1.0.0-package-20261027.log`。下面的源码同步记录与 10 月 16 日记录按原时间范围保留。

## 2026-10-27 — GitHub 同步前验证

环境：Apple Silicon / arm64，macOS 27.0.1（26A434），Xcode 27.1（27A9275），macOS SDK 27.0。应用版本 `1.0.0`，构建号 `20261016.1`。

- Release 构建成功，退出码 0。复用已有 SwiftPM 缓存与 DerivedData，未进行空缓存构建。
- **22 项选定测试全部通过，0 失败、0 跳过**，结果经 `xcresulttool` 回查：独立身份 4、日历模型 8、日历可见性筛选 6、文件拖拽 4。
- 日历模型测试包含再次打开回到今天、漏掉日期通知后的校正、漏掉时区通知后的校正；这属于模型自动化测试，本轮没有操作刘海面板复验。
- `scripts/verify-branding.py` 通过：独立身份、1,684 个中英文 key、格式占位符、10 个图标文件。
- `bash -n scripts/build.sh scripts/package.sh` 通过。

命令：

```sh
SOFTNOTCH_PACKAGE_CACHE=/absolute/path/to/SourcePackages scripts/build.sh
SOFTNOTCH_PACKAGE_CACHE=/absolute/path/to/SourcePackages scripts/build.sh test \
  -only-testing:SoftNotchTests/SoftNotchIdentityTests \
  -only-testing:SoftNotchTests/CalendarViewModelTests \
  -only-testing:SoftNotchTests/CalendarVisibilityFilterTests \
  -only-testing:SoftNotchTests/FileDragPasteboardTests \
  -resultBundlePath build/github-tests-20261027.xcresult
python3 scripts/verify-branding.py
bash -n scripts/build.sh scripts/package.sh
```

构建保留既有警告：两个扩展的版本 `2.9` 与主程序 `1.0.0` 不一致；未指定签名身份时跳过 helper 重签；无 AppIntents 依赖的目标跳过元数据提取。测试 dSYM 生成还有过期 XCTest 模块缓存提示，未阻止测试通过。

工程部署目标为 macOS 14.6，但随附 `MediaRemoteAdapter.framework` 的二进制最低系统为 macOS 26.0（arm64 与 x86_64 均经 `otool -l` 检查）。该框架由媒体适配器动态加载；不能将主程序部署目标视为全部媒体功能在旧系统可用的保证。旧系统、Intel、设备集成和在线服务本轮均未实测。

本轮没有签名、打包、安装、授予系统权限或进行 GUI 交互复验，也未发布二进制 Release。下列 2026-10-16 的签名、安装与截图结果仅代表当时的应用，不能用于证明本次源码产物已经过相同步骤。

本地日志（不提交）：`build/github-release-build-20261027.log`、`build/github-tests-20261027.log`、`build/github-tests-20261027.xcresult`、`build/github-tests-20261027-summary.json`。本轮可共享摘要见 [verification-20261027.json](verification-20261027.json)。

## 2026-10-16 — 历史验证

日期：2026-10-16（Asia/Shanghai）。构建：20261016.1。平台：本机 Apple Silicon macOS，Release / arm64。

### 已通过

- 完整 Xcode Release 编译成功，源码保留上游既有的编译警告。
- 14 个选定自动化测试通过：4 个独立身份/更新隔离/默认配置/本地化测试、6 个日历可见性筛选测试、4 个文件拖拽剪贴板测试。不是全量测试套件通过声明。
- 1,684 条中英文本地化 key 一致，格式占位符一致；10 个独立 AppIcon 尺寸齐全。
- 主程序 `com.walterluo.softnotch` 与辅助程序 `com.walterluo.softnotchHelper` 使用同一 SoftNotch Local Development 证书；身份验证逻辑保留。
- 本机签名的 /Applications/SoftNotch.app 以及最终 ZIP 解压结果均通过 `codesign --verify --deep --strict`。
- 安装文件与 ZIP 中的主程序 SHA-256 相同；原始 LICENSE 和 CREDITS.md 完整随应用打包；开发用 xctest bundle 不进入发行包。
- 媒体框架符号链接完整。实际启动无动态库加载错误，首次欢迎界面显示 SoftNotch 及新图标。
- CUA 实际检查中文设置、切换 English、恢复简体中文；关于页面显示版本 1.0.0、Walter Luo 个人版、原项目署名、使用说明及手动更新说明。

### 测试基线修复

原源码的 AppsSettingsRevampTests.swift 有 4 条被截断的 JSON 字符串，已补齐使测试目标可编译。SystemEnhanceHingeAnimationTests 引用了公开源码未提供的私有类型，现仅在 SOFTNOTCH_FULL_BUILD 构建下编译；没有用假实现替代这些类型。

### 当时的待验证事项与边界

首次引导等待 macOS 辅助功能授权，Continue 因未授权而禁用。可用 Command + , 打开设置。本次没有代用户授予辅助功能、屏幕录制、完全磁盘访问或其他敏感权限，也没有修改 TCC 数据库。

未完成首次引导，因此刘海实际运行、音乐控制、窗口贴靠、系统辅助程序连接/电池控制、截图到剪贴板、锁屏、多屏、在线服务与 Android 设备功能均未逐项实机验证。相应代码已继承，不能把编译和单元测试当成这些功能已正常的证明。

原公开源码缺失的账户、订阅和部分高级功能仍是占位实现；不宣称复刻官方商业版全部功能。应用为本地签名，未进行 Apple Developer ID 公证。

### 历史输出

- 安装应用：/Applications/SoftNotch.app
- 安装包：dist/SoftNotch-1.0.0-macOS-arm64.zip
- 校验：dist/SHA256SUMS；机器可读结果 docs/verification.json。
- 记录：build/release-build.log、build/tests.log、build/package.log（本地构建目录，不进入版本管理）。
- 实际界面：docs/screenshots/softnotch-welcome.png、softnotch-settings-zh.png、softnotch-about-zh.png。
