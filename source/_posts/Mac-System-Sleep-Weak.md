---
title: Mac System Sleep Weak Failure
tags: Mac
categories: 工具
abbrlink: dbfe9aba
date: 2020-08-31 14:29:43
---
### 前言
最近更新了 mac 系统到 Catalina 10.15.6，然后碰到了一个鬼问题 System sleep weak failure。mac 在睡眠一段时间后，无法唤醒，然后就自动重启。一开始没在意，后来实在受不了每天都重启电脑，然后又重新打开所有应用，怎么办嘞，找办法解决。
<!--more-->

### Solve System sleep weak failure
看到最多的办法是重置，然而对我并没有啥用。这里也放上了，万一试试对你有用嘞。

- [重置 NVRAM](https://support.apple.com/zh-cn/HT204063)
- [重置 SMC](http://support.apple.com/zh-cn/HT201295)
最终的解决办法是通过 pmset 重置了 sleep 时间。pmset 用于电源管理相关的设置，在系统偏好设置-节能-电源可以看到其一些设置选项，但是 pmset 更加灵活。
首先 `pmset -g custom` 看下目前电脑电源相关设置
![](https://tva1.sinaimg.cn/large/007S8ZIlly1giay085zyhj30s411maeu.jpg)

正常的话，应该是 sleep ≥ displaysleep ≥ disksleep。我这里 sleep 为 0 代表被禁用了（emmm，好像是我自己在节能里设置里不让电脑自动进入睡眠，设置之前也有 System sleep weak failure）。

- sleep -> mac 闲置多长时间后进入睡眠
- displaysleep -> mac 闲置多长时间后显示器进入睡眠
- disksleep -> mac 闲置多长时间后硬盘进入睡眠
打开 sleep ，并按照正常顺序设置。 `sudo pmset -a sleep 15`。第二天早上，打开电脑终于没了 System sleep weak failure。问题解决。

不过解决的方式有点迷糊，这东西产生的原因也不清楚，就当做一次记录吧。


