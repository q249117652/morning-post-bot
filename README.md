# 公众号早安文案自动生成器

基于 Claude Code Skills 的全自动微信公众号早安文案生成与发布系统。

## 项目结构

```
~/.claude/skills/morning-post-bot/
  SKILL.md                    # Claude Code 技能定义（核心）

~/morning-posts/
  scripts/
    run_morning_post.sh       # 自动化触发脚本（Crontab 调用）
  covers/
    default.jpg               # 默认封面图（需自行放置）
  post_2026-03-02.md          # 自动生成的文案（按日期命名）
  publish_log.txt             # 发布日志
```

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

# 安装 Humanizer-zh 技能（可选，本项目 SKILL.md 已内置其规则）
npx skills add https://github.com/op7418/Humanizer-zh.git
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

**IP 白名单配置**：在公众号后台 → 开发 → 基本配置 → IP白名单，添加运行脚本的服务器 IP。

如果你没有固定 IP，请使用 wenyan-cli 的远程 Server 模式（见下方说明）。

### 3. 准备封面图

```bash
# 将你的默认封面图放入 covers 目录
cp 你的封面图.jpg ~/morning-posts/covers/default.jpg
```

如果没有封面图也没关系，wenyan-cli 会自动使用文章中的第一张图片作为封面。

### 4. 配置定时任务

```bash
# 编辑 Crontab
crontab -e

# 添加以下行（每天 18:00 执行）
0 18 * * * /bin/bash /root/morning-posts/scripts/run_morning_post.sh >> /root/morning-posts/cron_output.log 2>&1
```

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

或

```
/morning-post-generator
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

同时修改 SKILL.md 中发布命令为：

```bash
wenyan publish -f 文件路径 -t default --server https://服务器地址 --api-key 密钥
```

## 生成文案示例

以下是系统自动生成的一篇早安文案：

```markdown
---
title: "早安 | 2026年3月2日 星期一"
cover: ~/morning-posts/covers/default.jpg
author: 早安工作室
---

# 3月2日 早安

三月的第一个工作日，窗外的风比昨天暖了一点。

---

## 晨间问候

周末过得太快，好像就眨了两下眼。不过没关系，新的一周总会
带来点新东西。今天天气不错，适合早起走两步。

---

## 今日分享

几个我最近读到的有意思的事。

### 关于睡眠的一个误解

很多人觉得周末补觉能把工作日欠的睡眠还回来。2024年斯坦福
的一项跟踪研究发现，补觉只能恢复大约 30% 的认知损失。
与其周末睡到中午，不如工作日早睡半小时。

### 一个冷知识

蜂蜜是唯一不会变质的天然食物。考古学家在埃及金字塔里发现了
3000 年前的蜂蜜，打开以后还能吃。

---

## 深度一刻

我最近在想一个问题：为什么我们总觉得时间不够用，但又经常
刷手机刷到忘记时间？

也许不是时间不够，是注意力太分散了。我试了一周每天早上
不看手机的前 30 分钟，说实话，效果比我预想的要明显。
脑子清醒很多，早饭也吃得从容了。

> 你不需要更多的时间，你需要更少的干扰。

---

## 今日行动

今天试试这件小事：把手机的通知关掉 **2 个小时**，
看看会不会有什么不同。
```

## 故障排查

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| `invalid ip` | 服务器 IP 不在白名单 | 添加 IP 到公众号后台，或使用 Server 模式 |
| `invalid appid or secret` | 环境变量配置错误 | 检查 `WECHAT_APP_ID` 和 `WECHAT_APP_SECRET` |
| `wenyan: command not found` | wenyan-cli 未安装 | 执行 `npm install -g @wenyan-md/cli` |
| `claude: command not found` | Claude Code CLI 未安装 | 参考 Claude Code 官方文档安装 |
| 文案 AI 味道重 | 人性化改写不充分 | 检查 SKILL.md 中的禁用词表是否生效 |
| 文件生成但未发布 | 环境变量缺失 | 确保 `.bashrc` 中配置了微信凭证 |

## 相关项目

- [Humanizer-zh](https://github.com/op7418/Humanizer-zh) - AI 写作去痕工具（中文版）
- [wenyan-cli](https://github.com/caol64/wenyan-cli) - Markdown 排版与发布到微信公众号
- [wenyan-mcp](https://github.com/caol64/wenyan-mcp) - wenyan 的 MCP 版本，支持 AI Agent 自动发文

## 许可

MIT License
