# 工作报告

Agent 基础设施相关的方案、汇报、实测和调研，每篇都是自包含的单页 HTML。

在线浏览：<https://zhchxiao123.github.io/work-reports/>

## 结构

- `*.html`：各篇报告，平铺在根目录，文件名即地址。
- `pages.json`：首页目录的唯一来源（分组、标题、摘要、日期、旧版本）。
- `index.html`：由 `tools/build_index.py` 根据 `pages.json` 生成，不要手改。
- `tools/add_home_link.py`：给缺少返回首页链接的页面补上（发布时自动运行）。
- `tools/scan.sh`：发布前的脱敏检查（服务器地址、凭据、内部路径、用户标识）。
- `tools/publish.sh`：复制草稿 → 检查 → 生成首页 → 提交并推送。

## 发布一篇

1. 在 `pages.json` 里加一条记录（同一主题的新版本：新文件放 `file`，旧文件挪进 `older`）。
2. `tools/publish.sh -m "说明" path/to/draft.html`

检查不通过就不会提交。研究页里引用的第三方公开 IP 加到 `scan.sh` 的 `ALLOW`。

## 来源

2026-11-08 由两个旧站点合并而来，旧地址已改为跳转到这里：

- `zhchxiao123.github.io/dsh-cubesandbox-platform/`（原 `gh-pages` 分支，取自提交 `537f3ae`）
- `zhchxiao123.github.io/muse-analysis/`（取自提交 `b6a3af0`，页面加了 `muse-` 前缀）

页面中的服务器地址、用户账号和主机路径在合并时做了脱敏。
