---
title: SSH配置
tags: Hadoop
categories: BigData
abbrlink: 9a4d2557
date: 2020-04-10 14:21:19
---
### 什么是 SSH
ssh 是一种网络协议，用于计算机之间的加密登录。大致流程如下
<!--more-->
![](https://timemachine-blog.oss-cn-beijing.aliyuncs.com/img/007S8ZIlly1gefb36prmvj30ll0dm3z7.jpg)
### 配置 ssh

这个应该挺熟悉的了，在使用 github 的时候，为了避免每次提交推送输入密码，我们应该都已经配置过了。在提一下过程，以下是 Mac 的。

1. ssh-keygen -t rsa 以 RSA 算法生成秘钥
2. ssh-copy-id -i id_rsa.pub user@host 上传公钥到要免密登录的服务器
3. ssh-add -K id_rsa
4. 系统偏好设置 -> 共享 -> 勾选远程登录
5. 如果需要 ssh localhost，也需要复制公钥到自己的 authorized_keys，cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

### 多台机器配置 SSH 免密登录
比如有三台机器 hadoop1 hadoop2 hadoop3。在每台机器上执行以下命令

 - ssh-keygen -t rsa -P “”
 - cd .ssh
 - cat id_rsa.pub >> authorized_keys

分别登录 hadoop2 hadoop3，执行以下命令
 - ssh-copy-id -i id_rsa.pub hadoop1
 
这时候 hadoop1 上的 authorized_keys 就是全的了，在从 hadoop1 上分发到其他机器
 - scp /root/.ssh/authorized_keys hadoop2:/root/.ssh/
 - scp /root/.ssh/authorized_keys hadoop3:/root/.ssh/
至此三台机器间已经可以免密登录
