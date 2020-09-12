---
title: Java安装
tags: Hadoop
categories: BigData
abbrlink: c032fe54
date: 2020-05-03 18:15:54
---
### 为什么 Java 8 仍是主流
如今 Java 已经出到了 14，为啥子大家还是在用 Java 8。你有没有为这个困惑过呢。其实接受新事物都有这样的规律，一是新事物有足够的吸引力，大家主动去追求。二是旧事物被强制扼杀，只能转向新事物。
<!--more-->
### 安装 JDK
- 命令安装
寻找你想安装的 Java 版本，并查看
```sh
brew search java
brew search jdk
brew info  java
```
如果没有你想安装的 Java 版本，可以更新一下 brew 仓库，或者利用 [brew tap](https://segmentfault.com/a/1190000012826983) 添加第三方库
```sh
brew tap homebrew/cask-versions
```
安装 JDK 8
```sh
brew cask install homebrew/cask-versions/adoptopenjdk8
```
官网下载
[下载地址](https://www.oracle.com/java/technologies/javase-downloads.html)，找到自己想要的版本，下载对应的 dmg 文件，跟着一步步走就好了。

### 配置 JDK
这个见多了，大数据相关组件都要配置一个 JAVA_HOME，编写 ~/.bash_profile
```sh
# JAVA
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:.
```
如果存在多个 Java 版本怎么办呢，可以编写 ~/.bash_profile 如下，这样的话，在终端下通过 jdk10 和 jdk8 命令便可以切换版本。不过，需要注意，这样切换并不会切换默认版本，只在当前终端下有用。

```sh
export JAVA_8_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home
export JAVA_10_HOME=/Library/Java/JavaVirtualMachines/jdk-10.0.2.jdk/Contents/Home
export JAVA_HOME=$JAVA_8_HOME
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:.

alias jdk10="export JAVA_HOME=$JAVA_10_HOME"
alias jdk8="export JAVA_HOME=$JAVA_8_HOME"
```
### learn by the way
说实话，以前配置环境变量都是跟着模子一起配，没有细究过。这里面的 PATH $PATH $PATH: 到底是啥东西呢？
PATH - 可执行程序的搜索路径，通过 `echo $PATH` 可以查看。
$PATH: - 在当前环境变量下追加新的环境变量，一次多个的话可以用冒号分隔。
