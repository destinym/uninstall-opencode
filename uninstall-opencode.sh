#!/bin/bash
# OpenCode macOS 彻底卸载脚本
# 适用系统: macOS (Apple Silicon / Intel)
# ⚠️ 警告: 此操作不可逆，将删除所有项目、会话、配置和数据！

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
info()  { echo -e "${BLUE}[NOTE]${NC} $1"; }

# ==================== 安全检查 ====================
if [[ "$(uname)" != "Darwin" ]]; then
    error "此脚本仅适用于 macOS，当前系统: $(uname)"
    exit 1
fi

echo ""
echo "========================================"
echo "⚠️  OpenCode macOS 彻底卸载脚本"
echo "========================================"
echo ""
echo "此脚本将永久删除:"
echo "  • OpenCode 应用程序及二进制文件"
echo "  • 所有项目数据、会话历史、Agent 记忆"
echo "  • 全局配置 (~/.config/opencode)"
echo "  • 应用数据 (~/.local/share/opencode)"
echo "  • 缓存、日志、临时文件"
echo ""
echo "${RED}⛔ 此操作不可逆！所有项目数据将被永久删除！${NC}"
echo ""

read -p "确认要彻底卸载 OpenCode? 输入 YES 继续: " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
    log "操作已取消"
    exit 0
fi

# ==================== 1. 停止进程 ====================
log "检查并停止 OpenCode 进程..."

# 获取除了当前脚本进程（$$）及其父进程外，所有包含 "opencode" 的进程 ID
# 避免脚本自身或其调用 shell 因名称匹配而自我终止
PIDS=$(pgrep -f "opencode" | grep -v -E "^($$|$PPID)$" || true)

if [ -n "$PIDS" ]; then
    warn "发现运行中的 OpenCode 进程，正在终止..."
    echo "$PIDS" | xargs kill 2>/dev/null || true
    sleep 2
    # 再次检查并强制终止残留进程
    PIDS_REMAINING=$(pgrep -f "opencode" | grep -v -E "^($$|$PPID)$" || true)
    if [ -n "$PIDS_REMAINING" ]; then
        echo "$PIDS_REMAINING" | xargs kill -9 2>/dev/null || true
    fi
    log "已终止所有 OpenCode 进程"
else
    log "未发现运行中的 OpenCode 进程"
fi

# ==================== 2. 删除应用程序 ====================
log "删除 OpenCode 应用程序..."

APP_PATHS=(
    "/Applications/OpenCode.app"
    "$HOME/Applications/OpenCode.app"
)

for path in "${APP_PATHS[@]}"; do
    if [ -d "$path" ]; then
        if [ ! -w "$path" ] || [ ! -w "$(dirname "$path")" ]; then
            warn "权限不足，正在使用 sudo 删除: $path"
            sudo rm -rf "$path"
        else
            rm -rf "$path"
        fi
        log "已删除应用: $path"
    fi
done

# ==================== 3. 删除二进制文件 ====================
log "删除 OpenCode 二进制文件..."

BINARY_PATHS=(
    "/usr/local/bin/opencode"
    "/opt/homebrew/bin/opencode"
    "$HOME/.local/bin/opencode"
    "$HOME/bin/opencode"
)

for path in "${BINARY_PATHS[@]}"; do
    if [ -f "$path" ] || [ -L "$path" ]; then
        if [ ! -w "$path" ] || [ ! -w "$(dirname "$path")" ]; then
            warn "权限不足，正在使用 sudo 删除: $path"
            sudo rm -f "$path"
        else
            rm -f "$path"
        fi
        log "已删除二进制: $path"
    fi
done

# Homebrew 安装检查
if command -v brew &> /dev/null; then
    if brew list --formula 2>/dev/null | grep -q "^opencode$"; then
        warn "检测到 Homebrew 安装的 OpenCode，执行卸载..."
        brew uninstall opencode 2>/dev/null || true
        log "已通过 Homebrew 卸载"
    fi
    if brew list --cask 2>/dev/null | grep -q "opencode"; then
        brew uninstall --cask opencode 2>/dev/null || true
        log "已通过 Homebrew Cask 卸载"
    fi
fi

# npm 全局安装检查
if command -v npm &> /dev/null; then
    if npm list -g --depth=0 2>/dev/null | grep -q "opencode"; then
        warn "检测到 npm 全局安装的 OpenCode..."
        npm uninstall -g opencode 2>/dev/null || true
        log "已通过 npm 卸载"
    fi
fi

# pnpm 全局安装检查
if command -v pnpm &> /dev/null; then
    if pnpm list -g --depth=0 2>/dev/null | grep -q "opencode"; then
        warn "检测到 pnpm 全局安装的 OpenCode..."
        pnpm uninstall -g opencode 2>/dev/null || true
        log "已通过 pnpm 卸载"
    fi
fi

# yarn 全局安装检查
if command -v yarn &> /dev/null; then
    if yarn global list 2>/dev/null | grep -q "opencode"; then
        warn "检测到 yarn 全局安装的 OpenCode..."
        yarn global remove opencode 2>/dev/null || true
        log "已通过 yarn 卸载"
    fi
fi

# bun 全局安装检查
if command -v bun &> /dev/null; then
    warn "尝试清理 bun 全局安装的 OpenCode..."
    bun uninstall -g opencode &>/dev/null || true
fi

# ==================== 4. 删除数据目录（核心） ====================
log "删除 OpenCode 数据目录..."

DATA_PATHS=(
    "$HOME/.local/share/opencode"       # 项目数据、数据库、storage、worktree
    "$HOME/Library/Application Support/opencode"  # macOS 备选数据位置
    "$HOME/.opencode"                   # 旧版数据目录
)

for path in "${DATA_PATHS[@]}"; do
    if [ -d "$path" ]; then
        rm -rf "$path"
        log "已删除数据目录: $path"
    fi
done

# ==================== 5. 删除配置文件 ====================
log "删除配置文件..."

CONFIG_PATHS=(
    "$HOME/.config/opencode"
    "$HOME/Library/Preferences/com.opencode.plist"
    "$HOME/.opencode.json"
)

for path in "${CONFIG_PATHS[@]}"; do
    if [ -e "$path" ]; then
        if [ ! -w "$path" ] || [ ! -w "$(dirname "$path")" ]; then
            sudo rm -rf "$path"
        else
            rm -rf "$path"
        fi
        log "已删除配置: $path"
    fi
done

# ==================== 6. 删除缓存和日志 ====================
log "删除缓存和日志..."

CACHE_LOG_PATHS=(
    "$HOME/Library/Caches/opencode"
    "$HOME/.cache/opencode"
    "$HOME/Library/Logs/opencode"
    "$HOME/.local/state/opencode"
)

for path in "${CACHE_LOG_PATHS[@]}"; do
    if [ -d "$path" ]; then
        rm -rf "$path"
        log "已删除: $path"
    fi
done

# 清理 ~/Library 中可能的残留
find "$HOME/Library" -maxdepth 3 -iname "*opencode*" -not -path "*/Trash/*" 2>/dev/null | while read -r item; do
    if [ -e "$item" ]; then
        if [ ! -w "$item" ] || [ ! -w "$(dirname "$item")" ]; then
            sudo rm -rf "$item"
        else
            rm -rf "$item"
        fi
        log "已删除 Library 残留: $item"
    fi
done

# ==================== 7. 验证卸载结果 ====================
log "验证卸载结果..."

VERIFY_PASS=true

# 排除当前脚本进程（$$）及父进程
if pgrep -f "opencode" | grep -v -E "^($$|$PPID)$" > /dev/null 2>&1; then
    error "✗ 仍有 OpenCode 进程在运行"
    VERIFY_PASS=false
else
    log "✓ 无运行中的 OpenCode 进程"
fi

if command -v opencode > /dev/null 2>&1; then
    error "✗ 仍能找到 opencode 命令: $(which opencode)"
    VERIFY_PASS=false
else
    log "✓ opencode 命令已移除"
fi

# 使用 || true 避免 find + head 触发 SIGPIPE 时因 pipefail 导致 set -e 崩溃退出
REMAINING=$(find "$HOME" -maxdepth 4 -iname "*opencode*" \
    -not -path "*/Trash/*" \
    -not -path "*/.Trash/*" \
    -not -path "*/node_modules/*" \
    2>/dev/null | head -10 || true)

if [ -n "$REMAINING" ]; then
    warn "发现以下残留文件（可手动清理）:"
    echo "$REMAINING" | while read -r f; do echo "    $f"; done
else
    log "✓ 未发现残留文件"
fi

# ==================== 完成 ====================
echo ""
echo "========================================"
if [ "$VERIFY_PASS" = true ]; then
    echo "🎉 OpenCode 已从 macOS 彻底卸载！"
else
    echo "⚠️  卸载基本完成，但有残留需手动处理"
fi
echo "========================================"
echo ""
echo "📋 后续建议:"
echo "  • 重启终端以确保 PATH 刷新"
echo "  • 如有 Docker 容器运行 OpenCode，请手动 docker rm"
echo "  • 检查浏览器扩展中是否有 OpenCode 相关插件"
echo ""
