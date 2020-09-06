---
title: Spark Shuffle
date: 2020-08-31 14:29:14
tags: Spark
---
### 前言
在学习很多大数据处理框架时，我们都会听到 Shuffle 。那么 Shuffle 到底是什么？为什么需要 Shuffle 的存在呢？
本篇作为一个疑问篇？只有在写的时候，我才明白我个人对 Spark 整体框架了解的浅陋，就比如其 Shuffle 的内部实现机制，每种 transformations shuffle 阶段所用到的不同的数据结构，这些才是 Spark 相比 MR 更快的根本原因，而不仅仅是单纯的的 DAG 内存计算等。这些都需要我去了解和学习，等我学成归来在总结此篇。
<!--more-->

### Shuffle 是什么
我们常理解的 shuffle 就是洗牌过程，将有规则的牌打乱成无规则的。但是在数据处理过程中，shuffle 是为了将无规则的数据洗成有规则的（将分布在不同节点上的数据按照一定的规则汇聚到一起）。
对于 MR 来讲，shuffle 连接了 map 阶段和 reduce 阶段。
对于 Spark 来讲，可以理解为 shuffle 连接了不同的 stage 阶段。

### 为什么需要 Shuffle
对于 MR 来讲，受限于其编程模型，reduce 阶段处理的必须是相同 key 的数据，所以必然需要 shuffle。
对于 Spark 来讲，其依靠 DAG 描述计算逻辑，其中没有宽依赖时，不会进行 shuffle。遇到宽依赖时，会划分 stage，从而需要 shuffle。这也是 Spark 相比 MR 更快的原因之一（因为 shuffle 阶段涉及大量的磁盘读写和网络 IO，直接影响着整个程序的性能和吞吐量）。

### Spark Shuffle
Spark shuffle 的发展主要经历了以下几个阶段，下面会着重介绍下 HashShuffle 和 SortMergeShuffle。
- HashShuffle。
- 引入 File Consolidation 机制，优化了 HashShuffle。
- SortMergeShuffle + bypass 机制。
- Unsafe Shuffle。
- 合并 Unsafe Shuffle 到 SortMergeShuffle。
- Spark 2.0 后，完全去除 HashShuffle。

#### HashShuffle
#### SortMergeShuffle
#### bypass 机制