---
title: UDAF - User Defined Aggregate  Functions
date: 2020-03-31 14:20:05
tags: Spark
---

### 前言
UDF 是基于列的自定义处理函数。UDAF 是基于多行的自定义处理函数。UDAF 用于 Untyped Dataset，Aggregator 用于处理自定义 Scala 对象构成的数据集的聚合。本文主要以三个例子来实现简单的 UDAF 和 Aggregator。
<!--more-->
### UDAF
UDAF 的定义继承 UserDefinedAggregateFunction。必须实现以下几个函数

|方法|	释义|
|------|--------|
|inputSchema|	输入的数据类型
|bufferSchema|	中间计算结果类型
|dataType|	聚合函数最终返回的类型
|deterministic|	相同输入是否返回相同输出，true
|initialize	|初始化中间结果 buffer
|update	|分区内计算结果，更新 buffer
|merge	|分区之间合并计算结果
|evaluate	|从 buffer 中获取最终结果


只需要创建 UDAF 对应的实例，便可以在 sql 或者 agg 中使用。比如 val myCount = new MyCountUDAF。
```scala
import org.apache.spark.sql.{Row, SparkSession}
import org.apache.spark.sql.types._
import org.apache.spark.sql.expressions.{MutableAggregationBuffer, UserDefinedAggregateFunction, Aggregator}
import org.apache.spark.sql.{Encoders, Encoder}

class MyCountUDAF extends UserDefinedAggregateFunction {
  override def inputSchema: StructType = {
    new StructType().add("id", LongType, nullable = true)
  }

  override def bufferSchema: StructType = {
    new StructType().add("count", LongType, nullable = true)
  }

  override def dataType: DataType = LongType

  override def deterministic: Boolean = true

  override def initialize(buffer: MutableAggregationBuffer): Unit = buffer(0) = 0L

  override def update(buffer: MutableAggregationBuffer, input: Row): Unit = buffer(0) = buffer.getLong(0) + 1

  override def merge(buffer: MutableAggregationBuffer, row: Row): Unit = buffer(0) = buffer.getLong(0) + row.getLong(0)

  override def evaluate(buffer: Row): Any = buffer.getLong(0)

}

class MyAverageUDAF extends UserDefinedAggregateFunction{
  override def inputSchema: StructType = {
    new StructType().add("inputColumn", LongType)
  }

  override def bufferSchema: StructType = {
    new StructType()
      .add("sum", LongType)
      .add("count", LongType)
  }

  override def dataType: DataType = DoubleType

  override def deterministic: Boolean = true

  override def initialize(buffer: MutableAggregationBuffer): Unit = {
    buffer(0) = 0L
    buffer(1) = 0L
  }

  override def update(buffer: MutableAggregationBuffer, input: Row): Unit = {
    buffer(0) = buffer.getLong(0) + input.getLong(0)
    buffer(1) = buffer.getLong(1) + 1
  }

  override def merge(buffer1: MutableAggregationBuffer, buffer2: Row): Unit = {
    buffer1(0) = buffer1.getLong(0) + buffer2.getLong(0)
    buffer1(1) = buffer1.getLong(1) + buffer2.getLong(1)
  }

  def evaluate(buffer: Row): Double = buffer.getLong(0) / buffer.getLong(1)

}

val myCount = new MyCountUDAF
val myAverage = new MyAverageUDAF
spark
    .range(start = 0, end = 4, step = 1, numPartitions = 2)
    .withColumn("group", $"id" % 2)
    .groupBy("group")
    .agg(myCount.distinct($"id") as "count")
    .show()
spark
    .range(start = 0, end = 4, step = 1, numPartitions = 2)
    .agg(myAverage($"id"))
    .show()
```

### Aggregator
自定义的 Aggregator 继承自 org.apache.spark.sql.expressions.Aggregator。必须实现一下几个方法。

|方法|	释义|
|-----|--------|
|zero|	计算结果初始值
|reduce	|分区内计算结果
|merge	|分区间合并计算结果
|finish	|计算最终结果并制定结果类型
|outputEncoder|	结果类型指定编码器
|bufferEncoder|	中间结果类型指定编码器

需要注意的是，在使用 Aggreagtor 的时候，需要 toColumn 来生成 TypedColumn 用于计算。就跟 groupBykey 中的一样，需要使用 typed.avg 来标记。

```scala
case class Employee(name:String, salary:Long)
case class Average(var count:Long, var sum:Long)

class MyAverageAggregator extends Aggregator[Employee, Average, Double]{
  // 初始化类型buffer
  override def zero: Average = Average(0L, 0L)
  // 计算聚合中间结果
  override def reduce(b: Average, a: Employee): Average = {
    b.count += 1
    b.sum += a.salary
    b
  }
  // 合并中间结果
  override def merge(b1: Average, b2: Average): Average = {
    b1.sum += b2.sum
    b1.count += b2.count
    b1
  }
  // 计算最终结果并确定类型
  override def finish(reduction: Average): Double = reduction.sum.toDouble / reduction.count
  // 中间值类型指定编码器
  override def bufferEncoder: Encoder[Average] = Encoders.product
  // 结果类型指定编码器
  override def outputEncoder: Encoder[Double] = Encoders.scalaDouble

}

val employee = Seq(
      Employee("Tom", 2674),
      Employee("Ton", 3400),
      Employee("Top", 4218),
      Employee("Tos", 1652)
    )
employee.toDS().select(myAveragor.toColumn.name("average_salary")).show() // 因为这里是Dataset[Employee]类型数据做聚合,所以toDS
```
