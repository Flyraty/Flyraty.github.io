---
title: Hadoop之HDFS
tags: Hadoop
categories: BigData
abbrlink: c508bdb8
date: 2020-07-04 14:25:57
---
### HDFS
Hadoop 分布式文件存储系统。用于海量数据的存储，往往是静态数据，适合 OLAP 分析。
<!--more-->
- 典型的 Master/Slaver 架构，NameNode 负责管理元数据和文件系统命名空间，处理来自客户端的请求，依赖 ZK 实现 HA 高可用。多个 DateNode 负责数据的存储，并上报自己的 block 信息。
- 伸缩性好，易于拓展，很容易拓展多个 DataNode。
- 高效，并发访问读取，按 block 大小切片读取。
- 高容错性，多副本机制保证了一台机器挂掉，文件不会丢失。
- 一次写入，多次读取，适用于 OLAP 分析。

### HDFS 客户端 API 操作
Hdfs 命令和普通的 linux 命令操作没啥区别。不过多解释。关于 API 操作，就是一句话，根据配置获取文件系统对象。就像下面这样

1. 引入相关 maven 依赖
```xml
<dependency>
          <groupId>org.apache.hadoop</groupId>
          <artifactId>hadoop-common</artifactId>
          <version>2.9.2</version>
      </dependency>
      <!-- https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-client-->
      <dependency>
          <groupId>org.apache.hadoop</groupId>
          <artifactId>hadoop-client</artifactId>
          <version>2.9.2</version>
      </dependency>
      <!-- https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-hdfs -->
      <dependency>
          <groupId>org.apache.hadoop</groupId>
          <artifactId>hadoop-hdfs</artifactId>
          <version>2.9.2</version>
      </dependency>
```
2. 代码编写，这里要主要的是权限问题，不指定用户容易出问题。emmm，第一次碰到权限问题还是写 Spark 的时候，Spark 默认存 Hdfs，如果要存本地文件，需要 file:// 标识本地文件系统。
```java
Configuration configuration = new Configuration();
FileSystem fs = FileSystem.get(new URI("hdfs://hadoop1:9000/"), configuration, "root");
fs.mkdirs(new Path("/test"));
fs.close();
```

### HDFS 读写机制
客户端与HDFS的读写其实也是一种网络通信。所以一开始的步骤肯定是互相问候
C: hello，我要读数据啦
N: 好的，数据在这个地方
C: hello，我要写数据了
N: 好的，我看看现在能不能写。可以写了
C: 那我写啦，这是我要写的数据，你看放在啥地方合适呢
N: 往这个地方写吧
C: 这个 D 挂了怎么办
N: 收到，我给你分配个新的

#### 机架感知
副本是如何选择机器存储的，如果副本都在一个机器上，那岂不是就没意义了。副本存储规则如下

 - 随机选取一个 DataNode 存储第一个副本，往往根据 DataNode 的具体使用情况。
 - 第二个副本存储在和第一个副本存储的DataNode相同机架的不同机器上。
 - 第三个副本存储在不同机架的节点。

#### HDFS 读数据流程
1. 客户端请求 NameNode 读取文件，NameNode 查找元数据信息，找到文件所在的 DataNode
2. 计算节点距离，找到离该客户端最近的 DataNode
3. DataNode开始传输数据给客户端(从磁盘里面读取数据输入流，以Packet为单位来做校验)。
4. 客户端以Packet为单位接收，先在本地缓存，然后写入目标文件。

#### HDFS 写数据流程
1. 客户端请求上传文件
2. NameNode 检查该文件及目录结构是否已经存在，如果存在，则返回客户端异常。不存在，告诉客户端可以上传
3. 客户端请求上传第一个 block 的存储位置
4. NmaeNode 返回相应的存储位置，
5. 客户端请求上传第一个 block，存储位置串行化 pipeline，dn1->dn2->dn3。dn1 收到请求发给dn2，dn2 收到请求发给 dn3
6. dn1，dn2，dn3 返回客户端应答信息
7. DataNode 以 packet 为单位接收数据，dn1 接收到了转给 dn2，dn2 转给 dn3
8. 重复 3~7 的步骤上传剩余的 block

#### 写过程发生错误怎么办
1. pipeline 被关闭，已经到故障节点的 packet 会被重新加到 pipeline 前端，保证管道中剩余的正常节点接收的 packet 不会丢失
2. 为已经正常存储在其他 DataNode 上的 Block 赋值一个新的 ID，并上报给 DataNode，保证故障节点恢复后的 DataNode 上删除上传失败后的不完整数据
3. pipeline 中删除故障节点信息，继续像其余正常节点上存储数据
4. namenode 监控到文件副本数不足时，会自动处理。

#### NN 与 2NN
关于元数据节点与元数据辅助节点，在[Hadoop 是什么](https://flyraty.github.io/2020/04/08/Hadoop%E5%AD%A6%E4%B9%A0-Hadoop%E6%98%AF%E4%BB%80%E4%B9%88/)中简单提了下，这里在重提下。

 - NameNode 启动生成 fsimage 快照，后续数据文件改动记录到 edits 日志
 - 2NN 定期询问 NmaeNode 是否需要 CheckPoint，如果需要，复制 fsimage，滚动 edits 日志文件。传输到 2NN 结点，进行 edits 日志与 fsimage 的合并。
 - 2NN 合并完成，生成一个新的 fsimage，传输到 NN 节点，重命名替换NN结点上的 fsimage。
为什么这样做呢？NmaeNode 作为元数据管理结点，肯定不能经常重启，在运行很长一段时间后，edits 日志文件已经很大，此时重启，fsimage 与 edits 日志文件合并时间较长，影响使用。所以有了 2NN 用来定期 checkpoint 合并，也降低了由于 NameNode 结点挂掉导致元数据大量丢失的风险。
