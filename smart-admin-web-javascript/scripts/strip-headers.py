#!/usr/bin/env python3
# shortcut: 删前端文件头版权注释块（含@Author/@Wechat/@Email/@Copyright），仅处理文件首个注释块
import re, sys, glob, os

def strip_first_comment(text, opener, closer):
    m = re.match(r'\s*', text)
    pre = m.group(0)
    rest = text[m.end():]
    if not rest.startswith(opener):
        return None
    end = rest.find(closer)
    if end == -1:
        return None
    block = rest[:end + len(closer)]
    if not re.search(r'@(Author|Wechat|Email|Copyright)', block):
        return None
    after = rest[end + len(closer):]
    # 去掉块后紧跟的空行
    after = re.sub(r'\n[ \t]*\n', '\n', after, count=1)
    return pre + after.lstrip('\n')

changed = 0
for pat in ['src/**/*.vue', 'src/**/*.js', 'src/**/*.ts', 'src/**/*.less', 'src/**/*.css', 'src/**/*.html']:
    for f in glob.glob(pat, recursive=True):
        with open(f, 'r', encoding='utf-8') as fp:
            txt = fp.read()
        # .vue/.html: <!-- --> ; .js/.ts: /* */
        for opener, closer in [('<!--', '-->'), ('/*', '*/')]:
            new = strip_first_comment(txt, opener, closer)
            if new is not None and new != txt:
                txt = new
        if txt != open(f, 'r', encoding='utf-8').read():
            with open(f, 'w', encoding='utf-8') as fp:
                fp.write(txt)
            changed += 1
print(f'changed: {changed}')
