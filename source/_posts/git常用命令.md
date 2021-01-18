---
title: git常用命令
tags: git
categories: 工具
abbrlink: 423abe9e
date: 2020-07-07 17:29:35
---
### 前言
这里记录一些常见的 git 操作。
<!--more-->

### 撤销上一次的 commit
```sh
git reset --soft HEAD^
```
### 撤销上一次的 add
```sh
git reset --mixed
```
### 关联远程仓库
```sh
git init
git remote add ${http url | ssh url} # 建议使用 ssh
```
### 删除关联的远程仓库
```sh
git remote remove origin
```
### 开启二次验证后，push 提示密码不对
- ssh
[配置SSH]()
将生成的 id_pub 文件中的内容复制到 github 上的 SSH 配置里
- personal token
使用 personal token 代替密码，比较麻烦，建议上种

### 暂存工作区进度
```sh
git stash
git stash pop 恢复工作区，可能会产生冲突
```
### 获取远程仓库地址
```sh
git remote get-url origin
```

### rebase 合并提交
rebase 可以合并多次提交，对重复功能的提交是有好处的，可以维持简洁的 commit log。不过，合并提交意味着远端丢失更改信息，在生产中是好是坏孰未可知。

- 指定合并提交的位置
即 start，end。需要注意的是从你想要合并的提交的前一个位置开始计数，像下面这个命令是合并最新提交前的 9 个提交 
```sh
git rebase -i HEAD~9 
```
- squash 合并
执行上步完成后就会有相应的提示，将想要合并的 commit 前面改成 squash，下面的注释都有解释每个操作是干啥的。
```sh
pick bce5037 chore: xxxx
  
# Rebase c4796b6..bce5037 onto c4796b6 (1 command)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup <commit> = like "squash", but discard this commit's log message
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
# .       create a merge commit using the original merge commit's
```
- 冲突解决
如果产生冲突，就解决冲突，继续执行 rebase
```sh
git rebase --continue
```
- 停止 rebase
```sh
git rebase --abort
```
