---
title: Dataset - Structured Query with Data Encoder
date: 2020-03-23 14:17:37
tags: Spark
---

## 前言
Dataset 是 Spark SQL 中的一种强类型数据结构。用于抽象结构化查询。在 Spark 2.x 中，我们常常会用到 Dataset  API 来表达我们对数据集的操作。
<!--more-->
## Dataset 
我们知道 Dataset 代表的是数据集，那么 Dataset 的数据结构构成就是数据集合吗？下面这张图为我们展现了是什么构成了 Dataset。Dataset 到底是什么？
![](https://tva1.sinaimg.cn/large/00831rSTly1gd41bh53dpj30dp0b7aak.jpg)
Dataset 包含以下三种元素（这在我们程序 debug 的时候也可以看到）

QuerExecution （解析未分析的 LogicalPlan 逻辑计划）
Encoder （解析每行数据，序列化或者反序列化对应数据。eg：DataFrame 用的是 RowEncoder。）
SparkSession
Dataset 是惰性计算的，只有遇到 action 算子在才会真正的触发计算。相比 DataFrame，Dataset 提供了声明式和类型安全的操作符。更通俗点来说，Dataset 是强类型的，而 DataFrame 是弱类型的。

Dataset 是强类型 typedrel 的，会在编译的时候进行类型检测；而 DataFrame 是弱类型 untypedrel 的，在执行的时候进行类型检测。
Dataset 是通过 Encoder 进行序列化，支持动态的生成代码，直接在 bytes 的层面进行排序，过滤等的操作。而 DataFrame 是采用可选的 java 的标准序列化或是 kyro 进行序列化。
Dataset 在 Spark 1.6的 feature 中被引入。到了Spark 2.x 中，对 Dataset 和 DataFrame 做了统一。type DataFrame = Dataset[Row]
我们可以对比一下 Dataset 和 DataFrame 的执行计划，可以看到 DataFrame 在分析执行计划时并没有提供类型检查。而 Dataset 却可以做到，这些都是由 scala 编译器自动完成的。这也是 Dataset 更吸引人的地方。

```scala
scala> spark.range(1).toDF.filter(_ == 0).explain(true)

== Parsed Logical Plan ==
'TypedFilter <function1>, interface org.apache.spark.sql.Row, [StructField(id,LongType,false)], unresolveddeserializer(createexternalrow(getcolumnbyordinal(0, LongType), StructField(id,LongType,false)))
+- Range (0, 1, step=1, splits=Some(4))

== Analyzed Logical Plan ==
id: bigint
TypedFilter <function1>, interface org.apache.spark.sql.Row, [StructField(id,LongType,false)], createexternalrow(id#23L, StructField(id,LongType,false))
+- Range (0, 1, step=1, splits=Some(4))

== Optimized Logical Plan ==
TypedFilter <function1>, interface org.apache.spark.sql.Row, [StructField(id,LongType,false)], createexternalrow(id#23L, StructField(id,LongType,false))
+- Range (0, 1, step=1, splits=Some(4))

== Physical Plan ==
*(1) Filter <function1>.apply
+- *(1) Range (0, 1, step=1, splits=4)

scala> spark.range(1).filter(_ == 0).explain(true)

== Parsed Logical Plan ==
'TypedFilter <function1>, class java.lang.Long, [StructField(value,LongType,true)], unresolveddeserializer(staticinvoke(class java.lang.Long, ObjectType(class java.lang.Long), valueOf, upcast(getcolumnbyordinal(0, LongType), LongType, - root class: "java.lang.Long"), true, false))
+- Range (0, 1, step=1, splits=Some(4))

== Analyzed Logical Plan ==
id: bigint
TypedFilter <function1>, class java.lang.Long, [StructField(value,LongType,true)], staticinvoke(class java.lang.Long, ObjectType(class java.lang.Long), valueOf, cast(id#27L as bigint), true, false)
+- Range (0, 1, step=1, splits=Some(4))

== Optimized Logical Plan ==
TypedFilter <function1>, class java.lang.Long, [StructField(value,LongType,true)], staticinvoke(class java.lang.Long, ObjectType(class java.lang.Long), valueOf, id#27L, true, false)
+- Range (0, 1, step=1, splits=Some(4))

== Physical Plan ==
*(1) Filter <function1>.apply
+- *(1) Range (0, 1, step=1, splits=4)
```
Dataset 是可查询的，可序列化的，并且可以作持久化存储。

SparkSession 和 QueryExecution 作为 Dataset 的临时属性不会被序列化。但是 Encoder 会被序列化，反序列化的时候还需要 Encoder 来解析。
Dataset 默认的存储级别是 MEMORY_AND_DISK。这里后面的 cache && persist 会讲到。
Spark 2.X 提供了 Structured Streaming。其还是使用 Dataset 来做为底层的数据结构来进行静态有界数据流和无界数据流的计算。通过 Dataset 提供的统一 API。我们可以更关注不同编程模型的计算逻辑。

## DataFrame
在 Dataset 小节里面也简单提到了 DataFrame 是什么以及和 Dataset 的区别。这里单独拿出来讲下如何创建 DataFrame 以及 DataFrame 的一些简单操作。因为工作中很多情况下都是从文件或者数据库中读取（DataFrameReader 在读取时会调用 ofRows 生成 DataFrame）。

DataFrame 可以被看作是由 row 和 named columns 组成的分布式表格数据集。就跟关系型数据中的一张数据表一样，我们可以对其进行 select，filter，join，group 等操作。其具有 RDD 的一切特性，比如，弹性，并行，分布式，只读。

下面是一个简单的 word count 程序

```scala

scala> val df = Seq(("one", 1), ("one", 1), ("two", 1)).toDF("word", "count")

scala> df.groupBy("word").count().show()
+----+-----+
|word|count|
+----+-----+
| two|    1|
| one|    2|
+----+-----+
```
从 Scala 序列或者 case class 或者 createDataFrame 创建 DataFrame

```scala
val df = Seq((1, 2), (3, 4)).toDF("id", "id+")
case class People(name:String, age:Int)
val people = Seq(People("zz", 1))
val df1 = spark.createDataFrame(people)
val df2 = people.toDF 
```
通过 DataFrameReader 创建 DataFrame，经常用到的方法，支持多种数据源的读取，json，csv，parquet，text，JDBC，Kafka等等。在后面的 DataSource API 中会详细讲。

```scala
scala> val reader = spark.read
reader: org.apache.spark.sql.DataFrameReader = org.apache.spark.sql.DataFrameReader@2125bb4e

scala> reader.json("file.json")

scala> reader.csv("file.csv")

scala> reader.parquet("file.parquet")
```


DataFrame query，你可以像使用数据表一样，通过 SQL 和 Dataset API 来对 DataFrame 进行查询计算。
```scala
improt org.apache.spark.sql.functions._

val columns  = Seq("name", "age", "grade")

val a = df.select(colums.map(col(_)): _*) // select 接受 Column 类型，所以需要做转换

val b = df.selectExpr(columns: _*)  // selectExpr 接受 Expression 类型

a.filter($"name".equalTo("Time Machine"))

a.groupBy("age").count()

a.withColumn("GradeString", $"grade".toString)

val table = a.registerTempTable("people") (1)

val sql = spark.sql("SELECT count(*) AS count FROM people")
```



