---
title: wakatime记录你的工作
categories: 工具
tags: wakatime
abbrlink: a92e8bd0
date: 2020-10-10 14:57:58
---

### 前言
偶然发现了别人的 github profile 多了一个 📊 Weekly development breakdown，用于展示各种语言工具的使用时长。感觉很有意思，遂研究了一下。
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gjk925gh1gj30pd02iq36.jpg)
<!--more-->

### wakatime
具体实现是有人已经写好的 waka-box plugin，github actions 定时更新 gist。具体的步骤可以见 [waka-box](https://github.com/matchai/waka-box)，这里不再赘述，只说几个需要注意的地方。

- 要想收集到 wakatime 的统计信息，需要先安装 wakatime 的 plugin，像常见的 Pycharm，IDEA，Sublime Text，Iterm，Chrome 都支持，具体的 plugin 安装见 [wakatime install plugin](https://wakatime.com/help/editors) 。
- github actions 需要先手动触发一次 workflow，后续的才能正常执行。修改你 fork 的 waka-box 仓库 .github/workflows 目录下的 schedual.yml 文件，修改以下内容设置手动触发，提交更改后，可以在 actions 界面看到该 flow 的 Run WorkFlow 按钮，点击运行。
```
on:
  workflow_dispatch:
```
- 你可能会发现 actions 运行完之后，你的 gist 提示 cann`t find any file。这个不用担心，检查下第一步的 plugin 是否安装，静静等待凌晨更新（UTC 凌晨实际上是北京时间早上8点）。

先上下我第一天的统计图
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gjk9i8qthwj31bi0laadd.jpg)

都搞定之后，可以将统计信息放到你自己 pinned 中


### 同名仓库

github 新建一个以你的账户名称命名的仓库会触发彩蛋，意思是该项目的 readme 会显示在 profile 中。其实就是自定义你的 github profile。
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gjk9mmheenj31em0d4wh3.jpg)

这里参考了 [liuyib](https://github.com/liuyib) 的仓库，通过 github 的 api 展示 github 的统计信息。就像下面这样
```sh
![flyraty's github stats](https://github-readme-stats.vercel.app/api?username=flyraty&show_icons=true)
```

![flyraty's github stats](https://github-readme-stats.vercel.app/api?username=flyraty&show_icons=true)


