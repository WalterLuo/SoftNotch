# SoftNotch

由 Walterluo 制作提供。

版本：1.0.0 · 版本名称：噗噗噗💨

macOS 刘海面板，提供音乐控制、按日期管理的待办、截屏、文件暂存与隔空投送。

## 构建

使用 Xcode 打开 `boringNotch.xcodeproj`，选择 `boringNotch` scheme 构建。应用产物为 `SoftNotch.app`。

沿用原 bundle identifier 和数据目录，保留已有设置、待办与暂存记录。

## 开源来源

基于 boring.notch 修改。参见 [来源记录](docs/UPSTREAM_ATTRIBUTIONS.md)、[原项目说明](docs/UPSTREAM_README.md)、[LICENSE](LICENSE) 与 [第三方许可证](THIRD_PARTY_LICENSES)。

## 自动构建与安装包

推送或提交 PR 后自动测试并生成 Apple 芯片版本，也可在 Actions 页面手动运行。构建产物包含 DMG、ZIP 和 SHA-256 校验值，保留 14 天。安装包使用临时签名，未经过 Apple 公证。

详见 [工作流说明](docs/WORKFLOWS.md)。
