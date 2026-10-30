#!/usr/bin/env python3
# 清理前端品牌/署名残留: 行内/函数级 @author 注释、net.lab1024 包名引用
import re, glob, os

AUTHOR_RE = re.compile(r'[ \t]*[-:：]*[ \t]*@author\b[^\n]*', re.IGNORECASE)
ROOTS = ['smart-admin-web-javascript/src', 'smart-app/src']
EXTS = ('*.js', '*.vue', '*.ts')

files = 0
authors = 0
pkgs = 0
for root in ROOTS:
    for ext in EXTS:
        for f in glob.glob(os.path.join(root, '**', ext), recursive=True):
            with open(f, 'r', encoding='utf-8', newline='') as fp:
                txt = fp.read()
            new, n1 = re.subn(r'net\.lab1024', 'com.example', txt)
            new, n2 = AUTHOR_RE.subn('', new)
            if new != txt:
                with open(f, 'w', encoding='utf-8', newline='') as fp:
                    fp.write(new)
                files += 1
                authors += n2
                pkgs += n1
print(f'files={files} authors={authors} net.lab1024={pkgs}')