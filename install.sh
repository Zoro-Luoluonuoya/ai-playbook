#!/bin/sh
# 把 playbook 铺到一个目标项目。不覆盖已存在的文件。
# 用法: sh install.sh [--dry-run] <目标项目路径>

set -eu

DRY=0
WITH_SKILL=0
TARGET=""

usage() {
    echo "用法: sh install.sh [--dry-run] <目标项目路径>"
    echo ""
    echo "  <目标项目路径>  已存在的项目根目录（新项目也可，会创建 docs/）"
    echo ""
    echo "选项:"
    echo "  --dry-run     只打印将要写入的路径，不落盘"
    echo "  --with-skill  同时把 skill 装到 \$HOME/.workbuddy/skills/ai-collab-playbook"
    echo "  -h, --help    显示本帮助"
    echo ""
    echo "行为:"
    echo "  1. 写 CLAUDE.md（规范正文，WorkBuddy / Claude Code 读）"
    echo "  2. 写 AGENTS.md（入口引导页，Codex 读）"
    echo "  3. 写 DECISIONS.md（拍板即冻结的决策账本）"
    echo "  4. 写 docs/spec.md、docs/MISTAKE-LOG.md、docs/DoD-验收清单.md、docs/每日三问.md"
    echo "  5. 复制 new-project.sh 到 docs/"
    echo ""
    echo "已存在的文件一律跳过，不覆盖。"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY=1; shift ;;
        --with-skill) WITH_SKILL=1; shift ;;
        -h|--help) usage; exit 0 ;;
        -*) echo "未知选项: $1" >&2; usage >&2; exit 2 ;;
        *) TARGET="$1"; shift ;;
    esac
done

if [ -z "$TARGET" ]; then
    usage >&2
    exit 2
fi

if [ ! -d "$TARGET" ]; then
    echo "目标目录不存在: $TARGET" >&2
    exit 2
fi

HERE=$(cd "$(dirname "$0")" && pwd)
TPL="$HERE/templates"

if [ ! -d "$TPL" ]; then
    echo "找不到模板目录: $TPL" >&2
    exit 2
fi

echo "playbook: $HERE"
echo "目标项目: $TARGET"
if [ "$DRY" = 1 ]; then
    echo "模式:     dry-run（不落盘）"
fi
echo ""

ok=0
skip=0

install_file() {
    src="$1"
    dst="$2"
    if [ -e "$dst" ]; then
        echo "  跳过（已存在）: $dst"
        skip=$((skip + 1))
        return 0
    fi
    if [ "$DRY" = 1 ]; then
        echo "  [dry-run] $dst"
    else
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "  写入: $dst"
    fi
    ok=$((ok + 1))
}

install_file "$TPL/CLAUDE.md.template"      "$TARGET/CLAUDE.md"
install_file "$TPL/AGENTS.md.template"      "$TARGET/AGENTS.md"
install_file "$TPL/DECISIONS.md.example"    "$TARGET/DECISIONS.md"
install_file "$TPL/spec.md.template"        "$TARGET/docs/spec.md"
install_file "$TPL/MISTAKE-LOG.md.template" "$TARGET/docs/MISTAKE-LOG.md"
install_file "$TPL/DoD-验收清单.md"           "$TARGET/docs/DoD-验收清单.md"
install_file "$TPL/每日三问.md"                "$TARGET/docs/每日三问.md"
install_file "$TPL/new-project.sh"          "$TARGET/docs/new-project.sh"

echo ""
echo "完成：写入 $ok 个，跳过 $skip 个（已存在）。"

# 可选：安装 skill。skill 只在 WorkBuddy 环境有意义，所以不默认装。
if [ "$WITH_SKILL" = 1 ]; then
    SKILL_HOME="${WORKBUDDY_SKILLS_DIR:-$HOME/.workbuddy/skills}"
    SKILL_DST="$SKILL_HOME/ai-collab-playbook"
    echo ""
    if [ ! -d "$HERE/skill" ]; then
        echo "跳过 skill：仓库里没有 skill/ 目录"
    elif [ -e "$SKILL_DST" ]; then
        echo "跳过 skill（已存在）: $SKILL_DST"
        echo "  想更新就手动删掉该目录后重跑，或直接 cp -r \"$HERE/skill\" \"$SKILL_DST\""
    elif [ "$DRY" = 1 ]; then
        echo "  [dry-run] cp -r $HERE/skill -> $SKILL_DST"
    else
        mkdir -p "$SKILL_HOME"
        cp -r "$HERE/skill" "$SKILL_DST"
        echo "  skill 已装: $SKILL_DST"
    fi
fi
echo ""
echo "下一步（按顺序，1-3 第一天做完）:"
echo "  1. 打开 CLAUDE.md，填「常用命令」和「架构三句话」；跑一遍那些命令确认能跑通。"
echo "  2. 打开 DECISIONS.md，删掉示例条目，写你今天已经拍板的事（技术选型/存储/界面口径）。"
echo "  3. 写第一个功能之前，先让「改一行 -> 跑一条验证 -> 看到绿」这条链路通。"
echo "  4. 要并行再跑: sh docs/new-project.sh --dry-run <本项目路径> <窗口数>"
