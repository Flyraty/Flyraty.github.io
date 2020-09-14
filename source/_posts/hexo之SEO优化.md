---
title: hexo之SEO优化
categories: hexo
tags: hexo
abbrlink: cfd1b897
date: 2020-09-14 15:05:32
---

### 前言
为你的站点生成站点地图并提交百度和谷歌收录

### 文章永久链接
这样你修改文章名称或者日期后，文章链接不会发生变化
安装插件
```
npm install hexo-abbrlink --save

```
修改站点配置文件
```
permalink: posts/:abbrlink/
abbrlink:
    alg: crc32   #算法： crc16(default) and crc32
    rep: hex
```

### 生成站点地图
安装插件
```sh
npm install hexo-generator-baidu-sitemap --save
npm install hexo-generator-sitemap --save
```
修改站点配置文件
```
url: https://flyraty.github.io
# sitemap
Plugins:
  - hexo-generator-baidu-sitemap
  - hexo-generator-sitemap
baidusitemap:
  path: baidusitemap.xml
sitemap:
  path: sitemap.xml
```
`hexo g` ，`hexo s` 后，可以访问 `localhost:4000/sitemap.xml` 查看站点地图。

### 提交到 google search console
查看站点是否被收录。
```
site:https://flyraty.github.io
```
登录 google search console ，验证自己对网站的所有权，选择适合自己的方式，建议选择验证码方式，直接修改主题配置文件
```
google_site_verification: zkSnlx4XqngA-8SYFGRahJ85Xh3odO9uB6ILJk6UZHM
```
重新部署后，点击验证。提交 sitemap。

### 提交百度收录
登录百度搜索资源平台，添加站点信息，验证自己对网站的所有权，建议选择验证码方式，直接修改主题配置文件
```
baidu_site_verification: code-XBmDG5fVMm
```
提交 sitemap

### 新文章自动提交百度收录
安装插件
```sh
npm install hexo-baidu-url-submit --save
```
修改站点配置文件
```
baidu_url_submit:
  count: 3 ## 比如3，代表提交最新的三个链接
  host: https://flyraty.github.io ## 在百度站长平台中注册的域名
  token: xxxxx ## 请注意这是您的秘钥， 请不要发布在公众仓库里!
  path: baidu_urls.txt ## 文本文档的地址， 新链接会保存在此文本文档里
```
以后每次 hexo d -g 的时候都会主动推送百度
