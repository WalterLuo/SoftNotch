# 构建、测试与本地打包

本指南对应当前 Sapphire 衍生 SoftNotch。主工程为 `SoftNotch.xcodeproj`，scheme 为 `SoftNotch`，应用版本为 1.0.0，构建号为 20261016.1。旧版 boring.notch 工程的构建步骤见历史提交，不适用于当前目录结构。

## 环境与兼容范围

2026-10-27 的 Release 构建通过环境：

| 项目 | 环境 |
| --- | --- |
| 主机架构 | Apple Silicon / arm64 |
| 系统 | macOS 27.0.1 |
| Xcode | 27.1（27A9275） |
| 构建配置 | Release，启用 testability，构建阶段禁用签名 |
| 项目部署目标 | macOS 14.6 |

需要完整 Xcode，单独安装 Command Line Tools 不够。源码使用 `SpeechTranscriber`、`SpeechAnalyzer` 等较新的 SDK 接口，因此不能假定任意版本的 Xcode 都能编译；使用上述已验证工具链最便于复现。

随附的 `MediaRemoteAdapter.framework` 在 Mach-O 中声明最低系统为 **macOS 26.0**。工程的 14.6 部署目标与该二进制依赖的要求不同，该框架由媒体适配器动态加载，旧系统的媒体功能尚未验证。旧系统和 Intel 构建均未完成本轮实机验证；不要仅修改部署目标就视为兼容性已经解决。

## 获取与编译

```sh
git clone https://github.com/WalterLuo/SoftNotch.git
cd SoftNotch
open SoftNotch.xcodeproj
scripts/build.sh
```

`scripts/build.sh` 默认使用 `/Applications/Xcode.app/Contents/Developer`，以 `platform=macOS,arch=arm64` 构建。Xcode 位于其他位置时，可设置 `DEVELOPER_DIR`：

```sh
DEVELOPER_DIR=/Applications/Xcode-27.1.app/Contents/Developer scripts/build.sh
```

默认产物位于 `build/DerivedData/Build/Products/Release/SoftNotch.app`。此时尚未执行本地发行包签名；打包步骤见下文。`build/` 与 `dist/` 均不进入版本管理。

首次构建需要联网获取 SwiftPM 依赖，版本由工程中的 `Package.resolved` 固定。已有对应依赖缓存时，可复用完整的 `SourcePackages` 目录：

```sh
SOFTNOTCH_PACKAGE_CACHE=/path/to/SourcePackages scripts/build.sh
```

设置该变量会同时启用 `-disableAutomaticPackageResolution` 和 `-skipPackageUpdates`。缓存必须包含锁定版本所需的 checkout 和二进制产物；缓存不完整或过期时，去掉该变量后重新解析依赖。不要提交 `SourcePackages` 缓存。

## 验证

先检查源码身份、中英文本地化 key / 格式占位符和图标文件：

```sh
python3 scripts/verify-branding.py
```

以下命令运行本项目当前关注的四组自动化测试：

```sh
scripts/build.sh test \
  -only-testing:SoftNotchTests/SoftNotchIdentityTests \
  -only-testing:SoftNotchTests/CalendarViewModelTests \
  -only-testing:SoftNotchTests/CalendarVisibilityFilterTests \
  -only-testing:SoftNotchTests/FileDragPasteboardTests
```

测试同样支持 `SOFTNOTCH_PACKAGE_CACHE`。这些测试覆盖身份与更新隔离、日历日期及可见性逻辑、文件拖拽剪贴板行为；它们不等同于全套测试或系统权限、辅助程序、音乐服务与设备集成的实机验证。2026-10-27 复用已有依赖缓存与 DerivedData 的 Release 构建和 22 项选定测试已通过；这不属于从空缓存开始的干净构建。具体记录见 [VALIDATION.md](VALIDATION.md)。

需要检查的人工路径包括：关闭并重新展开面板后的日历选中日期、跨日/时区变化、截图到目标应用的粘贴、语言切换、辅助程序连接，以及实际使用的音乐、天气、蓝牙和多屏场景。按功能需要在系统设置中授权。

## 签名与打包

先完成 Release 构建，再运行：

```sh
scripts/package.sh
```

脚本会：

1. 将应用复制到本地临时目录，避免云同步目录附加的 Finder 元数据干扰签名。
2. 移除开发用测试 bundle，并随应用打包 `LICENSE` 与 `CREDITS.md`。
3. 调用 `scripts/sign-local.py`，为主程序及辅助程序使用同一本地签名身份。
4. 验证应用身份与签名，生成 ZIP 和 SHA-256 文件。

输出：

- `dist/SoftNotch-1.0.0-macOS-arm64.zip`
- `dist/SHA256SUMS`

可在仓库根目录校验压缩包：

```sh
shasum -a 256 -c dist/SHA256SUMS
```

首次签名会在 `~/Library/Application Support/SoftNotchLocalSigning/` 创建专用钥匙串及签名材料，后续打包复用该身份。私钥和密码保留在该本机目录，不进入仓库；脚本不修改系统证书信任。请不要把该目录附到 issue、日志或提交中。

这些包是本地签名构建，未经 Apple Developer ID 公证。本轮 GitHub 更新同步源码及文档，没有发布新的二进制 Release。

## 手动安装与更新

解压 ZIP，将 `SoftNotch.app` 放入 `/Applications`。如果已有同名应用，先退出并备份现有应用，再安装新构建。首次启动遵循 macOS 的安全提示，并按使用需要授予辅助功能、屏幕录制、日历等权限。电池温度及充电控制还需要允许 SoftNotch Helper 在后台运行。

也可让打包脚本执行首次安装：

```sh
SOFTNOTCH_INSTALL=1 scripts/package.sh
```

该选项在 `/Applications/SoftNotch.app` 已存在时会停止，不会替用户覆盖已有安装。

应用未接入自动更新源；源码更新后需要重新构建、打包和安装。当前应用不会自动导入旧版 boring.notch 衍生 SoftNotch 或 Sapphire 的数据，详见 [MIGRATION.md](MIGRATION.md)。

## 服务配置与公开源码边界

仓库不包含开发者的私有服务凭据。Google 服务配置和天气私有配置已列入 `.gitignore`；保留的占位配置不代表服务已经可用。MusicKit 等服务需要使用者自己的授权与配置，签名密钥、开发者令牌和用户令牌应保存在仓库外，也不应进入构建日志。

当前构建禁用上游自动更新、Google Analytics 与 Crashlytics 收集。公开源码没有提供完整的账户、订阅、部分高级功能与系统扩展实现；相应入口可能隐藏或保留占位。启用 `SOFTNOTCH_FULL_BUILD` 不能补齐缺失实现，也不能证明功能可用。

GitHub 自动检查和可选手动构建见 [WORKFLOWS.md](WORKFLOWS.md)，贡献约定见 [CONTRIBUTING.md](../CONTRIBUTING.md)。
