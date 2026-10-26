#!/usr/bin/env python3
# strip-java-headers.py — 删 Java 文件含原作者署名的 Javadoc 块
# 匹配 /** ... */ 块内含 @Author/@Copyright/@Email/@Wechat 任一即删整块
# 用法: python strip-java-headers.py <目录1> [目录2...] [--apply]
# 默认 dry-run 仅预览,加 --apply 真改
import re, sys, glob

APPLY = '--apply' in sys.argv
dirs = [a for a in sys.argv[1:] if a != '--apply']
if not dirs:
    print('用法: strip-java-headers.py <目录> [--apply]  默认 dry-run')
    sys.exit(1)

block_re = re.compile(r'/\*\*[\s\S]*?\*/')
sig_re = re.compile(r'@(author|copyright|email|wechat|description|date)\b', re.IGNORECASE)

changed_files = 0
removed_blocks = 0

for d in dirs:
    pattern = d.rstrip('/').replace('\\', '/') + '/**/*.java'
    for f in glob.glob(pattern, recursive=True):
        try:
            with open(f, 'r', encoding='utf-8') as fp:
                txt = fp.read()
        except (UnicodeDecodeError, PermissionError):
            continue

        hit = [0]
        def repl(m):
            if sig_re.search(m.group(0)):
                hit[0] += 1
                return ''  # 删整块
            return m.group(0)

        new = block_re.sub(repl, txt)
        if hit[0] == 0:
            continue

        # 压缩删块后连续空行(最多保留1个空行)
        new = re.sub(r'\n[ \t]*\n[ \t]*\n', '\n\n', new)
        # 清理行尾空格
        new = '\n'.join(line.rstrip() for line in new.split('\n'))

        changed_files += 1
        removed_blocks += hit[0]
        mark = 'W' if APPLY else 'D'
        print(f'{mark} [{hit[0]}] {f}')
        if APPLY and new != txt:
            with open(f, 'w', encoding='utf-8') as fp:
                fp.write(new)

mode = 'APPLY' if APPLY else 'DRY-RUN'
print(f'\n[{mode}] 命中文件: {changed_files}, 删除 Javadoc 块: {removed_blocks}')
if not APPLY and changed_files:
    print('确认无误后加 --apply 真改')
