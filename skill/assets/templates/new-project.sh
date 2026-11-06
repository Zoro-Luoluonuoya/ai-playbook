#!/bin/sh
# new-project.sh —— 新项目起手：校验仓库 → 建 N 个 worktree → 各自装依赖 + 设 hooksPath → 打印下一步
# 用法: sh new-project.sh [--dry-run] <项目根目录> <窗口数> [分支前缀]
# 纪律: 任何会写磁盘 / 改仓库的动作都先打印再执行；--dry-run 只打印，不执行。

set -u

DRY_RUN=0
POS_COUNT=0
ROOT=""
WINDOWS=""
PREFIX=""

usage() {
  cat <<'USAGE'
用法: sh new-project.sh [--dry-run] <项目根目录> <窗口数> [分支前缀]

  <项目根目录>  已 git init 且至少有一次提交的仓库路径
  <窗口数>      要并行的 worktree 数量，1-9
  [分支前缀]    默认 agent

选项:
  --dry-run     只打印将要执行的命令（不建目录、不建分支、不装依赖）
  -h, --help    显示本帮助
USAGE
}

die() {
  printf '[错误] %s\n' "$1" >&2
  exit 1
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] %s\n' "$*"
    return 0
  fi
  printf '[exec] %s\n' "$*"
  "$@"
}

install_deps() {
  d=$1
  if [ -f "$d/pnpm-lock.yaml" ]; then
    run pnpm --dir "$d" install --frozen-lockfile
  elif [ -f "$d/yarn.lock" ]; then
    run yarn --cwd "$d" install --frozen-lockfile
  elif [ -f "$d/package-lock.json" ]; then
    run npm --prefix "$d" ci
  elif [ -f "$d/package.json" ]; then
    run npm --prefix "$d" install
  else
    printf '[跳过] %s 下没有 package.json，不装依赖\n' "$d"
    return 0
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      printf '[错误] 未知选项: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      case "$POS_COUNT" in
        0) ROOT="$1" ;;
        1) WINDOWS="$1" ;;
        2) PREFIX="$1" ;;
        *) die "参数过多: $1" ;;
      esac
      POS_COUNT=$((POS_COUNT + 1))
      ;;
  esac
  shift
done

if [ "$POS_COUNT" -lt 2 ]; then
  usage >&2
  exit 2
fi

[ -n "$PREFIX" ] || PREFIX="agent"

ROOT=${ROOT%/}
[ -n "$ROOT" ] || die "项目根目录不能为空"
[ -d "$ROOT" ] || die "目录不存在: $ROOT"
ROOT=$(cd "$ROOT" && pwd -P) || die "无法进入目录: $ROOT"

case "$WINDOWS" in
  ''|*[!0-9]*) die "窗口数必须是 1-9 的整数，收到: $WINDOWS" ;;
esac
if [ "$WINDOWS" -lt 1 ] || [ "$WINDOWS" -gt 9 ]; then
  die "窗口数超出范围 1-9，收到: $WINDOWS"
fi

case "$PREFIX" in
  *[!A-Za-z0-9._-]*) die "分支前缀只允许字母、数字和 . _ -，收到: $PREFIX" ;;
esac

command -v git >/dev/null 2>&1 || die "未找到 git，请先安装"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || \
  die "$ROOT 不是 git 仓库。先执行: git init && git add -A && git commit -m 'chore: init'"
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || \
  die "$ROOT 还没有任何提交，worktree 无法从 HEAD 建分支。先做首次提交。"

printf '项目根目录: %s\n' "$ROOT"
printf '窗口数量:   %s\n' "$WINDOWS"
printf '分支前缀:   %s\n' "$PREFIX"
printf '模式:       %s\n' "$([ "$DRY_RUN" -eq 1 ] && printf 'dry-run（不落盘）' || printf '实际执行')"

if [ ! -d "$ROOT/.githooks" ]; then
  printf '[警告] %s/.githooks 不存在：hooksPath 会被设置，但实际没有 hook 可跑。\n' "$ROOT" >&2
fi

i=1
while [ "$i" -le "$WINDOWS" ]; do
  WT="${ROOT}-w${i}"
  BRANCH="${PREFIX}/w${i}"

  printf '\n=== 窗口 %s/%s ===\n' "$i" "$WINDOWS"
  printf '目标目录: %s\n' "$WT"
  printf '分支:     %s\n' "$BRANCH"

  if [ -e "$WT" ]; then
    printf '[跳过] 目录已存在，不覆盖: %s\n' "$WT" >&2
  elif git -C "$ROOT" show-ref --verify --quiet "refs/heads/$BRANCH"; then
    printf '[跳过] 分支已存在: %s（重建会丢提交，本脚本不做）\n' "$BRANCH" >&2
  else
    printf '将要执行: 从 %s 的 HEAD 新建分支 %s，检出到 %s\n' "$ROOT" "$BRANCH" "$WT"
    run git -C "$ROOT" worktree add "$WT" -b "$BRANCH" || die "worktree 创建失败: $WT"

    if [ "$DRY_RUN" -eq 1 ]; then
      printf '[dry-run] 在 %s 装依赖（有 lockfile 用 lockfile：npm ci / pnpm / yarn）\n' "$WT"
      printf '[dry-run] git -C %s config core.hooksPath .githooks\n' "$WT"
    else
      install_deps "$WT" || die "依赖安装失败: $WT"
      run git -C "$WT" config core.hooksPath .githooks || die "设置 hooksPath 失败: $WT"
      if [ -d "$WT/.githooks" ]; then
        printf '[ok] hooksPath = %s/.githooks\n' "$WT"
      else
        printf '[警告] %s 没有 .githooks/ 目录，门禁实际为空\n' "$WT" >&2
      fi
    fi
  fi

  i=$((i + 1))
done

printf '\n========== 完成 ==========\n'
if [ "$DRY_RUN" -eq 1 ]; then
  printf '以上为 dry-run：没有创建任何目录或分支。去掉 --dry-run 再跑一次才会真执行。\n'
fi
printf '\n下一步（按顺序做，1-3 在第一天完成）:\n'
printf '1. 每个 worktree 用独立编辑器窗口打开、各跑一个 AI 会话；同一分支不得被两个窗口同时检出。\n'
printf '2. 把 CLAUDE.md.template 拷到 %s/CLAUDE.md，先填「常用命令」和「架构三句话」。\n' "$ROOT"
printf '3. 把 spec.md.template 拷到 %s/docs/spec.md，待澄清问题全部拍板后才许写代码。\n' "$ROOT"
printf '4. 在没改任何代码时先跑一遍 DoD 五层命令，记录基线 PASS；跑不绿的那层当天修。\n'
printf '5. 把 每日三问.md 放进 %s/docs/，收工前 2 分钟答完。\n' "$ROOT"
