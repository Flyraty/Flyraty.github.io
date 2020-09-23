---
title: Spark JDBC 及 join BNLJ 调优（WIP）
date: 2020-09-23 22:45:11
categories: BigData
tags: Spark
abbrlink: 1c8723dc
--- 

#### 前言
在用 Spark load impala 表做非等值连接时碰到了一些问题。表现为加载源数据慢及做 join 操作异常慢。本文记录逐步解决这些问题的过程。
<!--more-->

#### 记录
需求其实很简单，存在两张表，表A 和表B。
表A schema 如下。login_as_cfid 字段存在于表B 中的 $device_id_list 列表中。
```
root
 |-- id: long (nullable = true)
 |-- first_id: string (nullable = true)
 |-- $update_time: string (nullable = true)
 |-- login_as_cfid: string (nullable = true)
```
表B schema 如下，$device_id_list 为设备列表，其实是以 \n 分隔的字符串。。。。
```
root
 |-- id: long (nullable = true)
 |-- second_id: string (nullable = true)
 |-- $device_id_list: string (nullable = true)
 |-- $update_time: double (nullable = true)

```
现在需要找到 first_id 和 second_id 的对应关系。首先很自然的想到就是两张表做 join，join 的连接条件如下。
```scala
array_contains(col("$device_id_list"), $"login_as_cfid")
```

