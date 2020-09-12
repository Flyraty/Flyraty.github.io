---
title: Row && Column - Compose "Tabular Data Set"
tags: Spark
categories: BigData
abbrlink: 5d48686a
date: 2020-03-23 14:18:01
---
## 前言
Dataset ，DataFrame 在我们眼中的直观的呈现形式就是一张表格。那么我们该如何处理一张表格的行列呢？Spark SQL 中的 Row， Column 类型将为我们解答这个问题。
<!--more-->

## Row
Row 可以被看作集合 collection，只是带有可选的 schema （当对 Dataset 使用 toDF 或者 DataFrameReader 读取数据源时，schema 会通过 RowEncoder 分配给 Row）。所以 Row 具有集合的特性，我们可以通过索引来获取集合中的字段。下面是 Row 的一些方法示例

```scala
scala> import org.apache.spark.sql.Row
import org.apache.spark.sql.Row

scala> val row = Row(1, "hello")
row: org.apache.spark.sql.Row = [1,hello]

scala> row(1)
res13: Any = hello

scala> row.get(1)
res8: Any = hello

scala> row.schema
res9: org.apache.spark.sql.types.StructType = null

scala> Row.empty
res14: org.apache.spark.sql.Row = []

scala> Row.fromSeq(Seq(1, "hello"))
res15: org.apache.spark.sql.Row = [1,hello]

scala> Row.fromTuple((0, "hello"))
res16: org.apache.spark.sql.Row = [0,hello]

scala> Row.merge(Row(1), Row("hello"))
res17: org.apache.spark.sql.Row = [1,hello]
```
row 通过索引获取的是 Any 类型。可以通过 getAs 方法指定类型
```scala
row.getAS[Int](0)
```
## Column
通过 Column 来操作数据集中的每列数据。在讲 SparkSession 的时候我们有提到过 implicits object。其中有 stringtocolumn 的隐式转换方法。因此我们可以直接通过 $ 来创建一个column。这也是我们在 Spark SQL 程序中经常操作列的写法。Spark SQL 内置的 col 函数也是转换 Column 的。
```scala
scala> $"name"
res17: org.apache.spark.sql.ColumnName = name

scala> import org.apache.spark.sql.functions._
import org.apache.spark.sql.functions._

scala> col("name")
res18: org.apache.spark.sql.Column = name
```
$ 符的使用有时候还是有限制的，比如我们字段中存在 $。这时候 `$"$ip"`，`selectExpr("$ip")`  就会出现问题。这时候可能就需要 `col` 来操作列。

下面介绍一下与 Column 相关的一些常见方法 （日常使用中，我们往往需要 UDF 和 transform。Columns 和 filter 经常会结合使用用来过滤数据集）。

|method	|description	|example|
|-------|---------------|-------|
|as	|指定该列的类型	|`$"id".as[Int]`|
|cast	|指定该列的类型|	`$"id".cast("string")`|
|alias	|重命名该列	|`$"id".alias("ID")`|
|withColumn	|增加一列	|<br>``spark</br><br>`.range(5)`</br><br>`withColumn("id_"，$"id" - 1)`</br>|
|like	|类似于 SQL 中的 like|	`df("id") like 0`|
|over	|和 Window 结合使用，Window agg 后面会讲解到	| <br>`val window: WindowSpec =  ......`</br> <br>`$"id" over window`</br> |
|isin	|isin	|`$"id" is in (channel: _*)`|
|isInCollections	|是否该列值在指定集合中	|
|asc /  desc	| |`spark.range(5).sort($"id".desc).show()`|
