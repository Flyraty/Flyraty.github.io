---
title: SparkSession - The Entry Point to Spark SQL
date: 2020-03-21 14:17:08
tags: Spark
---

## 前言
根据 Spark 的架构，我们知道 driver 端通过 SparkContext 实例来控制程序的运行。在 Spark 2.X 里，提供了 SparkContext 的上层 SparkSession，两者之间可以互相转化。可以说，我们开发 Spark SQL 应用程序首先就要创建 SparkSession。
<!--more-->

## SparkSession
我们通过 SparkSession.Builder 来创建 SparkSession 实例。一旦 SparkSession 被创建，我们就可以使用  SparkSession 来创建 DataSet 来进行后续数据的计算。

```scala
import org.apcahe.spark.sql.SparkSession

val spark = SparkSession
	.builder()
	.appName("My First Processor")
    .master("local[*]")
	.enableHiveSupport() 
	.config("spark.sql.warehouse.dir", "target/spark-warehouse")
	.withExtensions { extensions =>
    extensions.injectResolutionRule { session =>
      ...
    }
  }
  .getOrCreate

import spark.implicits._

val df = Seq(("Mike", 11,), ("Jam", 23)).toDF("name", "age")

df.show()
```
通过 SparkSession，我们可以调用其 creatDataFrame 等函数，DataFrameReader API 等加载任意数据源，后面会有单独的章节讲 DataFrameReader。

tip：SparkSession.builder.withExtensions 可以用于新增自定义规则，像 OptimizerRule，ParseRule。 场景：数据查询平台中枢每天接受大量的 Sql 请求，可以通过自定义 Check 规则来过滤掉每个 session 提交的不合理请求。

spark-shell 会自动为我们创建变量名为 spark 的 SparkSession 对象。供我们调用各种 API 进行调试与学习。并且自动引入了隐式转换。现在打开 spark-shell，输入以下代码试一下
```scala
spark.range(5).show()
val a = Seq(("Mike", 11,), ("Jam", 23)).toDF("name", "age")
```
spark-shell 默认 enableHiveSupport() ，使用 hive metastore 进行元数据管理。可以通过以下命令使用内存进行元数据管理。涉及到的对象是 Spark.catalog。
```sh
spark-shell --conf spark.sql.catalogImplementation=in-memory
```
下面看下 SparkSession 常见的 API


|Method	|Description| example|
|------|-------|------|
|builder | 创建 SparkSession	| <br>`val spark = SparkSession`</br><br>`.builder.`</br><br>`.master("local[*]")`</br><br>`.getOrCreate`</br> |
|catalog |元数据管理	|spark.catalog |
|createDataFrame|通过 RDD 和 schema 创建 DF，重载方法，接受的参数都不一样	| <br>`import org.apache.spark.sql.types._`</br><br>`import org.apache.spark.sql.Row`</br><br>`val schema = new StructType().add($"id".int)`</br><br>`val rdd = spark.sparkContext.parallelize(Seq(Row(1), Row(2)))`</br><br>`val df = spark.createDataFrame(rdd, schema)`</br> |
|emptyDataFrame	 |空 DF	|`spark.emptyDataFrame.show()`|
|implicits	|引入隐式转换	| <br>`import spark.implicits._`</br><br>`$"id".toString`</br>|
|newSession	|新建一个 SparkSession| |
|read	创建 DataFrameReader	| `spark.read.json(input_path)` |
|range	创建 DataSet[java.lang.Long]	| `spark.range(5).show()` |
|sql	执行 sql 语句|	`spark.sql("show tables")` |
|stop	停止关联的 SparkContext|	`spark.stop()` |

## Builder API
Builder API 用来创建 SparkSession。这里介绍经常用到的方法。

|Method	|Description|
|-------|-----------|
|appName|	应用程序的名称|
|config	|设置配置项，可以设置 core 个数等|
|enableHiveSupport	|使用 hive metastore 作为 catalog|
|master|	spark master，比如 local[*]，YARN|
|getOrCreate|	获取一个SparkSession 示例，如果获取不到就创建|
|withExtensions	|自定义规则拓展|

## Implicits Object
隐式对象提供了将 scala 对象，比如 Seq，String，转换成 DataSet，DataFrame，Coulmn 等 spark 数据结构的方法。简而言之，就是为我们提供便捷。

|Method	|Description|
|-------|-----------|
|localSeqToDatasetHolder|	scala 的 `Seq[T]  => DataSet[T]`|
|Encoders：Spark SQL 用来序列化/反序列化的一个类。主要用于 DataSet。本质上每次调用toDS() 函数的时候都调用了 Encoder|
|StringToColumn| `$"name" => Column`，这也是我们经常看到 Spark 代码里操作列的写法。在后面的 Column 章节会详细讲到|
|rddToDatasetHolder|	`rdd => dataset`|
|symbolToColumn	|`symbol => Column`|


implicits object 定义在 SparkSession Object 里面，所以创建 SparkSession 后才可以引用。像下面的这些方法都是通过隐式转换实现的

```scala
case class => Dataset[T]

import org.apache.spark.sql.SparkSession

val spark = SparkSession.builder.master("local[*]").getOrCreate

import spark.implicits._

val df1 = Seq("implicits").toDS

val df2 = Seq("implicits").toDF

val df3 = Seq("implicits").toDF("text")

$"name".toString

val rdd = spark.sparkContext..parallelize(Seq(Row(1), Row(2)))

rdd.toDS

case class People(name:String, age:Int)

val people = Seq(People("Mike", 21), People("Jam", 20)).toDS

```