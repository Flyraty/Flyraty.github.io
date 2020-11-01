---
title: Apache Kafka实战-简明了解Kafka
date: 2020-11-01 10:54:37
categories: BigData
tags: [kafka,zookeeper]
---

### 前言
Kafka 是一个消息流处理引擎并支持实时流处理。Kafka 将消息以 topic 为单位进行归纳，将向 Kafka topic 发送消息的程序称为 producer，将订阅 topic 消息的程序称为 consumer。Kafka 以集群的方式运行，由一个或者多个服务组成，每个服务被称作 broker。producer 通过网络向 kafka 集群发送消息，consumer 通过 poll 的方式向 kafka 集群订阅消息。
Kafka 并不只是单纯的消息队列，其实所有的分布式处理框架相对于传统的处理框架都有高可靠，高容错，易于伸缩的特性。Kafka 是怎么实现这些特性的呢？
Kafka 经常用作接收实时数据流，应用解耦合，流量削峰，如何保证 Kafak 集群的高效运行呢？
在数据处理过程中，我们往往作为数据下游消费者，如何编写一个高效的 consumer 呢？Kafka 与其他大数据处理框架（比如 Spark，Flink ）是怎么集成的呢？
<!--more-->

### Kafka

