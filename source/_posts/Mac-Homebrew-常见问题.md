---
title: Mac-Homebrew-常见问题
categories: 工具
tags: Mac
abbrlink: c670d00d
date: 2021-05-15 21:01:42
---

### 前言
Homebrew 是 Mac 下方便快捷的包管理器。但是有时候因为其版本迭代等，导致 `brew update` 执行后各种依赖报错或者 Warning。emmm，碰到好几次了，并且由于网上解决办法参差不齐，每次解决浪费了大量时间。遂记录下每次的解决方法。建议遇到问题去查看官方 issue
<!--more-->

### 问题
建议遇到问题去查看官方 issue，你踩过的坑一般都已经有人踩过了。如果还不行，可以自己提 issue，找专业的人去解决效率会更高。
查询问题可以运用这几个命令，查看目前环境信息和 warning。
- `brew config`
- `brew doctor`
- `brew update-reset`
- `brew tap` -> 重新关联相关源，一般删除对应源之后执行这个。
Homebrew 安装在 /usr/local 下面，其中 Taps 下面是一些核心库，比如 homebrew-core，homebrew-cask 等，本质上就是一个个的 git 仓库。

#### Warning: Calling cellar in a bottle block is deprecated! Use brew style --fix on the formula to update the style or use sha256 with a cellar: argument instead. 
在 homebrew-core 提了 issue 才解决的。可以参考 [issue#77342](https://github.com/Homebrew/homebrew-core/issues/77342)。
在安装 grafana 的时候碰到的这个问题。`brew update` 也没报错，就是大量的 Warning。根据提示执行了 `brew style --fix`，显示 ruby 环境有点问题。
后面就是所有 brew 命令报这种错，并且更新包都不成功。
查看 `brew config `，homebrew-core 版本过低。
```sh
HOMEBREW_VERSION: 3.1.7-36-g7c68b17
ORIGIN: https://github.com/Homebrew/brew
HEAD: 7c68b1738b3dce2885d0146f327eaaf96b6d0029
Last commit: 2 days ago
Core tap ORIGIN: https://github.com/Homebrew/homebrew-core
Core tap HEAD: bf34b4a87af8acac55d95f133a8b56a627a28557
Core tap last commit: 5 months ago
Core tap branch: master
HOMEBREW_PREFIX: /usr/local
HOMEBREW_CASK_OPTS: `[]`
HOMEBREW_DISPLAY: /private/tmp/com.apple.launchd.jiJkB9eSrz/org.macosforge.xquartz:0
HOMEBREW_MAKE_JOBS: 8
Homebrew Ruby: 2.6.3 => /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/bin/ruby
CPU: octa-core 64-bit kabylake
Clang: 12.0.5 build 1205
Git: 2.29.2 => /usr/local/bin/git
Curl: 7.64.1 => /usr/bin/curl
macOS: 11.2.3-x86_64
CLT: 12.5.0.0.1.1617976050
Xcode: 10.2.1
```
第一次使用 `brew update-reset`，没有指定仓库，更新了 Taps 下所有仓库都到最新提交位置。显示成功，但是不知道为啥，单单 homebrew-core 没有 pull。
第二次先删除源，重新 `brew tap` 关联后成功。重新执行各种 brew 命令，不在报 Warning。
```sh
rm -rf $(brew --repo homebrew/core)
brew tap homebrew/core
```


