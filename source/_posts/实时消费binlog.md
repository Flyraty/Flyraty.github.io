---
title: 实时消费 MySQL Binlog
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
在 Mac 上安装开源软件包都比较方便，brew 可安一切，用好 search，info，tap，insatall 几个命令就行了。安装 MySQL，Kibana，ElasticSearch。
Kafka 安装请参考 [Apache Kafka实战-搭建zookeeper与kafka集群](https://timemachine.icu/posts/5f8acd6f/)。
```
brew install mysql@5.7
brew install kafka
brew install elasticsearch
brew install kibana
```
用 brew 安装还有一个好处，就是可以依赖 brew 来管理启停服务。
```
brew services start mysql
brew services start elasticsearch
brew services start kibana
```
现在本地访问 `localhost:5601 和 localhost:9200` 就可以看到 Kibana 和 ES 的返回了。 

#### 开启 MySQL Binlog
Binlog 是 MySQL sever 层维护的一种二进制日志，主要用来记录 MySQL 产生更新时的行为（即产生变化的 SQL 语句）到磁盘。主要用来数据恢复，主从数据同步，数据备份。
开启 MySQL Binlog 只需要几步
- 修改 /etc/my.cnf
```sh
log-bin=mysql-bin #开启binlog
binlog-format=ROW #选择row模式
```
- 重启 MySQL 
```sh
brew service restart mysql
```
- 查看是否开启 Binlog。ON 代表开启，此时也可以看到 Binlog 在磁盘上的位置。
```sh
mysql> show variables like '%log_bin%'; 
+---------------------------------+---------------------------------------+
| Variable_name                   | Value                                 |
+---------------------------------+---------------------------------------+
| log_bin                         | ON                                    |
| log_bin_basename                | /usr/local/mysql/data/mysql-bin       |
| log_bin_index                   | /usr/local/mysql/data/mysql-bin.index |
| log_bin_trust_function_creators | OFF                                   |
| log_bin_use_v1_row_events       | OFF                                   |
| sql_log_bin                     | ON                                    |
+---------------------------------+---------------------------------------+
6 rows in set (0.00 sec)

mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000001 |      4070 |
| mysql-bin.000002 |       154 |
+------------------+-----------+
2 rows in set (0.01 sec)
```

#### Canal 配置
由于 Binlog 是二进制文件，不能直接查看，需要使用 MySQL 自带的查看工具 `/bin/mysql/binlog`。不过这样查看仍然不是很方便，对我们使用订阅 Binlog帮助不大。这个时候就需要 Canal 了。Canal 是阿里开源的基于数据库 Binlog 的增量消费/订阅组件，其原理是伪装成 MySQL Slaver，这样 Master 就会通过某些协议将 binlog 推送给我 Canal。Canal 做了一些解析工作，将 Binlog 转换为 JSON 格式便于后续处理。

- 下载 Canal
```sh
wget https://github.com/alibaba/canal/releases/download/canal-1.1.3/canal.deployer-1.1.3.tar.gz
tar -zxvf canal.deployer-1.1.3.tar.gz
```
- 配置 CANAL_HOME
```sh
export CANAL_HOME=/Users/zaoshu/canal
soure ~/.bash_profile
```
- MySQL 中创建 Canal 的用户
```sh
mysql>  CREATE USER canal IDENTIFIED BY 'canal';  
mysql>  GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
mysql>  GRANT ALL PRIVILEGES ON *.* TO 'canal'@'%' ;
mysql>  FLUSH PRIVILEGES;
```

- 修改 $CANAL_HOME/conf/example/instance.properties
```sh
# mysql slave id
canal.instance.mysql.slaveId=3
# mysql 地址
canal.instance.master.address=127.0.0.1:3306
# 上步配置的 mysql canal 用户
canal.instance.dbUsername=canal
canal.instance.dbPassword=canal
# 监控所有数据库中的所有表
canal.instance.filter.regex=.*\\..*
# binlog 对接的 kafka topic
canal.mq.topic=ms_binlog
```
- 修改 canal.properties
```sh
# Kafka broker 信息
canal.mq.servers = localhost:9092,localhost:9093,localhost:9094
# json 格式
canal.mq.flatMessage = true
```
- 启动 Canal
```sh
$CANAL_HOME/bin/startup.sh
```
- Kafka consumer 消费数据验证 Canal 是否启用成功
```sh
kafka-console-consumer --bootstrap-server localhost:9092 --topic ms_binlog --from-beginning

# Binlog 示例
{"data":[{"rec_id":"4","url_name":"nanshanweila","time":"2017-12-31","jiaofang_info1":"交房时间：2018年年底交付洋房3#、11#等","jiaofang_info2":"交房楼栋：10#，11#，12#，15#，16#，2#，21#，22#，23#，27#，28#，3#，4#，5#","jiaofang_info3":"交房详情：2017年年底交付洋房3#、11#、12#、15#、16#、4#、5#等。","kaipan_info1":null,"kaipan_info2":null,"kaipan_info3":null,"created_time":"2019-05-27 12:50:50","created_time_ts":"1558918250187"}],"database":"fangtianxia","es":1610378360000,"id":3,"isDdl":false,"mysqlType":{"rec_id":"int(11)","url_name":"varchar(50)","time":"varchar(50)","jiaofang_info1":"text","jiaofang_info2":"text","jiaofang_info3":"text","kaipan_info1":"text","kaipan_info2":"text","kaipan_info3":"text","created_time":"datetime","created_time_ts":"bigint(20)"},"old":[{"jiaofang_info1":"交房时间：2017年年底交付洋房3#、11#等"}],"pkNames":["rec_id"],"sql":"","sqlType":{"rec_id":4,"url_name":12,"time":12,"jiaofang_info1":2005,"jiaofang_info2":2005,"jiaofang_info3":2005,"kaipan_info1":-4,"kaipan_info2":-4,"kaipan_info3":-4,"created_time":93,"created_time_ts":-5},"table":"newfangwork","ts":1610378360683,"type":"UPDATE"}
```

#### Spark Streaming 消费 Kafka
关于消费 Kakfa 可以直接参考官方文档上的代码 [Spark Streaming + Kafka Integration Guide ](https://spark.apache.org/docs/2.2.0/streaming-kafka-0-10-integration.html)。

```scala
import org.apache.kafka.clients.consumer.ConsumerRecord
import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.spark.sql.SparkSession
import org.apache.spark.streaming.dstream.InputDStream
import org.apache.spark.streaming.{Milliseconds, StreamingContext}
import org.apache.spark.streaming.kafka010._
import org.apache.spark.streaming.kafka010.LocationStrategies.PreferConsistent
import org.apache.spark.streaming.kafka010.ConsumerStrategies.Subscribe


object Kafka2ESDemo {

  def main(args: Array[String]): Unit = {

    val spark = SparkSession.builder().appName("Kafka2ESDemo").master("local[*]").getOrCreate()

    import spark.implicits._

    val sc = spark.sparkContext

    val checkpointDir = "./checkpoint"

    val ssc = new StreamingContext(sc, Milliseconds(100000))

    val kafkaParams = Map[String, Object](
      "bootstrap.servers" -> "localhost:9092",
      "key.deserializer" -> classOf[StringDeserializer],
      "value.deserializer" -> classOf[StringDeserializer],
      "group.id" -> "test",
      "auto.offset.reset" -> "earliest",
      "enable.auto.commit" -> (false: java.lang.Boolean)
    )

    val topics = Array("ms_binlog", "test_topic")
    val stream: InputDStream[ConsumerRecord[String, String]] = KafkaUtils.createDirectStream[String, String](
      ssc,
      PreferConsistent,
      Subscribe[String, String](topics, kafkaParams)
    )
    val resultDStream = stream.map(x => x.value())
    resultDStream.print()
    ssc.start()
    ssc.awaitTermination()
  }

}
```































