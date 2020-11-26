---
title: vim常用的命令
tags: Linux
categories: 工具
abbrlink: 15118c2d
date: 2020-05-26 14:24:16
---

#### 背景
脑子老是记不住东西，每次都反复查，遂分类记录下来
<!--more-->

#### vim 替换
- 全局替换
```sh
:%s/foo/bar/g
```
- 当前行替换
```sh
:s/foo/bar/g
```
- 指定行替换，比如下面是替换一行到四行
```sh
:1,4s/foo/bar/g
```

#### vim 查看文件编码
```sh
: set fileencoding
```
如果你想改变当前文件的编码的话，可以直接设置 fileencoding 的属性，不过直接更改可能会造成乱码。
```sh
: set fileencoding=utf-8
```
#### 显示行号
```sh
:set number
```
#### 撤销更改
```sh
u 或者 ctrl+R
```

#### 快速跳行
命令行模式下输入行号即可
```
: 17
```

#### 复制粘贴到系统剪切板
参考[如何将 Vim 剪贴板里面的东西粘贴到 Vim 之外的地方？](https://www.zhihu.com/question/19863631/answer/89354508)
```
+Y 复制当前行
+nY 复制当前行往下 n 行
```

