#!/usr/bin/env bash
# rename-pkg.sh — 通用 Java 包名整体迁移器
# 用法: ./rename-pkg.sh <OLD_DOTTED> <NEW_DOTTED> <TARGET_DIR> [--apply]
# 默认 dry-run，仅预览命中。--apply 才真改。
set -euo pipefail

OLD="${1:-}"
NEW="${2:-}"
TARGET="${3:-}"
APPLY=0
[[ "${4:-}" == "--apply" ]] && APPLY=1

red()    { printf '\033[31m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m\n' "$*"; }

# ---- 1. 参数校验 ----
err=0
pkg_re='^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$'
[[ "$OLD" =~ $pkg_re ]] || { red "ERR: OLD 包名非法: '$OLD' (须小写字母开头，段间用点)"; err=1; }
[[ "$NEW" =~ $pkg_re ]] || { red "ERR: NEW 包名非法: '$NEW'"; err=1; }
[[ "$OLD" == "$NEW" ]] && { red "ERR: OLD 与 NEW 相同"; err=1; }
if [[ -z "$TARGET" || ! -d "$TARGET" ]]; then
  red "ERR: TARGET_DIR 不存在: '$TARGET'"
  err=1
elif [[ ! -f "$TARGET/pom.xml" ]]; then
  red "ERR: $TARGET 下无 pom.xml（不像 Maven 项目根）"
  err=1
fi
[[ $err -ne 0 ]] && exit 1

# 派生斜杠形态
OLD_SLASH="${OLD//./\/}"
NEW_SLASH="${NEW//./\/}"

# 转义正则元字符（点号）
OLD_RE="${OLD//./\\.}"
NEW_RE_ESC="${NEW//./\\.}"

# 文件类型白名单 + 跳过目录
INCLUDE=( --include="*.java" --include="*.xml" --include="*.yml" --include="*.yaml" \
          --include="*.vm" --include="*.factories" --include="*.imports" --include="*.properties" )
EXCLUDE=( --exclude-dir=".codegraph" --exclude-dir="target" --exclude-dir="node_modules" --exclude-dir=".git" )

bold "== rename-pkg ==" 
echo "OLD (dotted) : $OLD"
echo "NEW (dotted) : $NEW"
echo "OLD (slash)  : $OLD_SLASH"
echo "NEW (slash)  : $NEW_SLASH"
echo "TARGET       : $TARGET"
echo "MODE         : $([[ $APPLY -eq 1 ]] && echo APPLY || echo DRY-RUN)"
echo

# ---- 锁定命中文件集（点号形态；斜杠形态内容里通常无，但通用保留）----
mapfile -t HIT_FILES < <( grep -rl "${INCLUDE[@]}" "${EXCLUDE[@]}" -- "$OLD_RE" "$TARGET" 2>/dev/null || true )
# 也纳入含斜杠形态的文件（其他项目可能有）
mapfile -t HIT_SLASH < <( grep -rlF "${INCLUDE[@]}" "${EXCLUDE[@]}" -- "$OLD_SLASH" "$TARGET" 2>/dev/null || true )

# 合并去重
declare -A seen=()
ALL_FILES=()
for f in "${HIT_FILES[@]}" "${HIT_SLASH[@]}"; do
  [[ -z "$f" ]] && continue
  [[ -n "${seen[$f]:-}" ]] && continue
  seen[$f]=1
  ALL_FILES+=("$f")
done

if [[ ${#ALL_FILES[@]} -eq 0 ]]; then
  yellow "WARN: 未在 $TARGET 内找到 '$OLD' 的任何引用。无事可做。"
  exit 0
fi

bold "[1/3] 文本命中预览（按文件）"
total=0
for f in "${ALL_FILES[@]}"; do
  c=$(grep -cE "$OLD_RE" "$f" 2>/dev/null || true)
  cs=$(grep -cF "$OLD_SLASH" "$f" 2>/dev/null || true)
  n=$((c+cs))
  total=$((total+n))
  printf "  %5d  %s\n" "$n" "${f#$TARGET/}"
done
echo "合计命中行数: $total"
echo

if [[ $APPLY -eq 0 ]]; then
  yellow "DRY-RUN：未改动任何文件。加 --apply 真改。"
  exit 0
fi

# ---- 2. 文本替换（先于目录移动）----
bold "[2/3] 文本替换（sed）"
for f in "${ALL_FILES[@]}"; do
  # 点号形态
  sed -i "s/${OLD_RE}/${NEW//./\\.}/g" "$f" 2>/dev/null || true
  # 实际 sed 替换串不需要转义点号（替换侧点号是字面），上面转义无碍但更稳用原始
  sed -i "s/${OLD_RE}/${NEW}/g" "$f"
  # 斜杠形态（字面，无需转义）
  if grep -qF "$OLD_SLASH" "$f" 2>/dev/null; then
    sed -i "s|${OLD_SLASH}|${NEW_SLASH}|g" "$f"
  fi
done
green "文本替换完成: ${#ALL_FILES[@]} 个文件"
echo

# ---- 3. 目录迁移（深→浅，逐层；每个含 OLD_SLASH 的模块根）----
bold "[3/3] 目录迁移"
# 找到所有 OLD_SLASH 目录
mapfile -t OLD_DIRS < <( find "$TARGET" -type d -path "*/${OLD_SLASH}" "${EXCLUDE[@]/--exclude-dir=/-not -path */}" 2>/dev/null || \
                         find "$TARGET" -type d -path "*/${OLD_SLASH}" 2>/dev/null || true )

# 用更可靠的方式定位（排除 .codegraph/target 等）
OLD_DIRS=()
while IFS= read -r d; do
  case "$d" in
    */.codegraph/*|*/target/*|*/node_modules/*|*/.git/*) continue ;;
  esac
  OLD_DIRS+=("$d")
done < <( find "$TARGET" -type d -path "*/${OLD_SLASH}" 2>/dev/null || true )

if [[ ${#OLD_DIRS[@]} -eq 0 ]]; then
  yellow "WARN: 未找到目录 */${OLD_SLASH}。可能目录形态与包名不一致，跳过目录迁移。"
else
  for d in "${OLD_DIRS[@]}"; do
    # d = .../net/lab1024
    parent=$(dirname "$d")            # .../net 的父 = .../
    seg_root=$(dirname "$d")          # .../net
    # 新路径前缀：把 parent 路径里末尾的 OLD_SLASH 段替换为 NEW_SLASH
    # parent 形如 .../net/lab1024 的父 = .../net —— 但我们要重建 net/.. 整段
    # 更稳：parent = .../<net>; 期望 parent 末段为 OLD 的第一段
    # 逐段重命名：从 OLD 最深段往上，逐层 mv
    IFS='.' read -ra oldsegs <<< "$OLD"   # net lab1024
    # 当前最深目录是 d（即 OLD_SLASH 完整路径），逐层往上 rename
    cur="$d"
    # 先把最末段之后无内容；逐层：把 OLD 第 i 段目录 rename 为 NEW 第 i 段
    # 但 NEW 段数可能与 OLD 不同 → 不能逐段 rename，需整体迁移
    # 方案：把 d 下所有内容移到 parent 重建的 NEW_SLASH 路径，再删空壳
    newdir="${parent%/*}/${NEW_SLASH}"
    # parent 形如 .../net/lab1024 的父 = .../net —— 不对，dirname(d) = .../net
    # 期望新目录 = .../<NEW 第一段>/<NEW 第二段>... 即把 OLD_SLASH 整段换成 NEW_SLASH
    base="${d%/${OLD_SLASH}}"          # 去掉末尾 /net/lab1024
    newdir="${base}/${NEW_SLASH}"
    echo "  迁移: $d -> $newdir"
    mkdir -p "$newdir"
    # 移动 d 下所有条目（含隐藏）
    shopt -s dotglob nullglob
    items=( "$d"/* )
    shopt -u dotglob nullglob
    if [[ ${#items[@]} -gt 0 ]]; then
      mv -n -- "${items[@]}" "$newdir"/
    fi
    # 删空壳：d 本身 + 中间 net/ 等
    # d 此时为空目录 net/lab1024（在最深）；自底向上 rmdir OLD 各段
    cur="$d"
    for (( i=${#oldsegs[@]}-1; i>=0; i-- )); do
      if rmdir "$cur" 2>/dev/null; then
        echo "  rmdir(空) $cur"
      else
        red "ERR: 删空壳失败（非空）: $cur —— 有遗漏文件未迁移，停止。"
        ls -la "$cur" >&2
        exit 1
      fi
      cur=$(dirname "$cur")
    done
  done
  green "目录迁移完成"
fi
echo

# ---- 4. 自检 ----
bold "[自检]"
# 排除目录用 grep --exclude-dir
resid=$(grep -rlE "${INCLUDE[@]}" "${EXCLUDE[@]}" -- "$OLD_RE" "$TARGET" 2>/dev/null | grep -v "/\.codegraph/" || true)
resid_slash=$(grep -rlF "${INCLUDE[@]}" "${EXCLUDE[@]}" -- "$OLD_SLASH" "$TARGET" 2>/dev/null | grep -v "/\.codegraph/" || true)
if [[ -n "$resid" || -n "$resid_slash" ]]; then
  red "ERR: 残留引用未清零："
  [[ -n "$resid" ]] && printf '%s\n' "$resid"
  [[ -n "$resid_slash" ]] && printf '%s\n' "$resid_slash"
  exit 1
fi
green "残留引用: 0 ✓"

new_hits=$(grep -rlE "${INCLUDE[@]}" "${EXCLUDE[@]}" -- "$NEW_RE_ESC" "$TARGET" 2>/dev/null | grep -v "/\.codegraph/" | wc -l || true)
echo "新包名命中文件数: $new_hits"
[[ "$new_hits" -gt 0 ]] && green "确认改到 ✓" || yellow "WARN: 新包名 0 命中，可能 OLD/NEW 写反或项目无该包"

# 空壳 net/ 检查
leftover=$(find "$TARGET" -type d -name "${OLD%%.*}" 2>/dev/null | grep -v "/\.codegraph/" || true)
[[ -n "$leftover" ]] && yellow "WARN: 仍有 OLD 首段目录残留：$leftover" || echo "空壳已清 ✓"

echo
bold "== 完成 =="
echo "下一步（可选）: cd $TARGET && mvn -q -o compile"
echo "若用 codegraph: cd $(dirname "$TARGET") && codegraph index"
