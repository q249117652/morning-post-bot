#!/bin/bash
# ============================================================
# 公众号早安文案自动生成 & 发布脚本
# 配合 Crontab 每天 18:00 执行
# ============================================================

set -euo pipefail

# -------------------- 配置区域 --------------------
# 微信公众号 API 凭证（必填）
# 建议将以下变量写入 ~/.bashrc 或 ~/.profile，而不是硬编码在此处
# export WECHAT_APP_ID="你的AppID"
# export WECHAT_APP_SECRET="你的AppSecret"

# 工作目录
WORK_DIR="$HOME/morning-posts"
LOG_FILE="$WORK_DIR/publish_log.txt"

# wenyan-cli 排版主题（可选：default, lapis 等，执行 wenyan theme -l 查看全部）
WENYAN_THEME="default"

# 远程 Server 模式（可选，IP 不在白名单时启用）
# WENYAN_SERVER="https://你的服务器地址"
# WENYAN_API_KEY="你的API密钥"

# Claude Code 命令路径（根据实际安装路径调整）
CLAUDE_CMD="claude"

# -------------------- 预检查 --------------------
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 确保工作目录存在
mkdir -p "$WORK_DIR"

log "===== 开始执行早安文案生成任务 ====="

# 检查 claude 命令是否可用
if ! command -v "$CLAUDE_CMD" &> /dev/null; then
    log "错误：claude 命令未找到，请确认 Claude Code CLI 已安装"
    exit 1
fi

# 检查 wenyan 命令是否可用
if ! command -v wenyan &> /dev/null; then
    log "错误：wenyan-cli 未安装，请执行: npm install -g @wenyan-md/cli"
    exit 1
fi

# 检查环境变量
if [ -z "${WECHAT_APP_ID:-}" ]; then
    log "警告：WECHAT_APP_ID 未设置，发布步骤可能失败"
fi

if [ -z "${WECHAT_APP_SECRET:-}" ]; then
    log "警告：WECHAT_APP_SECRET 未设置，发布步骤可能失败"
fi

# -------------------- 生成明天的日期 --------------------
TOMORROW_DATE=$(date -d "tomorrow" "+%Y-%m-%d" 2>/dev/null || date -v+1d "+%Y-%m-%d")
TOMORROW_DISPLAY=$(date -d "tomorrow" "+%Y年%m月%d日 %A" 2>/dev/null || date -v+1d "+%Y年%m月%d日 %A")
OUTPUT_FILE="$WORK_DIR/post_${TOMORROW_DATE}.md"

log "目标日期：$TOMORROW_DISPLAY"
log "输出文件：$OUTPUT_FILE"

# -------------------- 调用 Claude Code 生成文案 --------------------
# 使用 -p 参数进入非交互模式，自动调用 morning-post-generator 技能
PROMPT="请使用 morning-post-generator 技能，为 ${TOMORROW_DISPLAY} 生成早安公众号推文。
要求：
1. 严格按照 SKILL.md 中定义的板块结构生成内容
2. 必须执行人性化改写，去除所有 AI 痕迹
3. 质量自检评分必须达到 40/50 以上
4. 将文件保存为 ${OUTPUT_FILE}
5. 使用 wenyan publish -f ${OUTPUT_FILE} -t ${WENYAN_THEME} 推送至公众号草稿箱
6. 将发布结果（成功/失败、Media ID）记录到 ${LOG_FILE}"

log "正在调用 Claude Code 生成文案..."

# 执行 Claude Code
if $CLAUDE_CMD -p "$PROMPT" 2>&1 | tee -a "$LOG_FILE"; then
    log "Claude Code 执行完毕"
else
    log "错误：Claude Code 执行失败，退出码 $?"
    exit 1
fi

# -------------------- 验证输出 --------------------
if [ -f "$OUTPUT_FILE" ]; then
    log "文件生成成功：$OUTPUT_FILE"
    
    # 基础格式验证
    H1_COUNT=$(grep -c "^# " "$OUTPUT_FILE" || true)
    H2_COUNT=$(grep -c "^## " "$OUTPUT_FILE" || true)
    H3_COUNT=$(grep -c "^### " "$OUTPUT_FILE" || true)
    WORD_COUNT=$(wc -c < "$OUTPUT_FILE")
    
    log "格式检查：H1=${H1_COUNT} H2=${H2_COUNT} H3=${H3_COUNT} 字节数=${WORD_COUNT}"
    
    if [ "$H1_COUNT" -lt 1 ] || [ "$H2_COUNT" -lt 3 ] || [ "$H3_COUNT" -lt 2 ]; then
        log "警告：Markdown 层级结构不符合要求（需要 >=1个H1, >=3个H2, >=2个H3）"
    fi
else
    log "错误：文件未生成 $OUTPUT_FILE"
    exit 1
fi

log "===== 早安文案生成任务执行完毕 ====="
