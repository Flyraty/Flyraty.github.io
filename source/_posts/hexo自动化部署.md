---
title: github actions 实现 hexo 自动化部署
categories: hexo
tags: hexo
abbrlink: 1eb3f811
date: 2020-10-24 20:22:13
---

### 前言
使用 github pages 托管个人博客网站，使用双分支来保存博客源文件，使用 git submodule 来管理更新主题文件，使用 github actions 来做持续集成。
<!--more-->

### hexo 持续集成
#### 生成公钥私钥
这一步主要是为了 CI 中提交代码，生成了两个文件，公钥文件 github-deploy-key.pub，私钥文件 github-deploy-key。需要注意，如果你是在博客目录执行的命令，需要在 .gitignore 中加入这两个文件，避免上传到仓库中。
```sh
ssh-keygen -t rsa  -C "$(git config user.name)" -f github-deploy-key
```

#### 添加仓库环境变量
设置 HEXO_DEPLOY_PUB，value 是上步生成的 github-deploy-key.pub 文件内容。
![](https://timemachine-blog.oss-cn-beijing.aliyuncs.com/img/0081Kckwgy1gk0pc9xn3hj31yq0s6aex.jpg)
设置 HEXO_DEPLOY_PRI
![](https://timemachine-blog.oss-cn-beijing.aliyuncs.com/img/0081Kckwgy1gk0pe8e498j321e0t8djp.jpg)

#### 添加 workflow
编写 workflow，新建的时候会有对应的注释提示你该如何写。**需要注意的是 submodule 不会自动下载，需要添加 check submodules 这一步。**
```yml
name: CI
on:
  push:
    branches:
      - hexo
jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout source
        uses: actions/checkout@v1
        with:
          ref: hexo
      - name: Configration hexo repo
        env:
          ACTION_DEPLOY_KEY: ${{ secrets.HEXO_DEPLOY_PRI }}
        run: |
          mkdir -p ~/.ssh/
          echo "$ACTION_DEPLOY_KEY" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan github.com >> ~/.ssh/known_hosts
          git config --global user.email "1397554745@qq.com"
          git config --global user.name "Flyraty" 
      - name: Checkout submodules
        run: |
          git submodule init
          git submodule update
      - name: Use Node.js ${{ matrix.node_version }}
        uses: actions/setup-node@v1
        with:
          version: ${{ matrix.node_version }}
      - name: Setup Hexo
        run: |
         npm install hexo-cli -g
         npm install 
      - name: Hexo deploy
        run: |
          hexo clean
          hexo d


```

#### 测试持续集成
本地 hexo 分支提交代码即可，部署站点会由 github actions 自动完成。可以去仓库 actions 设置中查看执行完成的 flow。如果有错，点开查看错误的 step 修改即可。 