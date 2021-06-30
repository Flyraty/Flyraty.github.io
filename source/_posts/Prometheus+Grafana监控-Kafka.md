---
title: Prometheus + Grafana 监控 - Kafka
categories: 大数据运维
tags:
  - Grafana
  - Prometheus
  - kafka_exporter
  - WIP
abbrlink: dc1a86bd
date: 2021-05-15 21:37:35
---

### 前言
最近工作中越来越感受到监控对于查找问题的重要性，一个完备的链路监控对问题定位和趋势分析提效非常高。比如一条实时数据流，从数据采集到消费到入库各个阶段都有一些可观测性的指标（binlog 采集延迟，kafka-lag，读写 QPS，max-request-size，offset 趋势）。如果 kafka-lag 比较小并且 topic 写 QPS没打太高，但是数据有延迟，这里大概率就是上游采集的问题。
这里借用 prometheus 官网的话介绍监控的作用。
- 长期趋势分析：通过对监控样本数据的持续收集和统计，对监控指标进行长期趋势分析。例如，通过对磁盘空间增长率的判断，我们可以提前预测在未来什么时间节点上需要对资源进行扩容。
- 对照分析：两个版本的系统运行资源使用情况的差异如何？在不同容量情况下系统的并发和负载变化如何？通过监控能够方便的对系统进行跟踪和比较。
- 告警：当系统出现或者即将出现故障时，监控系统需要迅速反应并通知管理员，从而能够对问题进行快速的处理或者提前预防问题的发生，避免出现对业务的影响。
- 故障分析与定位：当问题发生后，需要对问题进行调查和处理。通过对不同监控监控以及历史数据的分析，能够找到并解决根源问题。

本系列主要用来记录工作中常见系统的监控实现，指标含义以及如何通过监控定位问题并在相关任务挂掉后如何和给下游业务一个较准确的预估恢复时间。大部分借助开源实现。
<!--more-->

### Prometheus
#### 安装
直接 brew 安装启动即可，也可以参考 [prometheus 中文文档](https://yunlzheng.gitbook.io/prometheus-book) 通过预编译包安装。
```
brew info prometheus
brew install prometheus
brew services start prometheus
```
在 prometheus.yml 里面配置抓取的 job。 需要注意一下，如果是 mac os 的话，Prometheus 默认配置文件地址为 `/usr/local/etc/prometheus.yml`。

#### 使用
安装完成后，可以打开 `http://localhost:9090/` 查看 Prometheus UI。可以在 Status-Targets 里面找到已经启动抓取的 exporter。
![](https://tva1.sinaimg.cn/large/008i3skNly1grc1gm1u0qj31h80ltn0f.jpg)

Prometheus 大概的流程如下。更多的信息可以查看官方文档。其中 PromQL 以及 metric 的格式需要重点了解下，以后查询 metrics，配置 Grafana DashBoard 都会用到。
- Prometheus server 定期从配置的 job 拉取 metrics。
- Prometheus 将拉取的 metrics 信息存储到本地，记录新的时间序列。如果触发定义好的 alert.rules，AlterManager 会向用户发送报警。


### Grafana
#### 安装
```
brew info grafana
brew install grafana
brew services start grafana
```
#### 使用
打开 `http://localhost:3000/`，查看 Grafana UI，默认账户名密码是 admin/admin。使用流程和普通写程序差不多，全套 CURD。
1. 配置 DataSource
2. 配置 DashBoard，直接 load 模板或者自己写 PromQL.
3. 配置告警规则


### kafka_exporter
Kafka 本身自带了监控，内部通过 Yammer Metrics 进行指标的暴露与注册。kafka_exporter 可以


