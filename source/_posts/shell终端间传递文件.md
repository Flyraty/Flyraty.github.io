---
title: shell终端间传递文件
date: 2020-08-19 17:19:08
tags: Linux
---
### 背景
碰到有些系统的环境权限认证太复杂，往往套了好几层。现在有本地主机 A，远程主机 B。现在 A 要向 B 上传文件。
1. 主机 A 不能直接访问主机 B
2. 只有主机 B 能访问远程服务器
3. 主机 A 上有工具可以和主机 B 通信
<!--more-->

### 直接通过shell传递文件
主机 A 终端上执行，生成文件的 base64
```sh
tar -c file | gzip -9 | base64 >> file.txt
```
主机 B 终端上执行，在 heredoc 中输入文件的 base64
```sh
cat <<'EOF' | base64 --decode | tar -zx
```