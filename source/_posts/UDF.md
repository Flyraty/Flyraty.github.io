---
title: UDF - User  Defined  Functions
date: 2020-03-24 14:19:43
tags: Spark
---

### 前言
Spark 本身提供的算子可以满足我们大多数的需求，并且我们可以组合各种算子，但是计算处理逻辑往往是复杂的。有些转换逻辑需要我们自定义函数才可以实现，这些自定义函数就是 UDF。UDF 是基于列的函数，拓展了 Spark SQL DSL，用于转换数据集。
<!--more-->

### UDF
#### 声明 UDF
定义 UDF 和写其他的函数并没有什么本质的区别。

UDF 的声明常用的方式是使用 `org.apache.spark.sql.functions.udf` 。看了下源码里面的注释，udf 接收的函数的参数最多只能有十个。
```scala
scala> val upper = udf((s:String) => s.toUpperCase)
upper: org.apache.spark.sql.expressions.UserDefinedFunction = UserDefinedFunction(<function1>,StringType,Some(List(StringType)))
```
使用 SparkContext 来注册，注意在使用你注册的 UDF 时，这里使用了 selectExpr，Expression 会自动由 Spark 去解析。而 select 的参数是 column 类型，这里使用 select 会报错。
```scala
scala> spark.udf.register("myUpper", (input: String) => input.toUpperCase)
res0: org.apache.spark.sql.expressions.UserDefinedFunction = UserDefinedFunction(<function1>,StringType,Some(List(StringType)))
scala> Seq("mike").toDF("name").selectExpr("myUpper(name)").show()
+-----------------+
|UDF:myUpper(name)|
+-----------------+
|             MIKE|
+-----------------+
```
使用 UDF 也很简单，将他当成 org.apache.spark.functions._ 中的函数一样调用就可以。UDF 常出现的问题其实是是类型错误，要避免 Any 类型的出现。

#### UDF 是个黑盒？
Spark 不会尝试去优化 UDF。这里可以简单对比一下使用 UDF 与不使用 UDF 的执行计划。可以看到使用了 UDF filter 算子并没有下推。
```scala
scala> val ds = Seq(People("Mike", 18), People("Mary", 19)).toDS
ds: org.apache.spark.sql.Dataset[People] = [name: string, age: int]

scala> ds.show()
+----+---+
|name|age|
+----+---+
|Mike| 18|
|Mary| 19|
+----+---+


scala> ds.filter($"name".equalTo("Mike")).explain(true)
== Parsed Logical Plan ==
'Filter ('name = Mike)
+- LocalRelation [name#54, age#55]

== Analyzed Logical Plan ==
name: string, age: int
Filter (name#54 = Mike)
+- LocalRelation [name#54, age#55]

== Optimized Logical Plan ==
LocalRelation [name#54, age#55]

== Physical Plan ==
LocalTableScan [name#54, age#55]

scala> ds.filter(_.name == "Mike").explain(true)
== Parsed Logical Plan ==
'TypedFilter <function1>, class $line30.$read$$iw$$iw$People, [StructField(name,StringType,true), StructField(age,IntegerType,false)], unresolveddeserializer(newInstance(class $line30.$read$$iw$$iw$People))
+- LocalRelation [name#54, age#55]

== Analyzed Logical Plan ==
name: string, age: int
TypedFilter <function1>, class $line30.$read$$iw$$iw$People, [StructField(name,StringType,true), StructField(age,IntegerType,false)], newInstance(class $line30.$read$$iw$$iw$People)
+- LocalRelation [name#54, age#55]

== Optimized Logical Plan ==
TypedFilter <function1>, class $line30.$read$$iw$$iw$People, [StructField(name,StringType,true), StructField(age,IntegerType,false)], newInstance(class $line30.$read$$iw$$iw$People)
+- LocalRelation [name#54, age#55]

== Physical Plan ==
*(1) Filter <function1>.apply
+- LocalTableScan [name#54, age#55]
```


