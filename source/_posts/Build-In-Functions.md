---
title: Build In Functions
date: 2020-03-23 14:19:36
tags: Spark
---

### 前言
需要处理的数据结构往往是复杂的，在 Spark 中该如何操作 Map，Array，struct 这些结构呢？Spark 已经为我们提供了很多内置函数来处理这一切。这些函数大多定义在 org.apache.saprk.sql.functions。
<!--more-->

### 日期处理
#### 获取当前 date，timestamp
current_date，current_timestamp，包括下面说的处理函数可以直接在 sql 语句中使用，spark.sql("Your  SQL")
```scala
scala> spark.emptyDataFrame.withColumn("current_date", current_date).schema
res3: org.apache.spark.sql.types.StructType = StructType(StructField(current_date,DateType,false))

scala> spark.range(1).select(current_date).show()
+--------------+
|current_date()|
+--------------+
|    2020-03-17|
+--------------+


scala> spark.range(1).select(current_timestamp).show()
+--------------------+
| current_timestamp()|
+--------------------+
|2020-03-17 10:37:...|
+--------------------+


scala> spark.range(1).select(current_timestamp).show(false)
+-----------------------+
|current_timestamp()    |
+-----------------------+
|2020-03-17 10:39:53.896|
+-----------------------+
```

#### column 转换到 date，timestamp，时间戳
to_date，to_timestamp 接受 date，timestamp ，string 类型的参数。如果参数为 string，指定可选的 format，转换失败不会报错，会返回 null。默认的 format 是 yyyy-MM-dd HH:mm:ss。

unix_timestamp 返回当前时间戳或者根据指定字段生成时间戳，这个经常会用到。

from_unixtime 转换时间戳到 timestamp

```scala
scala> spark.range(1).select(current_date).withColumn("to_timestamp", to_timestamp($"current_date()", "yyyy-MM-dd HH:mm:ss")).show()
+--------------+-------------------+
|current_date()|       to_timestamp|
+--------------+-------------------+
|    2020-03-17|2020-03-17 00:00:00|
+--------------+-------------------+

scala> spark.range(1).select(current_timestamp).withColumn("to_date", to_date($"current_timestamp()")).show()
+--------------------+----------+
| current_timestamp()|   to_date|
+--------------------+----------+
|2020-03-17 10:43:...|2020-03-17|
+--------------------+----------+

scala> Seq("2020-03-17 00:00:00").toDF("time").withColumn("unix_timestamp", unix_timestamp($"time")).show()
+-------------------+--------------+
|               time|unix_timestamp|
+-------------------+--------------+
|2020-03-17 00:00:00|    1584374400|
+-------------------+--------------+


scala> spark.range(1).select(unix_timestamp).show()
+--------------------------------------------------------+
|unix_timestamp(current_timestamp(), yyyy-MM-dd HH:mm:ss)|
+--------------------------------------------------------+
|                                              1584413996|
+--------------------------------------------------------+

scala> spark.sql("select current_date as current_date").show()
+------------+
|current_date|
+------------+
|  2020-03-17|
+------------+

scala> Seq(1582720143).toDF("time").withColumn("from_unixtime", from_unixtime($"time")).show()
+----------+-------------------+
|      time|      from_unixtime|
+----------+-------------------+
|1582720143|2020-02-26 20:29:03|
+----------+-------------------+
```

#### 格式化日期
date_format 用来格式化日期
```scala
scala> Seq("2020-03-17 00:00:00").toDF("time").withColumn("date_foramt", date_format($"time", "yyyy/MM/dd hh:mm:ss")).show()
+-------------------+-------------------+
|               time|        date_foramt|
+-------------------+-------------------+
|2020-03-17 00:00:00|2020/03/17 12:00:00|
+-------------------+-------------------+
```
### 复杂数据结构处理
就跟我们平常使用这些数据结构一样，取元素，追加元素，求长度，根据里面的数据做处理，修改数组，记录状态等。 org.apache.spark.sql.functions 中 @group 为 collection_funcs 的函数就是用来实现这些功能的。下面只介绍下经常遇到和使用的函数，更多的可以去看源码。

#### 处理 Array
|Method|	Description|
|------|----------|
|array_contains	|某个值是否在 array 中。|
|array_join	|类似于 Python 中的 “,”.join。指定分隔符和可选的空值替换符连接 array 中的值。
|element_at	|按索引取值，索引从 1 开始。
|explode	|平铺数组中内容到多行
|reverse	|反转数组
|array_zip	|合并数组到结构体，array1 array2 →  array<struct>

这里 explode 比较重要，像一个用户的多个事件被存在了数组里面，就可以使用 explode 提取出来，变成一行一个事件处理。explode 变多行，那么我想把数组里面的值依次取出来变成多列呢？

这是一个问题，你可以去了解下 transform，想想如何实现。

再有一些比较复杂的操作，比如我们想通过数组前面的均值来计算填充 null 值，这时候你就需要用 UDF 自己写处理逻辑来实现了。

```scala
scala> val array = Seq("1 2 3 4 5").toDF("id_string").withColumn("id_array", split($"id_string", " "))
array: org.apache.spark.sql.DataFrame = [id_string: string, id_array: array<string>]

scala> array.show()
+---------+---------------+
|id_string|       id_array|
+---------+---------------+
|1 2 3 4 5|[1, 2, 3, 4, 5]|
+---------+---------------+

scala> array.withColumn("head", element_at($"id_array", 1)).show()
+---------+---------------+----+
|id_string|       id_array|head|
+---------+---------------+----+
|1 2 3 4 5|[1, 2, 3, 4, 5]|   1|
+---------+---------------+----+

scala> array.withColumn("array_contains", array_contains($"id_array", "1")).show()
+---------+---------------+--------------+
|id_string|       id_array|array_contains|
+---------+---------------+--------------+
|1 2 3 4 5|[1, 2, 3, 4, 5]|          true|
+---------+---------------+--------------+

scala> array.withColumn("array_join", array_join($"id_array", ",")).show()
+---------+---------------+----------+
|id_string|       id_array|array_join|
+---------+---------------+----------+
|1 2 3 4 5|[1, 2, 3, 4, 5]| 1,2,3,4,5|
+---------+---------------+----------+

scala> array.select(explode($"id_array")).show()
+---+
|col|
+---+
|  1|
|  2|
|  3|
|  4|
|  5|
+---+
scala> val df = spark.sql("select arrays_zip(array(1,2,3),array('4','5')) as array_zip")
df: org.apache.spark.sql.DataFrame = [array_zip: array<struct<0:int,1:string>>]

scala> df.show(false)
+----------------------+
|array_zip             |
+----------------------+
|[[1, 4], [2, 5], [3,]]|
+----------------------+
```

#### 处理 Map

|Method	|Description|
|-------|---------|
|map_keys	|返回 map 的 key
|map_values	|返回 map 的 value
|map_from_arrays	|接收两个数组，第一个数组为 key 数组，第二个数组为 value 数组，key 数组不允许存在空值。
|getField / getItem	|根据 key 取值

不同于结构体，map 里面的数据类型要求是一致的。
```scala
scala> val map = Seq(Map(1 -> "1"), Map(2 -> "2")).toDF("map")
map: org.apache.spark.sql.DataFrame = [map: map<int,string>]

scala> map.show()
+--------+
|     map|
+--------+
|[1 -> 1]|
|[2 -> 2]|
+--------+
scala> map.withColumn("getField", $"map".getItem(1)).show()
+--------+--------+
|     map|getField|
+--------+--------+
|[1 -> 1]|       1|
|[2 -> 2]|    null|
+--------+--------+
```

#### 处理 struct

类似于 C++ 中的结构体。在 Scala 中可以用 case class  实现。取出数据可以用 getField。如果你想构造自己的结构体，可以直接使用 struct 函数，接收多列组合成一列，组合列的类型是结构体。如果你想展开结构体，可以直接在 select 中使用 * 通配符。

```scala
scala> val simple_struct = df.select(explode($"array_zip"))
simple_struct: org.apache.spark.sql.DataFrame = [col: struct<0: int, 1: string>]

scala> simple_struct.select("col.*").show()
+---+----+
|  0|   1|
+---+----+
|  1|   4|
|  2|   5|
|  3|null|
+---+----+
scala> spark.sql("select struct(1, 2, 3, 4,  5)").show()
+---------------------------------------------------------+
|named_struct(col1, 1, col2, 2, col3, 3, col4, 4, col5, 5)|
+---------------------------------------------------------+
|                                          [1, 2, 3, 4, 5]|
+---------------------------------------------------------+
```
#### 处理 Json
Spark 在读取 json 数据格式的时候会自动解析出各列。有时候你可能需要在数据中生成 json 字符串。这里会用到 to_json。 

### 聚合计算
聚合计算主要是 sum，min，max，avg，countDistinct 等等，常和 groupBy，agg 等结合使用。在后面的 Aggregate 中详细讲

### 其他
这里的其他函数指的是  org.apache.spark.sql.functions 中 @group 为 normal_funcs 的函数。介绍一下常用的。

|Method	|Description|
|-------|----------|
|lit	|生成一个 Column，该 Column 的值是不变的
|typedLit|	生成一个 Column，该 Column 的值是不变的，和上面的区别是支持 Scala 中的 Seq，Map，List 类型
|struct	|生成结构体
|when	|类似于 sql 中的 when，和 otherwise 结合使用

tip：对于 lit，我们在指定 track 的类型。对于 typedLit，我们可以用于指定生成一个空的 properties。对与 struct，我们用来选取指定字段构造 properties。这里直接拿一段 Spark SQL 的代码举例。

```scala
pvInfoDF
      .select(cols.map(col(_)): _*)
      .filter(adjust_valid)
      .filter(delimiter_valid)
      .filter(!col("$ip").contains(","))
      .filter($"channel_id" isin (channel: _*))
      .na.replace(cols, Map("-" -> ""))
      .withColumn("original_id", UDF.getUUID($"original_id"))
      .withColumn("distinct_id", when($"distinct_id".notEqual(""), $"distinct_id").otherwise($"original_id"))
      .withColumn("hour", UDF.intUDF($"hour"))
      .withColumn("type", lit("track"))
      .withColumn("time_free", lit(true))
      .withColumn("project", lit(s"$project"))
      .withColumn("event", lit("$pageview"))
      .withColumn("$screen_width", UDF.getScreen($"screen", lit(0)))
      .withColumn("$screen_height", UDF.getScreen($"screen", lit(1)))
      .withColumn("time", unix_timestamp($"time", "yyyy-MM-dd HH:mm:ss"))
      .transform(UDF.transformInt(int_cols))
```


