---
title: Azkaban工作流的编写
tags: Azkaban
categories: BigData
abbrlink: f428d959
date: 2020-07-24 14:27:26
---


### 前言
本篇主要讲解如何使用 AzKaban Flow 2.0 来编写工作流。Flow 1.0 在以后的版本中会逐步移除。

<!--more-->


### 工作流

#### 基础工作流

- 建立 flow 2.0 标识文件 flow20.project（文件名字一定要是这个），并输入以下内容并保存文件
```
azkaban-flow-version: 2.0
```

- 建立 .flow 工作流文件，就是常见的 yml 格式。nodes 作为根节点，下面定义该工作流下的 job 和子工作流。type 代表 job 的类型，config 代表其配置。
```yml
nodes:
	- name: jobA
	  type: command
	  config:
	  	command: echo "simple basic flow"
```

- zip 压缩上述两个文件，然后上传压缩包到 azkaban project 下，就可以看到此工作流，可以手动执行 Execute Flow。

#### 定义 job 间的依赖关系
```yml
nodes:
	- name: jobA
	  type: noop
	  config:
	  	command: echo "this is jobA"
	  dependsOn:
	  	- jobB
	  	- jobC
	- name: jobB
	  type: command
	  config:
	  	command: echo "this is jobB"
	- name: jobC
	  type: command
	  config:
	  	command: echo "this is jobC"  		
```

#### 定义子工作流
工作流中也可以嵌套子工作流，
```yml
nodes:
	- name: child_flow
	  type: flow
	  config:
	  	key: value
	  nodes:
	  	- name: jobA
	  	  type: command
	  	  config:
	  	  	command: echo "this is a chile flow job"
	- name: jobB
	  type: command
	  config:
	   	command: echo "this is jobB"	  	  	

```

#### job 也可以依赖其他工作流
比如下面的 jobB 依赖于子工作流 child_flow
```yml
nodes:
	- name: child_flow
	  type: flow
	  config:
	  	key: value
	  nodes:
	  	- name: jobA
	  	  type: command
	  	  config:
	  	  	command: echo "this is a chile flow job"
	- name: jobB
	  type: command
	  config:
	   	command: echo "this is jobB"
	  dependsOn: 
	  	-  child_flow	

```


#### 条件工作流
只有当满足某些条件时，才会触发目标 job。Azkaban 提供了一些预定义宏作为条件

- all_done	对应的作业状态 FAILED, KILLED, SUCCEEDED, SKIPPED, FAILED_SUCCEEDED, CANCELLED
- all_success \ one_success	对应的作业状态 SUCCEEDED, SKIPPED, FAILED_SUCCEEDED
- all_failed \ one_failed	对应的作业状态 FAILED, KILLED, CANCELLED

下面是一些条件举例
`all_success || ${file_ready:file1} == "ready"`
`all_success || ${file_ready:file1} == "ready" && ${job:param1} == 1 `

下面是一个条件工作流的例子，只有当文件准备好之后，才会执行 start_import。关于 `$JOB_OUTPUT_PROP_FILE` 是一个运行时环境变量，上游 job 产生的条件信息会写入到该临时文件，并传递到下游 job。下游 job 通过  `${上游job名称:变量名}` 读取。不过需要注意，参数只能在同一个 flow 的上下游 job 间传递，而不能跨 flow。

```yml
nodes:
 - name: file_ready
   type: command
   config:
     command: echo '{"file1":"ready"}' > $JOB_OUTPUT_PROP_FILE

 - name: start_import
   type: command
   dependsOn:
     - file_ready
   config:
     command: echo "start import"
   condition: ${file_ready:file1} == "ready"
```

