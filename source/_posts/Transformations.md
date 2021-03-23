---
title: "Transformations - Transform Your Dataset"
tags: Spark
categories: BigData
abbrlink: e0f17242
date: 2020-03-23 14:19:00
---

### 前言
由前面提到的 Spark 计算模型，我们可以知道 Spark 的数据计算在本质上是 RDD 的迭代转换。本文要讲的就是涉及到转换操作的转换算子 transformations 。通过这些转换算子，你就可以完成定义在数据集上的各种计算了，就和 SQL 一样。
<!--more-->

### Typed Transformations
这里的 Typed 是指什么呢，可以理解为强类型，即 transform  xxx to typed。这类转换算子返回 Dataset[T]，KeyValueGroupDataset。到底 Typed Transformations 和 UnTyped Transformations 有啥区别，我也有点迷糊，这里需要去读下源码。以看下下面的对 Typed Transformations 的解释。
```
Typed transformations are part of the Dataset API for transforming a Dataset with an Encoder (except the RowEncoder).
```
这里介绍一些常见的 Typed Transformations。你会发现这个普通的 SQL 书写并没有什么区别。只是 Spark 为你提供了更简洁的 API，并且做了一些内部优化。

|Method	|Description	|Example|
|-------|------------|-------|
|alias	|重命名列	 | `$"id".alias("ID")`|
|as	| 强转类型| `spark.range(5).as[String]`|
|coalesce	|hint，重分区，shuffle = false	|`spark.range(10000).coalesce(2).explain(true)`|
|repartition	|hint，重分区，shuffle = true	| `spark.range(10000).repartition(1).explain(true)` |
|distinct	|整体去重	 | `val ds = Seq(1, 2, 3, 2, 5).toDS.distinct()`|
|dropDuplicates	|按照一列或者多列去重	|`val ds = Seq(1, 2, 3, 2, 5).toDS.dropDuplicates("id")`|
|except	|差集	| <br>`val ds1 = Seq(1, 2, 3, 2, 5).toDS`</br><br>`val ds2  = Seq(1, 2, 6, 7, 8).toDS`</br><br>`ds1.except(ds2).show()`</br>|
|intersect	|交集 	`ds1.intersect(ds2).show()`|
|union	|并集	|`ds1.union(ds2).show()`|
|unionByname	|并集，比较严格，遇到列名重复，以及列缺少会报错| |	
|filter	|过滤	|`ds1.filter($"value" === 2)`|
|where	|过滤，看源码其实就是 filter	|`ds1.where($"value" === 2)`|
|map	|转换每行的内容|<br>`case class Sentence(id: Long, text: String)`</br><br>`val sentences = Seq(Sentence(0, "hello world"), Sentence(1, "witaj swiecie")).toDS`</br><br>`val sentences = Seq(Sentence(0, "hello world"), Sentence(1, "witaj swiecie")).toDS`</br><br>`sentences.map(s => s.text.length > 12).show()`</br>|	
|mapPartitions	|map对每个元素做操作，mapPartitions 针对每个分区，对分区里的元素做操作 |`sentences.mapPartitions(it => it.map(s => s.text.length > 12)).show()`|
|flatmap	|map + 打平嵌套元素|	sentences.flatMap(s => s.text.split("\\s+")).show()|
|limit	| | `sentences.limit(1)`|
|groupByKey	|比 groupBy 更加灵活，灵活在可以自由组合列？返回 KeyValueGroupDataset。但是后面可支持的聚合函数可能比较少	| <br>`ds.groupBy("id")`</br><br>`ds.groupByKey(row => {row.getString(0)})`</br> |
|select	|SQL 中的 select	||
|sort	|排序	||
|transform	|高阶函数，可把多个操作链接起来。后面会拿出来单独拿出来讲|<br>def transformInt(columns: Seq[String])(df: DataFrame) = {</br><br>  var dfi = df</br> <br>  for (column <- columns) {</br><br>    dfi = dfi.withColumn(column, col(s"$column").cast("int"))</br><br>  }</br><br>  dfi</br><br>}</br><br>df.transform(transformInt(Seq("id", "revenue")))</br>|

### UnTyped Transformations
弱类型的转换算子把 Dataset 转换为一些弱类型的数据结构，比如 DataFrame，RelationalGroupedDataset等，即 transform xxx to untyped。
```
Untyped transformations are part of the Dataset API for transforming a Dataset to a DataFrame, a Column, a RelationalGroupedDataset, a DataFrameNaFunctions or a DataFrameStatFunctions (and hence untyped).
```
这里介绍常见的 UnTyped Transformations，emnn，其实就是常见的 SQL Operator

|Method	|Description |	Example|
|------|-----------|--------|
|agg	|聚合函数	| <br>`val ds = xxx`</br><br>`ds.groupBy("name").agg(sum("score"), min("id"))`</br>|
|grouoBy|	分组|`ds.groupBy("name").count()`|
|cube|	多维分析	| |
|drop|	删除某列	| |
|join|	连接查询，SQL 中的 join| |	
|na|	DataFramnNaFunctions，常用于替换空值	| `spark.range(5).na` |
|rollup	|多维分析，分析的维度组合生成不一样	 | |
|select|	SQL 中的 select，和 Typed Transformations 的 select 接收的参数类型不一样，一个是  TypedColumn	| |
|selectExpr	|接收 Expression 类型	 | |
|withColumn|	根据其他类添加一列或者修改本列，当你有很多 withColumn 时，你可以选择使用 transform 来将很多操作 chain 起来	 |<br>`spark.range(5).withColumn("idPlus", $"id" + 1)`</br><br>`spark.range(5).withColumn("id", $"id" + 1)`</br>
|withColumnRenamed	|重命名列，alias也是不错的选择	| `spark.range(5).withColumnRenamed("id", "ID")`|

na 可以用来做填充替换。比入我们读取的 csv 文件中，有的列既有有值的，又有空字符串，还有为空的，或者其他乱七八遭的数据，为了方便后续的统计计算，我们肯定要替换成统一值代表一个统一的含义。

tip：spark na.fill 当接收 Map 作为参数时，Map 的 value 类型只能为 Int, Long, Float, Double, String, Boolean.

```scala
val cols = Seq("distinct_id", "time", "$ip", "$browser", "$url", "$referrer")
spark.read.csv(input_path).na.replace(cols, Map("-" -> ""))

spark.read.csv(input_path).na.fill(-1)
```



