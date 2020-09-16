---
title: hexo绑定域名和更换网站图标
categories: hexo
tags: hexo
description: hexo绑定域名和更换网站图标
abbrlink: ea2b28e2
date: 2020-09-16 13:17:37
---

### 绑定域名
- 注册域名，我选的是阿里云，注册了 .icu 域名。需要经过实名认证后才能使用，然后域名管理中更改下主体信息。基本上跟着步骤走就行。
- 域名解析，在域名管理中新建 CNAME 域名解析，其中记录值就是你要将注册域名解析到哪里，比如我这里就是 flyraty.github.io。
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gisghn2l7rj31ue04qwfe.jpg)
- 修改 github pages 配置，去往你的博客仓库，点击 settings 找到如下内容，修改 custom domain
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gisglk8oymj31h60pugqt.jpg)


### 更换网站图标
- 去图标库下载自己喜欢的图标，推荐[阿里矢量图标库](https://www.iconfont.cn/)。下载图标的 32*32，16*16 尺寸。
- 复制两张图标文件到 `themes/next/source/images`
- 修改主题配置文件，更改 favicon 的 small 和 medium 选项
```
favicon:
  small: /images/jiqiren-16x16.svg
  medium: /images/jiqiren-32x32.svg
```
- `hexo d -g` 部署你的站点
