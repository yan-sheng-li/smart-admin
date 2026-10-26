#!/usr/bin/env python3
# rename-pkg.py — Java 包名整体迁移器(跨平台,替代 rename-pkg.sh)
# 用法: python rename-pkg.py <OLD_DOTTED> <NEW_DOTTED> <TARGET_DIR> [--apply]
# 默认 dry-run 预览; 加 --apply 真改。
import sys, os, re, shutil
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

APPLY = '--apply' in sys.argv
args = [a for a in sys.argv[1:] if a != '--apply']

if len(args) != 3:
    print('用法: python rename-pkg.py <OLD_DOTTED> <NEW_DOTTED> <TARGET_DIR> [--apply]')
    sys.exit(1)

OLD, NEW, TARGET = args
PKG_RE = re.compile(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$')

err = []
if not PKG_RE.match(OLD):
    err.append(f"ERR: OLD 包名非法: '{OLD}' (须小写开头,段间用点)")
if not PKG_RE.match(NEW):
    err.append(f"ERR: NEW 包名非法: '{NEW}'")
if OLD == NEW:
    err.append('ERR: OLD 与 NEW 相同')
root = Path(TARGET)
if not root.is_dir():
    err.append(f"ERR: TARGET_DIR 不存在: '{TARGET}'")
elif not (root / 'pom.xml').exists():
    err.append(f"ERR: {TARGET} 下无 pom.xml (不像 Maven 项目根)")
if err:
    for e in err:
        print(e, file=sys.stderr)
    sys.exit(1)

OLD_SLASH = OLD.replace('.', '/')
NEW_SLASH = NEW.replace('.', '/')
OLD_RE = re.compile(re.escape(OLD))

EXTS = ('.java', '.xml', '.yml', '.yaml', '.vm', '.factories', '.imports', '.properties')
SPECIAL_NAMES = ('spring.factories', 'spring.imports')
EXCLUDE_DIRS = {'.codegraph', 'target', 'node_modules', '.git'}


def is_target_file(p: Path) -> bool:
    return p.suffix in EXTS or p.name in SPECIAL_NAMES


def iter_files():
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for fn in filenames:
            p = Path(dirpath) / fn
            if is_target_file(p):
                yield p


def iter_dirs():
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        yield Path(dirpath)


def read_text(p: Path) -> str:
    with open(p, 'r', encoding='utf-8', newline='') as fp:
        return fp.read()


def write_text(p: Path, txt: str):
    with open(p, 'w', encoding='utf-8', newline='') as fp:
        fp.write(txt)


# ---- 收集命中文件 ----
hits = []
for p in iter_files():
    try:
        txt = read_text(p)
    except (UnicodeDecodeError, PermissionError):
        continue
    if OLD in txt or OLD_SLASH in txt:
        hits.append((p, txt))

if not hits:
    print(f"WARN: 未在 {TARGET} 内找到 '{OLD}' 任何引用")
    sys.exit(0)

print('== rename-pkg ==')
print(f'OLD (dotted): {OLD}')
print(f'NEW (dotted): {NEW}')
print(f'OLD (slash) : {OLD_SLASH}')
print(f'NEW (slash) : {NEW_SLASH}')
print(f'TARGET      : {TARGET}')
print(f'MODE        : {"APPLY" if APPLY else "DRY-RUN"}')
print()

print('[1/3] 文本命中预览')
total = 0
for p, txt in hits:
    c = txt.count(OLD) + txt.count(OLD_SLASH)
    total += c
    print(f'  {c:5d}  {p.relative_to(root)}')
print(f'合计命中次数: {total}')
print()

if not APPLY:
    print('DRY-RUN: 未改动任何文件。加 --apply 真改。')
    sys.exit(0)

# ---- 文本替换 ----
print('[2/3] 文本替换')
changed = 0
for p, txt in hits:
    new_txt = OLD_RE.sub(NEW, txt)
    new_txt = new_txt.replace(OLD_SLASH, NEW_SLASH)
    if new_txt != txt:
        write_text(p, new_txt)
        changed += 1
print(f'文本替换完成: {changed} 个文件')
print()

# ---- 目录迁移 ----
print('[3/3] 目录迁移')
old_parts = tuple(OLD_SLASH.split('/'))
new_parts = tuple(NEW_SLASH.split('/'))

pkg_roots = []
for d in iter_dirs():
    parts = d.relative_to(root).parts
    if parts[-len(old_parts):] == old_parts:
        pkg_roots.append(d)

# 深 → 浅,先移最深包根再删父空壳
pkg_roots.sort(key=lambda d: len(d.parts), reverse=True)

for d in pkg_roots:
    base_parts = d.relative_to(root).parts[:-len(old_parts)]
    new_dir = root.joinpath(*base_parts).joinpath(*new_parts)
    rel_old = d.relative_to(root)
    rel_new = new_dir.relative_to(root)
    print(f'  迁移: {rel_old} -> {rel_new}')
    new_dir.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(d), str(new_dir))
    # 删空壳: 自底向上删 old_parts 各层空目录
    node = d
    for _ in range(len(old_parts)):
        if node.exists():
            try:
                node.rmdir()
            except OSError:
                pass
        node = node.parent

print()
print('[自检]')
resid = []
for p in iter_files():
    try:
        txt = read_text(p)
    except (UnicodeDecodeError, PermissionError):
        continue
    if OLD in txt or OLD_SLASH in txt:
        resid.append(str(p.relative_to(root)))
print(f'残留引用: {len(resid)}' + (' -> ' + '; '.join(resid[:10]) if resid else ''))

new_hits = 0
for p in iter_files():
    try:
        txt = read_text(p)
    except (UnicodeDecodeError, PermissionError):
        continue
    if NEW in txt or NEW_SLASH in txt:
        new_hits += 1
print(f'新包名命中文件数: {new_hits}')
if new_hits:
    print('确认改到 ✓')
else:
    print('WARN: 新包名 0 命中, 可能 OLD/NEW 写反')

# 空壳检查
leftover = [str(d.relative_to(root)) for d in iter_dirs()
            if d.name == OLD.split('.')[0]]
print('空壳残留:' + (' ' + '; '.join(leftover) if leftover else ' 无 ✓'))

print()
print('== 完成 ==')
print(f'下一步: cd {TARGET} && mvn -q -o compile')