---
title: hexo + github pages 打造你自己的博客
tags: hexo
categories: hexo
abbrlink: c5404504
date: 2020-09-07 14:27:36
---

### 前言
一周前手贱，`spark.write.mode("overwrite").save("xxx")` 覆盖了家目录，导致大部分代码和博客源文件被删除，mac 的个性化配置基本上也都没了，欲哭无泪，生活还要继续。一切从头再来吧，本文记录重新搭建博客的过程，踩坑甚多（主要是 next 7.x 相比以前的版本更改了很多配置项）。本文主要参考了 [小丁的博客](https://tding.top)。
<!--more-->
tips: 强烈建议大家一定要备份，备份，备份！

### hexo 

#### hexo 安装
创建 github pages 和创建普通的 github 仓库没太大区别（记住仓库名称是 username.github.io 就行了），这里就不在赘述了。以下的安装基于 mac，其实都差不多，现在的操作系统都提供了良好的包管理工具用于简化软件的安装。
- 安装 node 和 npm
```sh
brew install node
```
如果你想安装其他版本的 node，可以使用 `brew search node` ，找到对应的版本包然后安装。
- 安装 hexo 
```sh
npm install -g hexo-cli
```
- hexo init
hexo 初始化并自动创建博客目录，根据提示，初始化完成后，进入到博客目录，执行 `npm install`
```
hexo init Flyraty.github.io
```
- 常用命令
```sh
hexo d -g 生成并部署
hexo s 本地部署
hexo g 生成站点
hexo clean
hexo new 新建文章
```

#### 基础配置
一下是一些基础配置，主题选择，页面布局等，我们只需要记住两个配置文件就行了。
- 站点配置文件 `_config.yml`
- 主题配置文件 `themes/主题名/_config.yml`，我这里就是 `themes/next/_config.yml`

##### next 安装
下载解压放入 themes 目录或者 git clone。
```
git clone https://github.com/iissnan/hexo-theme-next themes/next
```
推荐 git 的方式，可以持续跟进更新 next。也可以用 git submoudle 维护。
```
git stash
git pull
git stash pop
```
##### 启用 next
编辑站点配置文件，修改 theme 选项。
```yml
theme: next
```
##### 更换 Schema
next 主题同样有好几种模板，这里选用的是 Gemini，因为文章间的界限比较清晰。
```yml
# Schemes
#scheme: Muse
#scheme: Mist
#scheme: Pisces
scheme: Gemini
```

##### 新建标签，分类，关于页面
会在 source 目录下生成对应的文件夹。这几个页面也是 markdown 文件，你可以自由编辑，比如关于页面。
```
hexo new page tag
hexo new page categories
hexo new page about
```
##### 设置站点语言
修改站点配置文件，如果你发现配置不管用的话，可以查看下 `themes/next/languages` 目录，看下是否存在 zh-Hans.yml 或者 zh-CN.yml。如果只存在 zh-CN.yml，重命名成 zh-Hans.yml 即可。
```yml
language: zh-Hans
```
##### 设置侧边栏菜单
修改主题配置文件，想显示哪个菜单，把对应的注释去掉就行。
```yml
menu:
  home: / || fa fa-home
  about: /about/ || fa fa-user
  tags: /tags || fa fa-tags
  categories: /categories || fa fa-th
  archives: /archives || fa fa-archive
  #schedule: /schedule/ || fa fa-calendar
  #sitemap: /sitemap.xml || fa fa-sitemap
  #commonweal: /404/ || fa fa-heartbeat
```
##### 侧栏位置
修改主题配置文件
```yml
sidebar:
  # Sidebar Position.
  position: left
  #position: right
```
##### 头像
修改主题配置文件，可以选择是否圆框，是否鼠标点击头像旋转。
```
# Sidebar Avatar
avatar:
  # Replace the default image and set the url here.
  url: https://avatars2.githubusercontent.com/u/24888835?s=400&u=20f46b828b9ee5d5a93dfce95ec7c01d07cff6cf&v=4
  # If true, the avatar will be dispalyed in circle.
  rounded: true
  # If true, the avatar will be rotated with the cursor.
  rotated: true
```
##### 站点描述
修改站点配置文件，主要是站点名称，描述，关键字，作者这些
```yml
# Site
title: TimeMachine Notes
subtitle: '愿一直遇到有趣的人和事'
descriptin: '于离别之朝束起约定之花'
keywords: 大数据,bigdata,Mac,Linux,生活,life
author: 时光机
language: zh-Hans
timezone: Asia/shanghai

```
##### 开启阅读数，字数统计
修改主题配置文件
```
# Post wordcount display settings
# Dependencies: https://github.com/theme-next/hexo-symbols-count-time
symbols_count_time:
  separated_meta: true
  item_text_post: true
  item_text_total: false
  awl: 4
  wpm: 275
```
##### 不蒜子统计
添加站点统计，比如 uv，pv 这些，可以选择百度统计，谷歌统计，不蒜字等。可以参考[官方文档](https://theme-next.iissnan.com/third-party-services.html)。这里选用了不蒜子
修改主题配置文件
```yml
busuanzi_count:
  enable: true
  total_visitors: true
  total_visitors_icon: fa fa-user
  total_views: true
  total_views_icon: fa fa-eye
  post_views: true
  post_views_icon: fa fa-eye
```
##### 添加搜索栏
安装搜索插件
```sh
npm install hexo-generator-searchdb --save

```
修改站点配置文件，添加 search 配置
```yml
# search
search:
  path: search.xml
  field: post
  format: html
  limit: 10000
```
##### RSS 订阅
安装插件
```sh
npm install hexo-generator-feed --save

```
修改站点配置文件，添加以下内容
```
# RSS
# feed
# Dependencies: https://github.com/hexojs/hexo-generator-feed
feed:
  type: atom
  path: atom.xml
  limit: 20
  hub:
  content:
```
修改主题配置文件
```
follow_me:
  #Twitter: https://twitter.com/username || fab fa-twitter
  #Telegram: https://t.me/channel_name || fab fa-telegram
  #WeChat: /images/wechat_channel.jpg || fab fa-weixin
  RSS: /atom.xml || fa fa-rss
```
##### 相关文章
安装插件
```sh
npm install hexo-related-popular-posts --save
```
修改主题配置文件
```yml
related_posts:
  enable: true
  title: 相关文章推荐# Custom header, leave empty to use the default one
  display_in_home: false
  params:
    maxCount: 5
    #PPMixingRate: 0.0
    #isDate: false
    #isImage: false
    isExcerpt: fals
```
##### 社交地址
修改主题配置文件，用自带的图标其实就可以了
```yml
social:
  GitHub: https://github.com/Flyraty || fab fa-github
  Zhihu: https://www.zhihu.com/people/zhang-hai-liang-83-28 || fab fa-zhihu
  E-Mail: 139hailiangabc@gmail.com || fa fa-envelope
  Weibo: https://weibo.com/yourname || fab fa-weibo
  #Google: https://plus.google.com/yourname || fab fa-google
  #Twitter: https://twitter.com/yourname || fab fa-twitter
  #FB Page: https://www.facebook.com/yourname || fab fa-facebook
  #StackOverflow: https://stackoverflow.com/yourname || fab fa-stack-overflow
  #YouTube: https://youtube.com/yourname || fab fa-youtube
  #Instagram: https://instagram.com/yourname || fab fa-instagram
  #Skype: skype:yourname?call|chat || fab fa-skype

social_icons:
  enable: true
  icons_only: false
  transition: false
```
##### 自动生成摘要
自动生成摘要在 next7 中被去除掉了。不想显示全文的话，有两种方式控制，建议第一种方式
- `<!--more-->`，会显示之前的内容，之后的内容不会显示
- 文章 meta 中添加 description字段 
不要在设置啥 auto_encrypt 了。。。

##### 添加 Disqus 评论系统
访问 `disqus.com`，选择 `i want to install disqus on my site`。然后跟着提示一步步走，只需要记住自己的 shortname 即可。
修改主题配置文件
```yml
 Disqus
disqus:
  enable: true
  shortname: flyraty
  count: true
  #post_meta_order: 0
```

##### 部署到 git
安装插件
```
npm install hexo-deployer-git --save
```
修改站点配置文件，部署站点，如果你以前没有使用过 git 的话，最好配置下 SSH
```
deploy:
  - type: git
    repo: git@github.com:Flyraty/Flyraty.github.io.git
    branch: master

```
直接 `hexo d -g` 并不会把你的博客源文件，比如文章 markdown push 到仓库，只是生成 public 下的静态 html push 到了站点进行渲染。此处建议新开一分支 hexo ，push 站点源文件到 hexo 分之上用于备份，可以把 hexo 分支设置为默认分支。


#### 美化
##### 代码框风格，并添加复制按钮
修改主题配置文件，设置 theme 和 style
```yml
codeblock:
  # Code Highlight theme
  # Available values: normal | night | night eighties | night blue | night bright | solarized | solarized dark | galactic
  # See: https://github.com/chriskempson/tomorrow-theme
  highlight_theme: night
  # Add copy button on codeblock
  copy_button:
    enable: true
    # Show text copy result.
    show_result: true
    # Available values: default | flat | mac
    style: mac
```
##### 动态背景图片
新建 source/_date/styles.styl，添加如下代码，如果想要设置动态背景效果，只需要将 `background:url`替换成一个动态背景接口就行了。
设置了背景图片，可能会导致文字看不到，所以需要设置透明度。
tips: 推荐图片网址 `https://wallhaven.cc/`
<details>
	<summary>styles.styl</summary>>
	```css
	// 设置背景图片
	body {
	    background:url(/images/girl.jpg);
	    background-repeat: no-repeat;
	    background-attachment:fixed; //不重复
	    background-size: cover;      //填充
	    background-position:50% 50%;
	}

	//博客内容透明化
	//文章内容的透明度设置
	.content-wrap {
	  opacity: 0.9;
	}

	//侧边框的透明度设置
	.sidebar {
	  opacity: 0.9;
	}
	//菜单栏的透明度设置
	.header-inner {
	  background: rgba(255,255,255,0.9);
	}
	//搜索框（local-search）的透明度设置
	.popup {
	  opacity: 0.9;
	}
	```

</details>

修改主题配置文件，打开自定义 styles.styl 设置
```yml
custom_file_path:
	style: source/_data/styles.sty
```

##### 页面动画效果
hexo 内置了一些页面动态效果。如果想打开的话，只需要在主题配置文件里搜索打开即可。
- canvas_nest
- canvas_ribbon
- three_waves 

比如 canvas_nest
```yml
# Canvas-nest
# Dependencies: https://github.com/theme-next/theme-next-canvas-nest
canvas_nest:
  enable: false
  onmobile: true # display on mobile or not
  color: "0,0,255" # RGB values, use ',' to separate
  opacity: 0.5 # the opacity of line: 0~1
  zIndex: -1 # z-index property of the background
  count: 99 # the number of lines
```

##### 页面顶部加载阅读进度条
修改主题配置文件
```yml
# Reading progress bar
reading_progress:
  enable: true
  # Available values: top | bottom
  position: top
  color: "#37c6c0"
  height: 3px
```
##### 文章阅读进度条
安装插件
```sh
npm install hexo-cake-moon-menu --save
```
修改主题配置文件，添加如下内容
```yml
moon_menu:
  back2top:
    enable: true
    icon: fa fa-chevron-up
    func: back2top
    order: -1
  back2bottom:
    enable: true
    icon: fa fa-chevron-down
    func: back2bottom
    order: -2
```
next  自带了文章阅读进度条（pace 配置），但是不如这个插件好看。
##### 鼠标点击烟花效果
参考 [小丁的博客](https://tding.top/archives/58cff12b.html)
##### 修改页面布局为圆角
新建 source/_data/variables.styl
```css
// 圆角设置
$border-radius-inner     = 20px 20px 20px 20px;
$border-radius           = 20px;
```
修改主题配置文件，打开自定义 variables.styl 的设置
```yml
custom_file_path:
	variable: source/_data/variables.sty
```

##### 添加粒子时钟
参考 [小丁的博客](https://tding.top/archives/dd68b70.html)
##### 去掉底部·强力驱动·
修改主题配置文件
```
footer:
	power: false
```
##### 关于页面显示 github commit chart
参考 [小丁的博客](https://tding.top)

#### 优化加速
##### 启用 FastClick
修改主题配置文件
```
fastclick: true
```
##### 启用 QuickLink
修改主题配置文件，quickclick 用于资源文件的预加载
```yml
quicklink:
  enable: true

  # Home page and archive page can be controlled through home and archive options below.
  # This configuration item is independent of `enable`.
  home: true
  archive: true

  # Default (true) will initialize quicklink after the load event fires.
  delay: true
  # Custom a time in milliseconds by which the browser must execute prefetching.
  timeout: 3000
  # Default (true) will enable fetch() or falls back to XHR.
  priority: true

  # For more flexibility you can add some patterns (RegExp, Function, or Array) to ignores.
  # See: https://github.com/GoogleChromeLabs/quicklink#custom-ignore-patterns
  ignores:

```
##### SEO
主要就是生成站点地图并提交百度和谷歌收录，生成永久链接，参考 https://flyraty.github.io/posts/cfd1b897/


### 参考
[小丁的博客](https://tding.top)

