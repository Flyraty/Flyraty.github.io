---
title: 多个 git 账户配置 SSH
date: 2020-12-26 22:01:21
categories: Linux
tags: Linux
---
### 前言
个人代码维护在 github，而目前大多数公司代码维护在私有 gitlab。这是两套不同的账户体系，并且一般私有 gitlab 的 commit email 不能更改，git 全局的用户名和邮箱只能有一个。这就导致了如下问题 → 不管配置了几个 SSH pub key，SSH 认证最终走的都是 global 的用户名的认证（比如你全局的用户是 github 的，那么你提交 gitlab 就会报 Permission Denied）。本文主要用来解决此问题。
其实多个 SSH 配置的话都是这样搞的，配个路由就好了。

### 配置 SSH
#### github
生成 ssh pub key，并将其添加到 github settings 的 SSH 配置中。
```sh
ssh-keygen -t rsa -C '${your github emial}' -f github
```

#### gitlab
生成 ssh pub key，并将其添加到 gitlab settings 的 SSH 配置中。
```sh
ssh-keygen -t rsa -C '${your gitlab emial}' -f gitlab
```

#### SSH config
修改 ssh 配置文件，用来配置不同 host 下用的 SSH 验证文件是哪个。可以理解为路由，发的请求都会查阅此文件来确定验证的 key 是哪个。
```sh
Host gitlab
  HostName git.zuoyebang.cc
  User zhanghailiang01
  IdentityFile ~/.ssh/gitlab


Host github.com
  HostName github.com
  User xxx
  IdentityFile ~/.ssh/github
```

#### 验证
验证配置好的 SSH 是否可用
```sh
$ ssh -T git@gitlab
Welcome to GitLab, @xxx!

$ ssh -T git@github.com
Hi xxx! You've successfully authenticated, but GitHub does not provide shell access.
```
#### 使用
经过上步验证通过后，免密提交 gitlab 还有一定的问题。我们还需要修改对应 gitlab 项目的用户名和邮箱，因为我们提交代码的账户认证是这个，而不是 git 全局的用户。修改完成之后，可以查看对应项目下的 .git/config 文件是否修改成功。
```sh
git config --local user.name 'xxx' && git config --local user.email 'xxx@xxx.com'
```
对于以后新增的 gitlab 项目，都要执行此步。

