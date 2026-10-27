# 版本迁移与兼容边界

2026-10-27，仓库主线更新为当前 Sapphire 衍生的 SoftNotch 源码。应用版本号仍为 `1.0.0`，构建号仍为 `20261016.1`；识别本次源码更新请使用 Git 提交，而不要仅比较应用版本号。

## 两个同名版本

| 项目 | 旧版 | 当前版本 |
| --- | --- | --- |
| 来源 | boring.notch | Sapphire 公开源码及本地修改 |
| 工程 / scheme | `boringNotch.xcodeproj` / `boringNotch` | `SoftNotch.xcodeproj` / `SoftNotch` |
| 应用名称 | SoftNotch.app | SoftNotch.app |
| 数据 | 沿用旧项目的标识与格式 | `com.walterluo.softnotch` 独立命名空间 |
| 主要文档 | 旧版按日期待办、暂存和打包说明 | 当前日历、设置、身份及构建说明 |
| 构建与许可 | 以旧提交内文件为准 | 以当前 `scripts/` 和 `LICENSE` 为准 |

旧版最终主线提交为 [`d1a4137`](https://github.com/WalterLuo/SoftNotch/tree/d1a4137b6c68f5faffbf1c5d2f7bbccf93bc13f2)，其源码、许可证、第三方声明和工作流仍可从该提交查阅。此次更新沿用 Git 历史，不重写旧提交。

## 安装前

1. 退出正在运行的 SoftNotch，以及其他可能重叠的刘海应用。
2. 备份原来的 `SoftNotch.app` 和仍需保留的数据。两个版本虽然标识不同，但应用文件名相同，复制到同一路径会发生覆盖。
3. 从 [GitHub Release](https://github.com/WalterLuo/SoftNotch/releases/tag/v1.0.0) 下载安装包，或从当前源码构建，并按 [构建指南](BUILDING.md) 安装。
4. 首次运行按需要重新授予 macOS 权限并配置服务；旧程序的授权不代表新程序已获授权。

本版本**没有自动数据迁移器**，不会自动读取或转换旧版待办、偏好或文件暂存记录，也不会自动导入 Sapphire 数据。请保留旧数据，不要直接覆盖新版本的设置文件。当前日历功能与旧版按日期待办不是同一数据模型。

## 回退

退出当前版本，恢复备份的旧应用及其对应数据。需要重建旧源码时，请在另一个目录检出上述旧版提交，并按其中的文档操作。当前构建脚本和验证记录不适用于旧源码。

当前 [v1.0.0 Release](https://github.com/WalterLuo/SoftNotch/releases/tag/v1.0.0) 提供 Apple Silicon 安装包，需手动安装；没有提供跨版本自动更新或数据转换工具。
