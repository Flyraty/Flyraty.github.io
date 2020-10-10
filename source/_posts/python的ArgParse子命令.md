---
title: python命令行解析模块ArgPrase
categories: python
tags: python
abbrlink: 29312bb7
date: 2020-10-09 15:24:17
---
### 前言
最近工作中需要封装一些 API 做成命令行工具，用到了 ArgParse，看似挺简单，其实坑也蛮多，主要是子命令父命令参数冲突的问题。
<!--more-->

### ArgParse
通过 parents 可以共用一些公共参数，比如下面的 trigger_parser 就可以使用 parent_parser 的参数
子命令中设置了 `add_help=False`，主要是为了解决子命令和父命令的 -h 参数冲突
公共参数设置了 `required=False`，主要是为了解决子命令一定需要父命令的参数

```python
parent_parser = argparse.ArgumentParser()
# 公共参数
parent_parser.add_argument("-u", "--url", dest="url", help="sa url")
parent_parser.add_argument("-p", "--project", dest="project", help=" project name")
parent_parser.add_argument("-t", "--token", dest="token", help="token，API secret")
# 子命令
sub_parser = parent_parser.add_subparsers(dest="subparsers_name")
# trigger
trigger_parser = sub_parser.add_parser("trigger", help="trigger tag calculate", parents=[parent_parser],
                                       add_help=False)
trigger_parser.add_argument("-d", "--etl_date", dest="etl_date", help="source data etl_date", required=True)
trigger_parser.add_argument("-e", "--event", dest="event", help="the tag that relation events", required=True)
# delete
delete_parser = sub_parser.add_parser("delete", help="delete tag", parents=[parent_parser], add_help=False)
delete_parser.add_argument("-fd", "--from_date", dest="from_date", help="delete start date", required=True)
delete_parser.add_argument("-td", "--to_date", dest="to_date", help="delete end date", required=True)
delete_parser.add_argument("-i", "--tag_id", dest="tag_id", help="delete tag id", required=False)
delete_parser.add_argument("-f", "--tag_config", dest="tag_config", help="delete tag id file", required=False)

args = parent_parser.parse_args()
```

关于使用，可以直接执行 `python3 xx.py -h`，`python3 xx.py trigger -h`查看。
如果觉得每次使用 python3 太麻烦，也可以重命名命令，就像下面这样，以后只需要 `etladmin -h `就好了
```sh
alias etladmin="python3 xx.py"
```
最好的办法是使用 pyinstaller 打包成 unix可执行程序。在 dist 目录下可以找到打包的文件
```sh
pip3 install pyinstaller
pyinstaller --version
pyinstaller -w -F -p . xx.py # -F 指定生成可执行文件，-w 去除黑框 -p . 指定程序的入口搜索路径，否则只能在生成目录下执行程序。
```

