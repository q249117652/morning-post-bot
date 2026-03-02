# 公众号早安文案自动生成器（元气补给站风格）

基于 Claude Code Skills 的全自动微信公众号早安文案生成与发布系统。

**定位**：朋友圈文案供应商——用户不是来"阅读"的，而是来**拿走使用**的。

## 项目结构

```
~/.claude/skills/morning-post-bot/
  SKILL.md                    # Claude Code 技能定义（核心，含完整写作风格指南）

~/morning-posts/
  scripts/
    run_morning_post.sh       # 自动化触发脚本（Crontab 调用）
  covers/
    default.jpg               # 默认封面图（需自行放置）
  post_2026-03-02.md          # 自动生成的文案（按日期命名）
  publish_log.txt             # 发布日志
```

## 生成内容风格

- 每篇 6-10 条可直接复制发朋友圈的短文案
- 标题带利益钩子（"照着抄，你的朋友圈会被翻烂~"🧡）
- 开头使用特殊装饰字体（ᴳᴼᴼᴰ ᴹᴼᴿᴺᴵᴺᴳ☼）
- 每条文案 2-4 句短句，口语化，有节奏感
- 内置 AI 去痕引擎（禁用词表 + 结构性检查 + 口语化处理）
- 结尾固定互动引导语（点赞关注类）
- 支持 6 种文案类型：早安励志、治愈鸡汤、节气季节、朋友圈合集、节日、情感共鸣

## 安装步骤

### 1. 安装依赖

```bash
# 安装 Node.js（如未安装）
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装 wenyan-cli
npm install -g @wenyan-md/cli

# 验证安装
wenyan --help
```

### 2. 配置微信公众号

登录 [微信公众平台](https://mp.weixin.qq.com/) 获取以下信息：

```bash
# 将以下内容添加到 ~/.bashrc 或 ~/.profile
export WECHAT_APP_ID="你的AppID"
export WECHAT_APP_SECRET="你的AppSecret"

# 使配置生效
source ~/.bashrc
```

**IP 白名单配置**：在公众号后台 - 开发 - 基本配置 - IP白名单，添加运行脚本的服务器 IP。

如果你没有固定 IP，请使用 wenyan-cli 的远程 Server 模式（见下方说明）。

### 3. 准备封面图

```bash
# 将你的默认封面图放入 covers 目录（建议 900x383px）
cp 你的封面图.jpg ~/morning-posts/covers/default.jpg
```

如果没有封面图也没关系，wenyan-cli 会自动使用文章中的第一张图片作为封面。

### 4. 配置定时任务

```bash
# 编辑 Crontab
crontab -e

# 添加以下行（每天 18:00 执行，生成次日早安推文）
0 18 * * * /bin/bash /root/morning-posts/scripts/run_morning_post.sh >> /root/morning-posts/cron_output.log 2>&1
```

> 最佳实践：提前一天晚上生成，设置次日早上 6:00-6:15 定时发布

## 使用方式

### 方式一：自动执行（推荐）

配置好 Crontab 后，系统每天 18:00 自动运行，无需人工干预。

### 方式二：手动执行

```bash
# 直接运行脚本
bash ~/morning-posts/scripts/run_morning_post.sh

# 或在 Claude Code 中手动触发
claude -p "请使用 morning-post-generator 技能，生成明天的早安公众号推文"
```

### 方式三：Claude Code 交互模式

在 Claude Code 对话中输入：

```
请生成明天的早安公众号推文
```

## wenyan-cli 主题配置

```bash
# 查看所有可用主题
wenyan theme -l

# 添加自定义主题
wenyan theme --add --name my-theme --path ./custom-theme.css

# 在脚本中使用指定主题（编辑 run_morning_post.sh 中的 WENYAN_THEME 变量）
WENYAN_THEME="lapis"
```

## 远程 Server 模式（无固定 IP 时使用）

如果你的运行环境 IP 不固定，可以部署 wenyan-cli Server 到云服务器：

### 在云服务器上部署 Server

```bash
# 方式一：直接运行
npm install -g @wenyan-md/cli
export WECHAT_APP_ID="你的AppID"
export WECHAT_APP_SECRET="你的AppSecret"
wenyan serve -p 3000 --api-key "设置一个安全的密钥"

# 方式二：Docker 部署
docker run -d \
  -e WECHAT_APP_ID="你的AppID" \
  -e WECHAT_APP_SECRET="你的AppSecret" \
  -p 3000:3000 \
  caol64/wenyan-cli serve --api-key "你的密钥"
```

### 修改脚本配置

编辑 `run_morning_post.sh`，取消以下注释并填入实际值：

```bash
WENYAN_SERVER="https://你的服务器地址:3000"
WENYAN_API_KEY="你设置的密钥"
```

## 生成文案示例

以下是系统自动生成的一篇早安文案（元气补给站风格）：

```markdown
---
title: "照着抄，你的朋友圈会被翻烂~"🧡
cover: ~/morning-posts/covers/default.jpg
author: 元气补给站
---

# ᴳᴼᴼᴰ ᴹᴼᴿᴺᴵᴺᴳ☼

[图片]

---

## 01

别焦虑，沉住气。
你只是在成长的路上，
不是在走投无路的巷子里。
☀️早安～

[图片]

---

## 02

搞钱这件事，
从来没有不辛苦的选项。
但你可以选择辛苦之后，
对自己好一点 ☕

[图片]

---

## 03

我觉得吧，
心态好了，啥事都顺。
实在不顺……
那就先喝杯奶茶再说 🧡

[图片]

---

## 04

有些路，走着走着就亮了。
有些人，处着处着就散了。
但你还在，就很好。

[图片]

---

## 05

降温了❄️
出门记得裹严实点～
热乎乎的奶茶安排上☕

[图片]

---

## 06

> 没人扶你的时候，自己站直。
> 路还长，背影要美 ✨

[图片]

---

💖点个赞赞，好运不断，点个小心心，天天都开心~

☀️元气补给站 承包你朋友圈所有文案
```

## 选题日历

| 星期 | 选题方向 |
|------|----------|
| 周一 | 新的一周，元气满满（周一专属激励） |
| 周二 | 周二愉快，小日子继续 |
| 周三 | 周三，一周过半加油 |
| 周四 | 快到周末了，再坚持一下 |
| 周五 | 周五快乐，准备迎接周末 |
| 周六 | 周末愉快，享受生活 |
| 周日 | 周日慢生活，为下周充电 |

特殊节点（自动识别）：24节气、法定节假日、季节转换、天气变化

## 故障排查

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| `invalid ip` | 服务器 IP 不在白名单 | 添加 IP 到公众号后台，或使用 Server 模式 |
| `invalid appid or secret` | 环境变量配置错误 | 检查 `WECHAT_APP_ID` 和 `WECHAT_APP_SECRET` |
| `wenyan: command not found` | wenyan-cli 未安装 | 执行 `npm install -g @wenyan-md/cli` |
| `claude: command not found` | Claude Code CLI 未安装 | 参考 Claude Code 官方文档安装 |
| 文案 AI 味道重 | 人性化改写不充分 | SKILL.md 已内置完整禁用词表和检查清单 |
| 文件生成但未发布 | 环境变量缺失 | 确保 `.bashrc` 中配置了微信凭证 |
| AI味词汇残留告警 | 生成模型偶尔遗漏 | 脚本自动检测，手动修改后重新发布 |

## 相关项目

- [Humanizer-zh](https://github.com/op7418/Humanizer-zh) - AI 写作去痕工具（中文版）
- [wenyan-cli](https://github.com/caol64/wenyan-cli) - Markdown 排版与发布到微信公众号
- [wenyan-mcp](https://github.com/caol64/wenyan-mcp) - wenyan 的 MCP 版本，支持 AI Agent 自动发文

## 许可

MIT License
