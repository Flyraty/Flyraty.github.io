---
title: MarkDown 文档常用的语法
tags: MarkDown
categories: 工具
abbrlink: 4092064b
date: 2020-05-14 17:24:11
---
### 背景
在使用 MarkDown 语法书写文档的过程中，经常遇到一些场景不会表达，每次都去搜索，太浪费时间。遂记录下来放在本篇文档中。不定期更新
<!--more-->
### 文字加粗
使用 **(加粗文字)**，就像这样，你的名字

### 表格中代码换行
表格中书写代码示例的时候，由于没有换行，代码较短还可以，但是太长的话基本上就不知所云了。就像下面这样，虽然用 ; 做了分隔，但是看起来还是比较别扭。

|算子|	示例|
|------|------|
|map	|case class Sentence(id: Long, text: String);val sentences = Seq(Sentence(0, "hello world"), Sentence(1, "witaj swiecie")).toDS;sentences.map(s => s.text.length > 12).show()|

这个时候可以采用 <br> 标签

|算子|	示例|
|------|-----|
|map	|`case class Sentence(id: Long, text: String)`<br>`val sentences = Seq(Sentence(0, "hello world"), Sentence(1, "witaj swiecie")).toDS`<br>`sentences.map(s => s.text.length > 12).show()`<br> |

### 代码段折叠
使用 `<details><summary></summary></details>` 实现。比如下面这样，`<summary>` 标签代表折叠代码块的摘要。 `<summary>` 标签下面的内容代表你要折叠的文本块或者代码块。
```xml
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
```
最终实现的效果是这样子的

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

### 控制图片大小
通过 `<img>` 标签
```xml
<img src="https://spark.apache.org/docs/3.0.0-preview/img/AllJobsPageDetail1.png" width="10%" height="10%">
<img src="https://spark.apache.org/docs/3.0.0-preview/img/AllJobsPageDetail1.png" width="30%" height="30%">
```
可以比对下效果，第一张图片是第一个 img 标签
<img src="https://spark.apache.org/docs/3.0.0-preview/img/AllJobsPageDetail1.png" width="10%" height="10%">

<img src="https://spark.apache.org/docs/3.0.0-preview/img/AllJobsPageDetail1.png" width="30%" height="30%">

### 任务列表
```
- [] 已完成
- [x] 未完成
```
上述代码实现的效果如下，加 x 代表已经完成

- [] 已完成
- [x] 未完成

