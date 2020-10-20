---
title: 本机搭建zookeeper与kafka伪集群
categories: BigData
tags: [kafka,zookeeper]
abbrlink: 5f8acd6f
date: 2020-10-20 11:42:32
---

#### 前言
直接 brew 安装的 zookeeper 与 kafka 最新版本。但是搭建 zookeeper 集群的时候，zkServer 一直启动失败。遂记录。
<!--more-->

#### zookeeper
brew 一下即可，需要注意的是安装目录，zookeeper 默认安装在 `/usr/local/Cellar/zookeeper`，配置文件默认在 `/usr/local/etc/zookeeper`。
```
brew install zookeeper
```
因为是搭建伪集群，所以进入到配置文件目录下，复制三份 zoo.cfg，分别命名为 zoo1.cfg zoo2.cfg zoo3.cfg，编写配置文件如下（配置文件大抵一致，只需要注意端口号，因为是本机只有一台机器），以 zoo1.cfg 为例

```
tickTime=2000 # 心跳和超时的时间单位
initLimit=10 # follower 连接 leader 的超时时间，10 * tickTime
syncLimit=5 # follower 与 leader 同步的超时时间，5 * tickTime
dataDir=/usr/local/var/run/zookeeper/data/zookeeper1  # 快照及 myid 保存目录
clientPort=2181 # 提供服务的端口
server.1=localhost:2888:3888 # 1 是 myid，2888 用于连接 leader，3888 用于选举 leader
server.2=localhost:2889:3889
server.3=localhost:2890:3890
```

配置 myid，如果目录未创建的话需要先创建目录
```sh
echo "1" > /usr/local/var/run/zookeeper/data/zookeeper1/myid
echo "2" > /usr/local/var/run/zookeeper/data/zookeeper2/myid
echo "3" > /usr/local/var/run/zookeeper/data/zookeeper3/myid
```
开始启动 zkServer，因为我设置了环境变量，可以直接使用 zkServer，不在赘述
```
zkServer start zoo1.cfg
zkServer start zoo2.cfg
zkServer start zoo3.cfg
```
启动过程中遇到的问题，zkServer 一直报 failed start。查看日志，有以下错，关于日志目录的话，可以直接查看 log4j.properties

```java
java.lang.NoSuchMethodError: java.nio.ByteBuffer.clear()Ljava/nio/ByteBuffer;
        at org.apache.jute.BinaryOutputArchive.stringToByteBuffer(BinaryOutputArchive.java:80)
        at org.apache.jute.BinaryOutputArchive.writeString(BinaryOutputArchive.java:110)
        at org.apache.zookeeper.data.Id.serialize(Id.java:51)
        at org.apache.jute.BinaryOutputArchive.writeRecord(BinaryOutputArchive.java:126)
        at org.apache.zookeeper.data.ACL.serialize(ACL.java:52)
        at org.apache.zookeeper.server.ReferenceCountedACLCache.serialize(ReferenceCountedACLCache.java:152)
        at org.apache.zookeeper.server.DataTree.serializeAcls(DataTree.java:1359)
        at org.apache.zookeeper.server.DataTree.serialize(DataTree.java:1372)
        at org.apache.zookeeper.server.util.SerializeUtils.serializeSnapshot(SerializeUtils.java:171)
        at org.apache.zookeeper.server.persistence.FileSnap.serialize(FileSnap.java:227)
        at org.apache.zookeeper.server.persistence.FileSnap.serialize(FileSnap.java:246)
        at org.apache.zookeeper.server.persistence.FileTxnSnapLog.save(FileTxnSnapLog.java:472)
        at org.apache.zookeeper.server.persistence.FileTxnSnapLog.restore(FileTxnSnapLog.java:291)
        at org.apache.zookeeper.server.ZKDatabase.loadDataBase(ZKDatabase.java:285)
        at org.apache.zookeeper.server.quorum.QuorumPeer.loadDataBase(QuorumPeer.java:1090)
        at org.apache.zookeeper.server.quorum.QuorumPeer.start(QuorumPeer.java:1075)
        at org.apache.zookeeper.server.quorum.QuorumPeerMain.runFromConfig(QuorumPeerMain.java:227)
        at org.apache.zookeeper.server.quorum.QuorumPeerMain.initializeAndRun(QuorumPeerMain.java:136)
        at org.apache.zookeeper.server.quorum.QuorumPeerMain.main(QuorumPeerMain.java:90)
```
查了下错误，是新版本的 zookeeper java 版本不向下兼容的问题，要么升 java 版本，要么降低 zk 的版本。emmn，因为我本机本来就有两套 java，可以在当前终端下直接切换，遂切换到 jdk10，正常启动。

```sh
# java
export JAVA_8_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home
export JAVA_10_HOME=/Library/Java/JavaVirtualMachines/jdk-10.0.2.jdk/Contents/Home
export JAVA_HOME=$JAVA_8_HOME
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:.

alias jdk10="export JAVA_HOME=$JAVA_10_HOME"
alias jdk8="export JAVA_HOME=$JAVA_8_HOME"
``` 

查看 zkServer 的状态
```sh
zkServer status zoo1.cfg
zkServer status zoo2.cfg
zkServer status zoo3.cfg
```

#### kafka

brew 一下即可
```sh
brew install kafka
```

kafka 伪集群的搭建比较简单，进入到配置文件目录 `/usr/local/Cellar/kafka/2.6.0/libexec/config`，复制出三份 server.properties。以 server1.properties 为例，需要改动的就是 broker.id，listiners，log.dirs
```
broker.id=0
delete.topic.enable=true
listiners=PLAINTEXT://localhost:9092
log.dirs=/data/kafka1
zookeeper.connect=localhost:2181,localhost:2182,localhost:2183
unclean.leader.election.enable=false
zookeeper.connection.timeout.ms=6000
```
启动 kafka
```sh 
kafka-server-start -daemon server1.properties
kafka-server-start -daemon server2.properties
kafka-server-start -daemon server3.properties
```

测试 topic 的创建，消息的生产与消费
```sh
kafka-topics --zookeeper localhost:2181 --create --topic test_topic --partitions 3 --replication-factor 3
kafka-topice --zookeeper localhost:2181 --list
kafka-topice --zookeeper localhost:2181 --describe --topic test_topic
kafka-console-producer --broker-list localhost:9092 --topic test_topic
kafka-console-consumer --bootstrap-server localhost:9092 --topic test_topic --from-beginning  # 新版 consumer
kafka-console-consumer --zookeeper localhost:9092 --topic test_topic --from-beginning # 旧版 consumer
```