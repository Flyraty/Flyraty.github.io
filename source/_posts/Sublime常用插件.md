---
title: Sublime常用命令和插件
categories: 工具
tags: Sublime Text
abbrlink: 12d67bff
date: 2020-09-15 14:44:30
---

### 前言
鉴于每次电脑重装都要重新折腾一遍，遂创建一个[工具分类](https://flyraty.github.io/categories/%E5%B7%A5%E5%85%B7/)用于记录常见软件的配置安装及使用，本篇主要介绍 Sublime Text.
Sublime Text 是一款流行的代码编辑器软件，也是HTML和散文先进的文本编辑器，可运行在Linux，Windows 和 Mac OS X。也是许多程序员喜欢使用的一款文本编辑器软件。同样推荐[官方文档](https://www.sublimetextcn.com/)
<!--more-->

### 更换主题
- 安装 a file icon ，添加对应文件图片，改善视觉效果。 `Command + Shift + p` 搜索 Package Control ，安装对应插件即可。
- 安装 Agila 主题，同样的打开 Package Control 搜索安装。
- 修改自定义配置文件 Sublime Text -> Preferences -> settings。左边是默认配置文件，右边是自定义的。关于 Agila 主题，可以直接参考[文档](https://github.com/arvi/Agila-Theme)，我这里的配置文件如下
```
"color_scheme": "Packages/Agila Theme/Agila Origin Oceanic Next.tmTheme",
"ignored_packages":
	[
		"Vintage",
		"zzz A File Icon zzz"
	],
"theme": "Agila Origin.sublime-theme",
```

### Sql​Beautifier
主要格式化 SQL，打开 Package Control 搜索安装即可。`Command + k  && Command + f` 格式化 SQL 文件。

### 多行编辑模式
最常使用的是 Alt + 多选切换到多行编辑模式 → 加上 “” → `Command + J` 合并多行生成列表

### 设置文件修改自动保存
在自定义配置文件中加入 `"save_on_focus_lost": true`

