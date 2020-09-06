---
title: Docker常用命令
date: 2020-07-29 14:28:05
tags: Docker
---
### 前言
本篇用来持续更新记录在使用 Docker 过程中经常遇到的命令以及一些小问题
<!--more-->

### compose 后台启动所有服务
```sh
docker-compose up -d
```
### compose 重新构建依赖镜像
```sh
docker-compose up --build
```
### 快速检查容器基本信息
```sh
docker inspect ${container_id} # 关于 container 的查看，使用 docker ps -a
```
### 查看容器日志
```sh
docker log ${container_id}
```
### 删除所有已经停止的容器
```sh
docker rm `docker ps -a | grep Exited | awk '{print $1}'`
```
### 删除所有构建过程中出错的镜像，这里就是简单删除了 TAG 为 None 的
```sh
docker rmi `docker images | grep '<none>' | awk '{print $3}'` # 注意只有删除了依赖镜像的相关容器后才能删除基础镜像
```
