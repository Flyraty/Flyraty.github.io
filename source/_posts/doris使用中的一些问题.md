---
title: doris/starrocks 碎碎念
date: 2022-07-13 11:36:29
categories: BigData
tags: 
	- Doris
  	- StarRocks 
---

### 前言
2020 年末入职作业帮，接触到了 doris，当时还是 doris on es，后来随着业务的发展，从 doe 切到 dorisdb，再到 starrocks，期间做过了很多基础测试（包括离线，实时摄入，doris 本身的数据集成工具，apache seatunnel 的 doris connector 等），也碰到过很多慢查询问题，内部的广告用户画像平台也是基于 starrocks 进行构建的。本文主要在回忆下碰到的问题吧，对一些至今仍未解决的问题也会留下自己的猜想，希望后面有机会可以在验证吧。


