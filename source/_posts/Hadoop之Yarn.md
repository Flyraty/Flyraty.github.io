---
title: Hadoop之Yarn
date: 2020-07-06 14:26:16
tags: Hadoop
---
### 前言
YARN 作为最常见的资源调度管理器，它是如何工作的呢？
<!--more-->

### YRAN
在 [Hadoop 是什么]() 中简单提到了 Yarn 的主要组件。

- ResourceManager -> 接收处理客户端的请求，资源分配与调度，启动监控 ApplicationMaster，监控 NodeManager。
- NodeManager -> 单个节点上的资源管理，处理来自 ResourceManager 和 ApplicationMaster 的命令。
- ApplicationMaster -> 为应用程序申请资源并分配给内部任务。
- Container -> 运行 job 封装的容器，抽象出来部分 CPU，内存等资源供给使用。

#### Yarn 任务提交
1. 客户端提交任务给 ResourceManager
2. RM 处理客户端请求并分配 app_id 和资源提交路径
3. 客户端上传应用程序等信息到资源路径下，并请求 RM 分配 ApplicationMaster
4. RM 将请求添加到容量调度器中
5. NM 空闲后领取到 job 并创建 Container 和 ApplicationMaster
6. ApplicationMaster 从资源提交路径中下载应用程序相关信息到本地
7. ApplicationMaster 向 RM 申请运行多个 MapTask
8. RM 分配 MapTask 到其余的 NM 上
9. 其余 NM 创建任务运行的容器
10. ApplicationMaster 向其余 NM 上发送程序启动的脚本并运行
11. MapTask 运行完毕后，ApplicationMaster 会像 RM 申请运行 ReduceTask
12. ReduceTask 拉取 MapTask 产生的中间数据
13. ReduceTask 运行完毕后，MR 会向 RM 申请注销自己

#### Yarn 调度策略
具体配置可以通过修改 yarn-site.xml，`yarn.resourcemanager.scheduler.class`

##### FIFO
先进先出策略，容易阻塞小任务

##### Capacity Scheduler
容量调度策略，多队列模式，每个队列占用集群一定比例的资源，队列内部又采用 FIFO。比如可以设置常驻任务队列，临时任务队列。

#### Fair Scheduler
公平调度器，CDH 默认使用策略。举个例子，假设有两个用户 A 和 B，他们分别拥有一个队列。当A启动一个 job 而 B 没有任务时，A 会获得全部集群资源;当B启动一个 job 后，A 的 job 会继续运行，不过一会儿之后两个任务会各自获得一半的集群资源。如果此时 B 再启动第二个 job 并且其它 job 还在运行，则它将会和 B 的第一个 job 共享 B 这个队列的资源，也就是 B 的第二个 job 会用四分之 一的集群资源，而 A 的 job 仍然用于集群一半的资源，结果就是资源最终在两个用户之间平等的共享。
