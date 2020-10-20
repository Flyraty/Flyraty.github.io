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
