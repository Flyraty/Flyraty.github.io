---
title: Spark小知识点
categories: BigData
tags: Spark
abbrlink: e220000e
date: 2020-09-22 22:28:36
---

#### 前言
工作中碰到的一些 Spark 的问题
<!--more-->

#### spark load impala
采用 jdbc format，不过需要注意，ImpalaJDBC41.jar 的版本。在 Maven 中央仓库中的 ImpalaJDBC41 的依赖都是不管用的。因此需要自己去下载并放入 libs 目录 [下载地址](https://www.cloudera.com/downloads/connectors/impala/jdbc/2-6-4.html)。如果采用 sbt 打包管理的话，在 build.sbt 中加入以下内容用于标识本地依赖 jar 的路径。

```
unmanagedBase := baseDirectory.value / "libs"

```
连接 impala 代码示例，这里加了一些参数，`numPartitions,partitionColumn,lowerBound,upperBound` 用于调节 load 数据时的并发度。不加这些参数的时候。默认只有一个 task 在加载数据，大数据量的情况下相对较慢。建议 jdbc format 的数据源都调节一下这些参数，以达到一个理想的并发度。
```scala
spark.read
  .format("jdbc")
  .option("url", s"$impala_url")
  .option("driver", "com.cloudera.impala.jdbc41.Driver")
  .option("dbtable", "users")
  .option("numPartitions", 32)
  .option("partitionColumn", "id")
  .option("lowerBound", "1")
  .option("upperBound", "100000")
  .load()

```

#### spark 非等值 join 的执行计划
默认使用 BNLJ，及 BrocastNestLoopJoin，执行效率会非常低。如果查询条件比较少，此时可以想办法转换为等值连接来优化。
```scala
scala> array.join(b, array_contains($"id_array", $"id")).explain(true)
== Parsed Logical Plan ==
Join Inner, array_contains(id_array#7, id#19)
:- Project [id_string#5, split(id_string#5,  ) AS id_array#7]
:  +- Project [value#3 AS id_string#5]
:     +- LocalRelation [value#3]
+- Project [cast(id#0L as string) AS id#19]
   +- Range (0, 5, step=1, splits=Some(8))

== Analyzed Logical Plan ==
id_string: string, id_array: array<string>, id: string
Join Inner, array_contains(id_array#7, id#19)
:- Project [id_string#5, split(id_string#5,  ) AS id_array#7]
:  +- Project [value#3 AS id_string#5]
:     +- LocalRelation [value#3]
+- Project [cast(id#0L as string) AS id#19]
   +- Range (0, 5, step=1, splits=Some(8))

== Optimized Logical Plan ==
Join Inner, array_contains(id_array#7, id#19)
:- LocalRelation [id_string#5, id_array#7]
+- Project [cast(id#0L as string) AS id#19]
   +- Range (0, 5, step=1, splits=Some(8))

== Physical Plan ==
BroadcastNestedLoopJoin BuildLeft, Inner, array_contains(id_array#7, id#19)
:- BroadcastExchange IdentityBroadcastMode
:  +- LocalTableScan [id_string#5, id_array#7]
+- *(1) Project [cast(id#0L as string) AS id#19]
   +- *(1) Range (0, 5, step=1, splits=8)
```

#### Spark SQL 处理多层嵌套数据
写代码要以尽量简洁的形式表达出想要的意思，避免代码的冗余。如果要取多层嵌套数据中的某些字段做处理，比如像下面的的 schema，是大量的 getFiled 还是采用其他的办法呢。
```
root
 |-- ak: string (nullable = true)
 |-- pl: string (nullable = true)
 |-- usr: struct (nullable = true)
 |    |-- did: string (nullable = true)
 |-- ut: string (nullable = true)
 |-- ip: string (nullable = true)
 |-- st: long (nullable = true)
 |-- ua: string (nullable = true)
 |-- data: struct (nullable = true)
 |    |-- dt: string (nullable = true)
 |    |-- pr: struct (nullable = true)
 |    |    |-- $an: string (nullable = true)
 |    |    |-- $br: string (nullable = true)
 |    |    |-- $cn: string (nullable = true)
 |    |    |-- $cr: string (nullable = true)
 |    |    |-- $ct: long (nullable = true)
 |    |    |-- $cuid: string (nullable = true)
 |    |    |-- $dru: long (nullable = true)
 |    |    |-- $dv: string (nullable = true)
 |    |    |-- $eid: string (nullable = true)
 |    |    |-- $imei: string (nullable = true)
 |    |    |-- $jail: long (nullable = true)
 |    |    |-- $lang: string (nullable = true)
 |    |    |-- $mkr: string (nullable = true)
 |    |    |-- $mnet: string (nullable = true)
 |    |    |-- $net: string (nullable = true)
 |    |    |-- $os: string (nullable = true)
 |    |    |-- $ov: string (nullable = true)
 |    |    |-- $private: long (nullable = true)
 |    |    |-- $ps: string (nullable = true)
 |    |    |-- $rs: string (nullable = true)
 |    |    |-- $sc: long (nullable = true)
 |    |    |-- $sid: long (nullable = true)
 |    |    |-- $ss_name: string (nullable = true)
 |    |    |-- $tz: long (nullable = true)
 |    |    |-- $vn: string (nullable = true)
```
在字段具有相似特征的情况下可以用以下方法处理，得到所有列的集合在做后续处理。
```scala
import org.apache.spark.sql.functions._
 
val pr = $"data".getFiled("pr")
val prDF = testDataDF.select("data.pr.*")
val prColumns = prDF.columns.filter(_.startsWith("$"))
val custom_columns = prColumns.map(x => pr.getField(x).alias(x)).toSeq
```

#### Spark UDF WrappedArray
UDF 在接收 Array 作为参数的时候，类型其实是 WrappedArray。

#### Spark UDF 接受常量作为参数
使用 lit 或者 typedlit 包装一下，成为一个常量 Column 在处理。
```scala
val getScreen = udf((t: String, index: Int) =>
    t match {
      case t if !t.contains("*") => ""
      case t if t.split("\\*").length.equals(2) => t.split("\\*")(index)
      case _ => ""
    }
 
  )
getScreen($"Screen", lit(0))
```

#### Spark SQL lit 与 typedLit
typedLit 用于包装 scala 的数据结构类型，比如 Seq，Map 等。
lit 用于包装简单数据类型，比如 int，string 等。

#### cast 强转类型的坑
针对数据质量较差的数据做类型转换时，建议使用 UDF 。因为 cast 转换失败就为 null，容易丢数据。可以查看 `org.apache.spark.sql.catalyst.expressions.Cast.scala`

#### spark Ambiguous reference to fields StructField
spark 默认大小写不敏感，这就导致如果你的数据中存在 name 和 Name，就会认为是相同的列，从而抛出此错误，此时可以开启大小写敏感
```scala
val spark = SparkSession.builder()
    .master("local[*]")
    .appName("zhugeProcessor")
    .config("spark.sql.caseSensitive", true)
    .getOrCreate()
```


