---
title: Mac 上 VmwareFusion配置静态 IP
date: 2020-06-29 17:45:04
tags: mac
---
### 背景
由于学习原因，在 mac 上下了 Vmware Fusion 构建虚拟机搭建集群。（emnn，我也想用 docker 呀，奈何水平不大够）。配置静态 IP 的时候，发现和 windows 上的一点也不一样，碰到了一些问题，遂记录下来。
<!--more-->

### Vmware Fusion 配置静态IP
1. 点击虚拟机窗口，修改网络适配器设置，改为 net 模式
![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gg961uax3fj311m0oqage.jpg)

2. 查看 Mac 本机的网络配置

	- 进入 Vmaware Fusion 的 vmnet8 目录，
	```sh
	cd /Library/Preferences/VMware\ Fusion/vmnet8
	```
	`less nat.conf` 查看 nat.conf。其中的 NET gateway address 中的 ip 就是本机网关地址，netmask 是子网掩码。
	![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gg96l82g99j31bc0s00wy.jpg)

	`less dhcpd.conf` 查看 dhcpd.conf。其中的 range 代表虚拟机允许选择的惊静态 ip 地址范围，我这里的范围就是 172.16.242.128 ~ 172.16.242.254
	![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gg96ptija2j30w60ac402.jpg)

	- 获取 DNS，在 mac 系统偏好设置 -> 网络 -> 高级 -> DNS
	![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gg96s7pdfij30zs0n6amb.jpg)


3. 登录你装的虚拟机系统，修改 /etc/sysconfig/network-scripts 目录下的 ifcfg-en 开头的文件。修改如下，修改的内容主要有
```
BOOTPROTO=static
ONBOOT=yes
IPADDR=172.16.242.130  -> 你要设置的静态 IP
GATEWAY=172.16.242.2 -> 上面第二步获取的本机网关地址
NETMASK=255.255.255.0 -> 上面第二步获取的子网掩码
DNS1=210.22.84.3 -> 上面第二步获取的 DNS，这里可以配置多个 DNS，比如下面在加个 DNS2
```
![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gg96v7nn0kj30j80i4tax.jpg)

4. 重启 network 服务， service network restart

5. 至此，静态 IP 配置已经 OK 了。只要虚拟机开启，你就可以直接用 iTerm ssh 直连虚拟机，而不用进到 vmware fusion 打开的终端。
