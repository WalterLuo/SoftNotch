# SoftNotch 自动构建

维护者：Walterluo。

`.github/workflows/softnotch.yml` 替换全部上游工作流：推送到 main、向 main 提交 PR，或在 Actions 页面手动点击 Run workflow，都会先测试再编译 Release，并上传构建产物。

- 构建工具：macOS 15 runner、Xcode 16.4。
- 目标平台：Apple Silicon（arm64）、macOS 14 及以上。暂未验证 Intel。
- 测试：待办日期、排序、完成与删除持久化；音乐状态解析和切换。
- 产物：SoftNotch DMG、ZIP、SHA256SUMS.txt，保留 14 天。
- 权限：只读源码；不需要原作者的密钥或 Apple 证书，不推送代码、不创建公开 Release、不更新 Homebrew 或 Sparkle。
- 下载：GitHub 仓库 → Actions → 成功的运行 → Artifacts。

安装包使用本地临时签名，未经过 Apple 公证；不能视为已签名公证的正式发行版。应用仍保留上游 Sparkle 更新地址，使用本分支时保持自动更新关闭，避免被上游版本替换。正式发布前需另行配置 SoftNotch 的签名、公证和更新服务。

本地执行：

```sh
bash scripts/test.sh
bash scripts/build.sh
```

构建产物位于 `dist/`。脚本沿用 Xcode 中的版本号，不修改源码或自动递增版本号。

GitHub CLI 推送 `.github/workflows` 需要 `workflow` scope；如当前账号缺少此权限，运行 `gh auth refresh -h github.com -s workflow` 并由账号所有者完成 GitHub 授权。首次上传后，需要在仓库 Settings → Actions → General 启用 Actions 才会运行。
