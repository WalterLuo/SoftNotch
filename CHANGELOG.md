# 变更记录

## v1.0.0 — 2026-10-27

当前 Sapphire 衍生版首次通过 GitHub Release 提供 Apple Silicon / arm64 安装包。应用版本为 **1.0.0 / 20261016.1**。

- 发布 `SoftNotch-1.0.0-macOS-arm64.zip` 和 `SHA256SUMS`，附安装、校验及兼容范围说明。
- 包含日历每次重新展开回到今天的修复，同时保留面板持续展开时浏览其他日期的行为。
- 提供独立的主程序与辅助程序身份、默认简体中文及 English 设置、快捷截图和现有公开源码功能。
- 本地签名，未做 Apple Developer ID 公证；未启用自动更新，也不自动迁移旧版数据。

下载与完整说明见 [GitHub Release](https://github.com/WalterLuo/SoftNotch/releases/tag/v1.0.0) / [仓库内发行说明](docs/releases/v1.0.0.md)。

## 2026-10-27 — GitHub 源码同步

应用版本仍为 **1.0.0 / 20261016.1**；本次是源码与文档同步，不是新的二进制发行版。

- 仓库主线更新为当前 Sapphire 衍生工程，保留此前 boring.notch 版本的 Git 历史。
- 同步独立应用与辅助程序身份、中文默认设置、English 切换、快捷截图和本地构建 / 签名 / 打包脚本。
- 包含日历重新展开回到今天的修复：每次展开重新读取本地日期及时区，持续展开时允许浏览其他日期；附相关回归测试。
- 更新 README、应用使用说明、产品与设计约束、贡献和安全反馈入口。
- 新增构建与安装、版本迁移说明；验证记录区分本次检查和此前的签名、安装及界面检查。

来源基线于 2026-10-16 建立；该基线的验证见 [历史记录](docs/VALIDATION.md)。旧 boring.notch 版的改动请查阅 [旧版提交](https://github.com/WalterLuo/SoftNotch/commits/d1a4137b6c68f5faffbf1c5d2f7bbccf93bc13f2)。
