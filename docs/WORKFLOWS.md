# GitHub 检查流程

当前配置：[`.github/workflows/softnotch.yml`](../.github/workflows/softnotch.yml)。

## 自动检查

推送到 `main` 或向 `main` 提交 Pull Request 时，macOS runner 检查：

- 主程序与辅助程序的独立身份。
- 中英文 key、格式占位符及图标文件。
- 构建与打包脚本语法、Xcode project、scheme 和 SwiftPM 锁定文件。
- 仓库内符号链接的目标完整性。

绿色的 `source-checks` 仅表示上述静态检查通过，不能代表编译、单元测试或实机功能已通过。

## 手动构建

在仓库 [Actions](https://github.com/WalterLuo/SoftNotch/actions) 中选择 **SoftNotch source checks → Run workflow**，勾选 `full_build`，并指定合适的 macOS runner 标签。默认标签为 `macos-latest`。

构建任务要求 Apple Silicon / arm64，并使用 runner 当前选择的 Xcode。默认 runner 的 Xcode 由 GitHub 管理，可能与本地工具链不同；本地验证使用 Xcode 27.1，手动云端构建是否可行取决于当次 runner 的 SDK 和依赖解析结果。任务会记录架构、macOS、Xcode 和 SDK 版本，架构不符时明确失败。

启用后执行 Release 构建及 [BUILDING.md](BUILDING.md) 中的四组选定测试，诊断日志保存为 Actions artifact，保留 14 天。此任务不运行本地证书创建、签名、安装或打包，也不发布 GitHub Release。

## 与旧版的区别

此前 boring.notch 版工作流使用 Xcode 16.4、`scripts/test.sh` 和旧的 DMG / ZIP 脚本，这些不适用于当前 Sapphire 衍生工程。旧工作流随 [旧版提交](https://github.com/WalterLuo/SoftNotch/tree/d1a4137b6c68f5faffbf1c5d2f7bbccf93bc13f2) 保留。

当前安装包按构建指南在本机生成、签名和校验后，上传到 [GitHub Release](https://github.com/WalterLuo/SoftNotch/releases/tag/v1.0.0)。Actions 日志 artifact 不是安装包；工作流成功也不会自动发布新的 Release。
