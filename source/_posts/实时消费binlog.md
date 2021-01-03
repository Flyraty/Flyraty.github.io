---
title: 实时消费binlog（WIP）
abbrlink: d5c98b55
date: 2021-01-02 14:55:10
categories: BigData
tags: Spark
---

### 前言
最近工作中用到的，以前没有搞过 binlog，遂在本地完整的跑遍 demo 看看。整体数据流如下，Canal 接收 MySQL Binlog 到 Kafka。Spark Streaming 消费数据写到 ES。
<!--more-->
### 实时消费binlog 

#### 环境准备
#### 开启 MySQL Binlog
#### Canal 配置
#### Spark Streaming 消费 Kafka