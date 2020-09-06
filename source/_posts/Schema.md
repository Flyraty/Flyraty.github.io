---
title: Schema - Describe Structure of Data
date: 2020-03-23 14:18:45
tags: Spark
---
### 前言
Schema 描述并规范数据的结构组成。在 Spark SQL 中，你所处理的每个 df， ds 都有自己的 schema。
<!--more-->

### Schema
Schema 可以是隐式的（在执行过程中推断出 schema），也可以是显式的（指定 schema 并在编译期检查）。Schema 用 StructType 和 StructField 声明。你可以使用 printTreeString 或者 prettyJson 来输出更美观的 schema。
```scala
scala> import org.apache.spark.sql.types._

scala> val schemaUntyped = new StructType().add("a", "int")
schemaUntyped: org.apache.spark.sql.types.StructType = StructType(StructField(a,IntegerType,true))

scala> schemaUntyped.printTreeString
root
 |-- a: integer (nullable = true)
Spark 2.x 中，使用 Encoder 来解析描述 Dataset 的 schema

scala> import org.apache.spark.sql.Encoders

scala> Encoders.INT.schema.printTreeString
root
 |-- value: integer (nullable = true)

scala> Encoders.product[(String, java.sql.Timestamp)].schema.printTreeString
root
|-- _1: string (nullable = true)
|-- _2: timestamp (nullable = true)

case class Person(id: Long, name: String)
scala> Encoders.product[Person].schema.printTreeString
root
 |-- id: long (nullable = false)
 |-- name: string (nullable = true)
```

上面提到每个 df 和 ds 都有自己的 schema，不管是隐式还是显式的。可以使用 printSchema 来得到。printSchema 在我们调试处理一些比较复杂的数据结构时非常有用。
```scala
scala> val df = Seq((1, 2), (3, 4)).toDF("id", "num")
df: org.apache.spark.sql.DataFrame = [id: int, num: int]

scala> df.printSchema
root
 |-- id: integer (nullable = false)
 |-- num: integer (nullable = false)

scala> df.schema
res5: org.apache.spark.sql.types.StructType = StructType(StructField(id,IntegerType,false), StructField(num,IntegerType,false))

scala> df.schema("id").dataType
res6: org.apache.spark.sql.types.DataType = IntegerType
```
### StructType

StructType 是用来定义声明 schema 的数据类型。可看作是 StructField 的集合，与 DDL 数据库定义语言可以互相转换。
``` scala
scala> df.schema foreach println
StructField(id,IntegerType,false)
StructField(num,IntegerType,false)

scala> df.schema.toDDL
res9: String = `id` INT,`num` INT

scala> df.schema.sql
res10: String = STRUCT<`id`: INT, `num`: INT>
```
我们可以通过 schema 的 add 方法来创建一层或者多层嵌套的 schema。在日常工作中，处理一些无表头类 csv 格式文件时，我们可以通过 map 快速生成统一类型的 schema。如果你要硬指定类型的话，需要确保数据质量足够好，同一字段不会存在类型不一致的现象，否则根据 schema 读取出来的数据会出现大量 Null。

```scala
val cols = Seq("session_id", "original_id", "time", "timestamp", "$ip", "computer_id", "distinct_id", "click", "value", "$url")

val inferSchema = StructType(cols.map(StructField(_, StringType)))
```
### StructField
StructField 用来描述每列的类型，一般由列名，数据类型，nullable，comment（默认为空） 组成。同样与 DDL 数据库定义语言可以互相转换
```scala
scala> df.schema("id")
res11: org.apache.spark.sql.types.StructField = StructField(id,IntegerType,false)

scala> df.schema("id").getComment
res12: Option[String] = None

scala> import org.apache.spark.sql.types.MetadataBuilder
import org.apache.spark.sql.types.MetadataBuilder

scala> val metadata = new MetadataBuilder().putString("comment", "id").build
metadata: org.apache.spark.sql.types.Metadata = {"comment":"id"}

scala> import org.apache.spark.sql.types.{LongType, StructField}
import org.apache.spark.sql.types.{LongType, StructField}

scala> val f = new StructField(name = "id", dataType = LongType, nullable = false, metadata)
f: org.apache.spark.sql.types.StructField = StructField(id,LongType,false)

scala> f.toDDL
res13: String = `id` BIGINT COMMENT 'id'
```

