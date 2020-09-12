---
title: 常见的Linux数据处理命令
tags: Linux
categories: Linux
abbrlink: 265c42ae
date: 2020-05-07 14:22:05
---

### 背景
读到了一篇文章讲的如何用 linux 命令来实现一些常见的数据处理操作，如排序，去重，聚合等，感觉非常不错。正好最近工作也用到了这些，遂翻译过来，顺便实践一下。原文地址 [An Introduction To Data Science On The Linux Command Line](https://blog.robertelder.org/data-science-linux-command-line/)
<!--more-->

### The '|' Symbol
许多读者可能已经非常熟悉 | 符号，但是有的或许并不明白其中的含义。在这里需要提前说明一下：在下面几个章节中许多命令的输入和输出都是通过 | 管道来连接的，这意味着我们可以链接很多有用的命令来组合成有用的程序，而这些程序可以直接运行在命令行上。

### grep
**what's grep？**grep 是一个用于提取文件中指定匹配文本的工具。我们可以通过很多不同的标志或者选项来选择从文件或者流中匹配指定的文本。grep 通常是一个面向行的工具，这意味着当它匹配到指定文本，包含匹配文本的整行数据就会被输出出来。当然你可以使用 -o 选项只输出匹配到的文本。

**why is grep useful？**grep 非常有用是因为这是一个比较快的从大量文本总找出匹配文本的方法。一些比较常见的例子有：过滤 web 日志文件查看指定网页的访问量；在你的代码包中搜索指定的关键词（grep 往往比编辑器搜索的更快更可靠）；在 Unix 的管道中间过滤前一个命令的输出。

**How does grep relate to data science？** grep 对特定的数据科学任务非常有用，因为它可以很快的从数据集中匹配得到你想要的信息。很有可能你的数据集中存在很多无关的信息，你想要的数据分布在文本的各个行中。如果你能想到一个完美的规则来过滤它们，那么 grep 非常有用。比如，你现在有一个记录销售信息的 csv 文件

<details>
	<summary>sales.csv</summary>
	tem, modelnumber, price, tax <br>
	Sneakers, MN009, 49.99, 1.11<br>
	Sneakers, MTG09, 139.99, 4.11<br>
	Shirt, MN089, 8.99, 1.44<br>
	Pants, N09, 39.99, 1.11<br>
	Sneakers, KN09, 49.99, 1.11<br>
	Shoes, BN009, 449.22, 4.31<br>
	Sneakers, dN099, 9.99, 1.22<br>
	Bananas, GG009, 4.99, 1.11<br>
</details>
你可以使用这样的一个命令
```sh
grep Sneakers sales.csv
```
这会过滤出包含 Sneakers 文本的销售记录，下面是执行这条命令的结果
<details>
	<summary>results.csv</summary>
	Sneakers, MN009, 49.99, 1.11<br>
	Sneakers, MTG09, 139.99, 4.11<br>
	Sneakers, KN09, 49.99, 1.11<br>
	Sneakers, dN099, 9.99, 1.22<br>
</details>

你也可以通过正则表达式来寻找符合特定模式的文本，比如下面的这条命令可以用来过滤以 BN 或者 MN 开头且跟着三个数字的 modelnumber
```sh
grep -o "\(BN\|MN\)\([0-9]\)\{3\}" sales.csv
```
### sed
**what's sed？**sed 用于搜索和替换文本。比如，你可以使用下面的命令将该目录下所有文件中的 dog 替换成 cat
```sh
sed -i 's/dog/cat/g' *
```
**why is sed useful？** sed 可以使用正则来表达复杂的匹配场景。sed 的正则替换同样支持反向引用，这使得我们可以匹配任意的模式并且只改变匹配文本中的一部分内容。比如下面的命令会从给定的所有文本中搜索到双引号字符文本行并且交换位置，不需要改动匹配行中的其他文本，同时还将 “ 替换成 ()。
```sh
echo 'The "quick brown" fox jumped over the "lazy red" dog.' | sed -E 's/"([^"]+)"([^"]+)"([^"]+)"/(\3)\2(\1)/'
```
下面是执行的结果
`The (lazy red) fox jumped over the (quck brown) dog.`

**How does sed relate to data science？**sed  可以用来转换数据格式，比如你需要计算销售额，但是很不幸，原数据的数值型数据加上了 ”，这时候你就可以使用 sed 去掉 “ 做最简单的格式转换
<details>
	<summary>sales.csv</summary>
	age,value<br>
	"33","5943"<br>
	"32","543"<br>
	"34","93"<br>
	"39","5943"<br>
	"36","9943"<br>
	"38","8943"<br>
</details>

```sh
cat sales.csv | sed -e 's/"//g'
```
如果你经常遇到以下场合，你需要将某个数据集传给你的程序去处理，但是文件中的某些字符无法被程序处理，这时候你就可以使用 sed 去格式化你的数据

### awk
**What is awk?**  awk 可以用作通用计算，有一些更高级的搜索和替换用法。

**Why is awk Useful?** awk 可以轻松的处理格式化的文本行，就像一些高级编程语言一样。当然像搜索替换我们用 sed 也可以实现，但是 awk 表现的更漂亮。awk 还可以处理行与行之间的操作，比如第一列加和。

**How does awk relate to data science？**现在我们有一个包含温度信息的文件，里面有华氏度和摄氏度，现在我们需要统一成摄氏度
<details>
	<summary>temps.csv</summary>
	temp,unit<br>
	26.1,C<br>
	78.1,F<br>
	23.1,C<br>
	25.7,C<br>
	76.3,F<br>
	77.3,F<br>
	24.2,C<br>
	79.3,F<br>
	27.9,C<br>
	75.1,F<br>
	25.9,C<br>
	79.0,F<br>
</details>
你可以用简单的 awk 实现

```sh
cat temps.txt | awk -F',' '{if($2=="F")print (($1-32)*5/9)",C";else print $1","$2}'
```
### sort
**What is sort?** 正如其名，sort 是用来排序的

**Why is sort Useful?** sort本身可能并没有意义，其常用作一些数据的预处理：你想找到销售额最多的销售人员？sort it ! 然后输出第一行。你想得到 top N，sort it ! 然后输出前 n 行。你想根据数值或者字典排序，这些 sort 都帮你实现了。让我们去感受下不同方式的 sort
<details>
	<summary>nums.txt</summary>
	0<br>
	1<br>
	1234<br>
	11<br>
	ZZZZ<br>
	1010<br>
	0123<br>
	hello world<br>
	abc123<br>
	Hello World<br>
	9<br>
	zzzz
</details>	
默认 sort 的结果，由下面可以看到，排序是按照字典序来的，所以下面的数值排序可能不符合你的期望。

```sh
cat foo.txt | sort
```

<details>
	<summary>results</summary>
	0<br>
	0123<br>
	1<br>
	1010<br>
	11<br>
	1234<br>
	9<br>
	abc123<br>
	Hello World<br>
	hello world<br>
	ZZZZ<br>
	zzzz<br>
</details>
如果你想使用数值排序，加上 -n 选项就好了

```sh
cat foo.txt | sort -n
```

<details>
	<summary>results</summary>
	0<br>
	abc123<br>
	Hello World<br>
	hello world<br>
	ZZZZ<br>
	zzzz<br>
	1<br>
	9<br>
	11<br>
	0123<br>
	1010<br>
	1234<br>
</details>
倒序排序，可以使用 -r 

```sh
cat foo.txt | sort -r
```
<details>
	<summary>results</summary>
	zzzz<br>
	ZZZZ<br>
	hello world<br>
	Hello World<br>
	abc123<br>
	9<br>
	1234<br>
	11<br>
	1010<br>
	1<br>
	0123<br>
	0<br>
</details>

**How does sort relate to data science？**像下面提到的 comm，uniq 就需要接收 sort 排序后的输入。sort -R 还允许我们随机排列输入，这对于生成测试用例测试程序非常有帮助。

### comm
**What is comm?** comm 可以用来计算文件间的差集，并集，补集。

**Why is comm Useful? **comm 可以使我们很容易了解到 2 个文件的不同与相同之处。

**How does comm relate to data science？**一个很好的例子就是你现在有 2 个邮箱列表，一个记录了登录的邮箱，signup.txt。一个记录了产生购买行为的邮箱列表，purchase.txt。
<details>
	<summary>signup.txt</summary>
	8_so_late@hotmail.com<br>
	fred@example.com<br>
	info@info.info<br>
	something@somewhere.com<br>
	ted@example.net<br>
</details>

<details>
	<summary>purchase.txt</summary>
	example@gmail.com<br>
	fred@example.com<br>
	mark@facebook.com<br>
	something@somewhere.com<br>
</details>

我们现在有3个问题，1）登录并购买的用户有哪些？2）登录没有购买的用户有哪些？3）没有登录就购买的用户有哪些？comm 可以非常容易的解决这些问题，比如下面的命令就可以看到登录并购买的用户
```sh
comm -12 signups.txt purchases.txt
```
需要注意的是 comm 处理的文件必须是被排序过的

### uniq

**What is uniq?**uniq 会帮你解决唯一性的问题。

**Why is uniq Useful?** 如果你想删除重复数据，uniq 会帮助你。如果你想知道每条数据的重复次数，uniq 会告诉你。uniq 也可以帮你输出重复项，甚至完整性唯一性的检查。

**How does uniq relate to data science？**举个例子，现在你有一个销售数据文件 sales.csv 
<details>
	<summary>sales.csv</summary>
	Shoes,19.00<br>
	Shoes,28.00<br>
	Pants,77.00<br>
	Socks,12.00<br>
	Shirt,22.00<br>
	Socks,12.00<br>
	Socks,12.00<br>
	Boots,82.00<br>
</details>

现在你想知道我们到底销售了哪几样商品，你可以通过 awk 提取商品名称然后通过管道传递给 uniq 
```sh
cat sales.csv | awk -F',' '{print $1}' | sort | uniq
```
我们也可以得到每件商品的销售量
```sh
cat sales.csv | awk -F',' '{print $1}' | sort | uniq -c
```
下面是执行的结果
<details>
	<summary>results.csv</summary>
	1 Boots<br>
	1 Pants<br>
	1 Shirt<br>
	2 Shoes<br>
	3 Socks<br>
</details>	

### tr
**What is tr?** tr 可以用来删除替换一些文件中的字符，如 \n

**Why is  Ustreful? ** tr 比较有用的一个地方就是替换掉 windows 上产生的回车符等一些乱七八糟的符号。也可以做一些大小写转换。比如下面的例子将 test.txt 中的 a-z 字符集替换成 大写
```sh
cat test.txt | tr a-z A-Z
``` 

**How does tr relate to data science？**tr 命令并不像上面的命令与数据处理的联系很深，但是对于特殊情况的数据修复和处理还是非常有帮助的。

### cat
**What is cat?** cat 可以读取一个或者多个文件，并将内容输出到标准输出

**Why is cat Useful?** cat 对于合并多个文件非常有用，或者你想把文件输出

**How does cat relate to data science？**cat 在日常的数据处理中非常常见，最常见的例子是你想聚合几个格式相同的文件然后做数据处理。比如你想对目录下的 csv 文件进行聚合去重
```sh
cat *.csv | awk -F' ' '{print $1}' | sort | uniq
```
你可能经常看到用 cat 读取文件然后交给其他程序去处理
```sh
cat test.txt | somecommand
```
也许有人说 cat 并没有用，这是因为我们可以使用输入重定向
```sh
somecommand < file.txt
```
### head
**What is head?** head 允许你只输出一个文件的前几行数据

**Why is head Useful?** 你只想检查一个大文件的一部分内容，你只想计算前几行数据

**How does head relate to data science？**比如你有以下的商品销售文件 sales.csv
<details>
	<summary>sales.csv</summary>
	Shoes,19.00<br>
	Shoes,19.00<br>
	Pants,77.00<br>
	Pants,77.00<br>
	Shoes,19.00<br>
	Shoes,28.00<br>
	Pants,77.00<br>
	Boots,22.00<br>
	Socks,12.00<br>
	Socks,12.00<br>
	Socks,12.00<br>
	Shirt,22.00<br>
	Socks,12.00<br>
	Boots,82.00<br>
	Boots,82.00<br>
</details>

你想计算 top 3 最受欢迎的商品，可以使用如下命令
```sh
cat sales.csv | awk -F ',' 'print $1' | sort | uniq -c | sort -n -r | head -n 3
```
### tail
**What is tail?** tail 和head 是相反的，tail 输出文件末尾的内容

**Why is tail Useful? ** tail 和 head 的功能差不多

**How does tail relate to data science？** 你可以使用 tail 去计算上面 head的例子
```sh
cat sales.csv | awk -F',' '{print $1}' | sort | uniq -c | sort -n | tail -n 3
```
tail 还可以用来指定起始行，最常见的是 csv 的表头，如果我们只关注数据而不需要表头的话，那么可以使用 tail
```sh
cat sales.csv | tail -n +2 
```
### wc
**What is wc?** wc 用于单词或者行计数

**Why is wc Useful?**  wc 总是能很快解答你的文件有多少行，每行有多少个字符这样的问题。

**How does wc relate to data science？**比如你想快速知道你的邮件列表文件中有多少个邮件，wc 就可以做到
```sh
wc -l email.csv
```
wc 也可以用来对多个文件进行计数，这时候就可以和下面提到的 find 命令组合。下面这条命令会统计 data 目录下所有 json  文件的行数
```sh
wc -l `find /data -name *.json`
```
wc 用作字符计数，这里的 -n 是避免换行，换行会导致字符数 + 1
```sh
echo -n "Here is some text that you'll get a character count for" | wc -c
```
### find
**What is find?**  find 用于查找文件，并且可以对查找的文件进行一些处理

**Why is find Useful?** find 可以通过指定不同的选项（文件类型，文件大小，文件权限等）来查找文件，最有用的是 -exec 选项，它使得我们每找到一个文件，就可以立即对该文件进行操作。

**How does find relate to data science？**让我们用 find 来查找并替换文件中的内容，find 和 sed 的结合。
```sh
find . -type f -exec sed -i 's/dog/cat/g' {} \;
```
find 后面 . 的含义的是当前目录，find 会从当前目录递归查找所有符合条件的文件并做处理，我们也可以通过 find 来删除一些程序生成的临时文件，比如 spark 的 *crc 文件
```sh
find . -name '*.crc' -type f -exec rm -rf {} \;
```
### tsort
**What is tsort?** tsort 用来拓补排序，有点类似计算数据之间的血缘关系

**Why is tsort Useful?**  这里用一个简单的例子来描述 tsort，既然是计算血缘关系，那么也就是下一个任务的进行依赖于前一个任务的完成。现在我们就有一个这样的文件 'task_dependencies.txt'
<details>
	<summary>task_dependencies.txt</summary>
	wall_framing foundation<br>
	foundation excavation<br>
	excavation construction_permits<br>
	dry_wall electrical<br>
	electrical wall_framing<br>
	wall_painting crack_filling<br>
	crack_filling dry_wall<br>
</details>

上述文件描述了乱序的事物依赖关系，让我们用 tsort 来梳理一下
```sh
cat task_dependencies.txt | tsort
```
tsort 会遍历每一行内容，并假设前面的一个事物是后面的依赖，由此计算排序整体的依赖关系，下面是执行的结果
<details>
	<summary>results.txt</summary>
	wall_painting<br>
	crack_filling<br>
	dry_wall<br>
	electrical<br>
	wall_framing<br>
	foundation<br>
	excavation<br>
	construction_permits<br>
</details>	

**How does tsort relate to data science？**拓补排序是图论中常见的问题，应用于机器学习，任务调度，项目管理等等。像 Spark，Flink 对任务的调度就用到了拓补排序。

### tee
**What is tee?** tee命令同时向指定文件和标准输出打印信息流

**Why is tee Useful? **如果你想在运行程序的时候，既要记录日志文件，又想观察程序的输出，tee 命令可以帮助你
```sh
bash test.sh | tee test.log
```
**How does tee relate to data science？**tee 命令对数据分析可能并没有用处，但是对我们 debug 很有帮助，比如你有一个非常长的数据处理管道，但是并没有得到你想要的结果，到底是哪一步出了问题了，tee 这时候就可以帮助你
```sh
cat sales.csv | tail -n +2 | tee after_tail.log | awk -F',' '{print $1}' | tee after_awk.log | sort | tee after_sort.log | uniq -c | tee after_uniq.log
```
### The '>' Symbol
**What is the '>' Symbol?**输出重定向

**Why is the '>' Symbol Useful?** 输出重定向，输出重定向到文件，而不是在打印到屏幕上
```sh
cat sales.csv | tail -n +2 | awk -F',' '{print $1}' | sort | uniq -c > unique_counts.txt
```
### The '<' Symbol
**What is the '<' Symbol?** 输入重定向

**Why is the '<' Symbol Useful?** 指定程序的输入
```sh
grep Pants < sales.txt
```





