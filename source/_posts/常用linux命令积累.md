---
title: 常用linux命令积累
categories: Linux
tags: Linux
abbrlink: a1fe0a10
date: 2020-09-18 17:45:54
---

#### 前言
工作中经常碰到的一些linxu命令组合
<!--more-->

#### 文件添加第一列
```sh
awk '{$1="order_data|"$1; print}'  xx.txt  >> xxx.txt
```
#### 文件添加第一行
1i 代指第一行
```sh
sed -i '1ievent_name|apid|pegtime|product_name|empno' xxx.txt

```