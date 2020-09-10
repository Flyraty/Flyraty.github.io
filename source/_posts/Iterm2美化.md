---
title: Iterm2 美化
date: 2020-09-08 11:24:24
tags: Mac
---

### 前言
工欲善其事，必先利其器。Iterm2 是 Mac 下的终端利器，支持标签变色，命令自动补全，智能选中，与 tmux 集成，大量易用的快捷键，通过配置 profile 可以快捷的登录到多个 remote 终端。
<!--more-->

### Iterm2 主题配置
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gileqar91oj31d90u0nph.jpg)

#### oh my zsh
on my zsh 通过提供开源的配置，只需要简单的修改配置文件就能增添插件，修改样式。安装如下
```
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```
安装完成后，会在用户家目录下生成 `~/.zshrc`（zsh 配置文件） 和 `.oh-my-zsh`（主题和插件的存放目录）。

tips：如果发现切换到 zsh 后，少了一些环境变量，可以直接在 `~/.zshrc` 开头加入 `source ~/.bash_profile`。


#### 常用插件
- Git 在主机名够显示 git 项目信息，比如分值，状态等
- zsh-syntax-highlighting 高亮显示常见的命令，在命令输错时，会报红
- zsh-autosuggestions 命令自动补全，输入命令时，会灰色显示出推荐命令，按右方向键即可补全。
有些插件需要安装，下载下来后直接放到 `~/.oh-my-zsh/custom/plugins` 即可，比如 `zsh-autosuggestions`。

```sh
git clone git://github.com/zsh-users/zsh-autosuggestions  ~/.oh-my-zsh/custom/plugins
```
然后修改 `~/.zshrc` 的 pluging 配置

```
plugins=(git z zsh-syntax-highlighting zsh-autosuggestions)
```
最后当然是重新 source 一下了
```
source ~/.zshrc
```

#### 主题配置
可以在 [oh-my-zsh 主题列表](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes) 里选用自己喜欢的终端样式，然后修改 `~/.zshrc`。
```
ZSH_THEME="ys"
```
修改主题配色，这里用的是 [Dracula](https://draculatheme.com/iterm/)，下载对应的主题文件，然后导入到 Iterm2 中。
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gilejtsgcej315x0u0b29.jpg)

#### 背景配置
可以在 profile -> window 中配置终端背景图片，然后自己调节一下终端透明度 Transparency
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gilekuryhuj31fe0t4drb.jpg)

#### status bar
逼格比较高，在 profile -> session 中启用 status bar 并配置。
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gileoqd2ifj31ek0teq9z.jpg)

![](https://tva1.sinaimg.cn/large/007S8ZIlly1gileork71nj31a90u0ahm.jpg) 

### sshpass + proilfe 快速登录远程终端
sshpass 用于在命令中直接提供服务器密码，而不用通过交互式输入。Iterm2  profile 中可以设置打开窗口时执行的 command。两者结合就可以实现快速登入远程服务器。
#### 安装 sshpass
- [sshpass 下载](https://sourceforge.net/projects/sshpass/files/)
- 解压缩后，进入到 `sshpass` 目录
- 执行 `./configure`
- 执行 `sudo make install`
- sshpass

sshpass 的简单使用
```
/usr/local/bin/sshpass -p '你的密码' ssh user@host
```
#### 配置 profile
在 profile  command 中输入命令即可
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gilf1rwxbkj318g0u0do6.jpg)

#### 快速连接
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gilgch0xhlj316o0aakbg.jpg)




