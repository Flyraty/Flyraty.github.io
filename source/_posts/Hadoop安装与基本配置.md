---
title: Hadoop安装与基本配置
tags: Hadoop
categories: BigData
abbrlink: 2679c08d
date: 2020-04-14 14:20:51
---
### Mac 上安装 Hadoop
- 前提条件
	- [Java 安装](https://flyraty.github.io/posts/c032fe54/)

- 命令安装
执行以下命令，hadoop 会被安装到 /usr/local/Cellar/Hadoop/${HADOOP_VERSION}，这样默认安装的是 Hadoop 的最新版本，修改配置可以直接去安装目录下。
<!--more-->
```sh
brew instll hadoop
```
- 预编译包安装
官网下载Hadoop的预编译包，地址是 https://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}-src.tar.gz，指定你想下载的版本就好了。下载下来后，直接解压缩，放到你想的目录。

### Hadoop的三种运行模式
- Local (Standalone) Mode 独立运行模式，Hadoop 默认的配置，运行在单个 java 进程中，常用于调试
- Pseudo-Distributed Mode 伪分布式模式，Hadoop 不同功能组件运行在不同进程，但是都运行在一个节点上
- Fully-Distributed Mode 完全分布式模式，Hadoop 运行在多个节点上

### 伪分布式启动 Hadoop
#### 修改配置文件
以下需要注意的是，如果配置文件不存在，可以从对应的 .template 模板文件复制或者重命名。

1. ${HADOOP_HOME}/etc/hadoop/core-site.xml，修改 Hadoop 的默认文件系统，配置 Hadoop 临时文件目录。默认在 /tmp/hadoop-${user.name}
```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/usr/local/hadoop-2.7.2/tmp</value>
    </property>

</configuration>
```
2. ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml，配置副本数
```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
```
3. [配置SSH](https://flyraty.github.io/posts/4feffbd0/)

4. ${HADOOP_HOME}/etc/hadoop/mapred-site.xml
```xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```
5. ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
```xml
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>
```

#### 启动 HDFS
1. 格式化 NameNode，多次格式化的时候有坑，主要原因是 DataNode 不认识格式化后的 NameNode，后面详细说。如果不先格式化 NameNode，start-hdfs.sh 的时候就不会启动 NameNode。
```sh
hdfs namenode -format
```
2. 启动 HDFS
```sh
start-hdfs.sh
```
3. jps 查看 HDFS 相关的进程是否启动成功。
![](https://timemachine-blog.oss-cn-beijing.aliyuncs.com/img/007S8ZIlly1gefmo350qjj30lc05874n.jpg)


4. 访问 localhost:50070，启动成功会看到 HDFS 的 web ui，可以查看 HDFS 的状态和基本信息。

5. 测试创建目录，上传文件。在 web ui 上可以查看文件。文件到底存在了 HDFS 的什么地方呢。和 hadoop.tmp.dir 的文件设置路径有关。
hadoop.tmp.dir/dfs/data 里。真实的文件目录层级比较深，比如我这个是在 tmp/dfs/data/current/BP-1094310977-192.168.102.5-1588517605135/current/finalized/subdir0/subdir0/blk_1073741825。相应的 NameNode 的数据在 /tmp/dfs/name/current 下面。
```sh
hadoop fs -mkdir -p /user/test
hadoop fs -put etc/hadoop/core-site.xml /user/test
```

#### 启动 Yarn

1. 启动 YARN，jps 查看是否有相关进程。
```sh
start-yarn.sh
```
2. 打开 localhost:8088 可以看到 Yarn 的 web UI
3. 测试运行 Map Reduce 程序，一开始运行了几次都不成功，UI 上查看日志显示 /bin/java 文件或者目录不存在。需要配置 hadoop-env.sh，yaer-env.sh，mapred-env.sh 中的 JAVA_HOME。
```sh
hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar wordcount /user/test/input  output
```

### Docker 搭建 Hadoop 集群（WIP）
#### 构建基础镜像，组装服务
一开始的想法很简单,想的就是 docker-compose 构建三个 centos 容器并组网。emmmm，其实没有考虑容易互联，通过 link 和 expose 开放端口的方式还没有尝试。这里先存下目前处理的东西

1. 编写 Dockerfile 构建基础镜像，安装 jdk，vim， curl， wget， ntp等搭建环境所需软件包。

2. 根据基础镜像，docker-compose 组装服务

#### 集群配置分发
编写分发脚本，rsync 或者 scp，一般是 rsync，速度快，只同步差异。emmm，编写的脚本也比较简单，按规律循环遍历节点，执行 rsync，接收要分发的内容作为参数
```sh
if [[ $# -eq 0 ]]; then
   echo "no params";
   exit;
fi

path=$1

file_name=`basename $path`

dir=`cd -P $(dirname ${file_name}); pwd`

user=`whoami`
for((host=1; host<4; host++)); do
echo ------------------- hadoop$host --------------
rsync -rvl $dir$file_name $user@hadoop$host:$dir
done
```
#### SSH 配置
参考 [配置SSH]()

#### NTP 时间同步
设置一台服务器作为时间服务器，其他服务器定期从时间服务器同步时间，保证多台结点时间一致。参考 [ntp 时间服务器同步](https://blog.51cto.com/14259167/2427537)

#### 启动整个集群
修改 Hadoop 配置文件，emmm，按照上面伪分布式搭建的修改就行，只不多 ResourceManager, default.FS 等需要替换成我们部署该进程的节点域名。并且编写 /etc/slaves用于指定该集群的子节点。所有修改完毕后，分发脚本。
`start-dfs.sh` 启动 HDFS 集群，注意要在启动 NodeManager 的节点上执行
`start-yarn.sh` 启动 yarn 集群，注意要在启动 ResourceManager 的节点上执行
`mr-jobhistory-daemon.sh start historyserver` 启动历史服务器，主要要在 historyserver 的节点上执行

#### 注意事项
- 只有在第一次启动的时候，执行 hadoop namenode format，不要多次执行

