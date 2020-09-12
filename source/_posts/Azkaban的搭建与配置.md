---
title: Azkaban的搭建与配置
tags: Azkaban
categories: BigData
abbrlink: 79bc37bf
date: 2020-07-09 14:26:39
---
### 前言
AzKaban 是一个任务流调度器，可以组织作业及工作流之间的依赖关系，使得任务按照我们所想的方式有序执行。并且可以轻便的实现报警监控。本文主要讲解如何以 mutible executor mode 部署 AzKaban，并提交简单的工作流做测试使用。
<!--more-->

### AzKaban 部署
AzKaban 主要有两部分组成，AzKabanWebServer 和 AzKabanExecutor。 顾名思义，webserver 主要用来接收请求，UI展示，executor 用于真实的任务执行，任务执行的状态，日志等信息依赖 Mysql 存储。
AzKaban 的部署和其他的分布式系统一样，下载安装包，配置好一台机器后，进行配置分发，然后先启动所有的 executor，在启动 webserver。

### 使用 docker 构建
这里不多说了，可以参考我的 github [docker_azkaban](https://github.com/Flyraty/docker_bigdata/tree/master/docker_azkaban)
