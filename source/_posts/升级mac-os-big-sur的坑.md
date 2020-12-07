---
title: mac os 升级到 big sur的坑
categories: 工具
tags: Mac
abbrlink: 9894dc13
date: 2020-11-21 18:05:18
---

#### 前言
升级到 big sur 后，一些系统命令及软件包找不到了（比如 git，python3..）。
<!--more-->

#### 解决方式
升级完成之后，使用 git 报以下错，还有其他一些软件包也是报的类似的错。
```
sh: line 1: 97132 Abort trap: 6 /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -sdk / -find git 2> /dev/null
git: error: unable to find utility "git", not a developer tool or in PATH
```
找不到 git ？？？而且报的是 xcode 的错，难道是升级把 xcode comandline tools 搞没了。但是看了下 brew，svn 啥的都没啥问题。于是重装 git

```sh
brew uninstall git
brew search git
brew install git
```
emmm，重装之后也不管用，看报错是 git 没有在环境变量里，这东西不是 xcode omandline tools 自带的吗? 于是试着加了下环境变量
```
PATH=/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH
```
加上之后，git 倒是好了。接下来修 python3。也用的重装大法，最后提示 xcode 版本过低。于是又重装 xcode 。
```
xcode-select --install
```
开启 python3，可以正常没问题，本以为解决好了，由于重装了 python，很多三方库都没了，开始拿 pip3 重装，结果一堆库安装失败，还是上面的报错，只不过 git 变成了什么 gcc，clang。严重怀疑是什么地方环境变量指错了。看下 xcode commandline tools 的指向。
```sh
xcode-select --print-path 
```
指向的是 Developer 文件夹，其实应该指向 CommandLineTools。遂修改

```sh
sudo xcode-select --switch /Library/Developer/CommandLineTool

```
改完之后，重启了 itrem2 啥的，再各种安装就没有问题了。