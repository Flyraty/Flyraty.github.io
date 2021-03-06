---
title: Mac重装系统找不到磁盘主盘，无法抹掉
categories: 工具
tags: Mac
abbrlink: 23b10311
date: 2021-02-15 21:57:08
---

#### 前言
最近打算把自己 Mac 卖掉，重装系统碰到了个问题，搞了一天多才搞定，遂记录下。具体是在线重装系统进入到磁盘工具后，找不到主盘，只有一个不到 3G 的 disk0，无法抹掉主盘上的数据且重装系统的时候也识别不到主盘。和[这个问题](https://www.jianshu.com/p/69346847efd0)比较类似，不过解决办法真是扯了，网上都是千篇一律，说不清楚，根本不能解决😑 。
<!--more-->
![](https://tva1.sinaimg.cn/large/008eGmZEly1gnrhr55qq7j31400u0myu.jpg)
![](https://tva1.sinaimg.cn/large/008eGmZEly1gnrhr52lkxj31400u0dhc.jpg)
#### 解决办法
这个问题的本质其实就是 Macintosh HD 识别不到，直接进入系统，打开磁盘工具查看，发现 Macintosh HD 是灰色的，显示未装载，运行急救不管用。Macintosh HD - 数据正常。

command + R 进入到恢复模式磁盘工具下，发现根本找不到 Macintosh HD。此处，还偶尔碰到一个 -5010F 错误。

改用 U 盘引导重装，在才进入到磁盘工具下，发现 Macintosh HD 为灰色，此处建议直接抹掉灰色显示的宗卷。抹掉后，再次进入到重新安装 OS 界面，此时已经可以识别出 Macintosh HD ，剩下的就是跟着提示安装了。

关于制作系统盘，可以直接查看官方支持文档 - [如何创建可引导的 macOS 安装器](https://support.apple.com/zh-cn/HT201372)