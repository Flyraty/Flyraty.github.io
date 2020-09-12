---
title: Aggregate - 普通的聚合计算和基于 window 的聚合计算
tags: Spark
categories: BigData
abbrlink: bfb6e21b
date: 2020-03-26 14:19:54
---
### 前言
聚合计算对于数据统计有着重要的作用，比如常见的 Top N 问题。本文主要介绍常见的聚合计算函数以及基于 Window 的处理。
<!--more-->

### Basic Aggregate
Spark 提供了 groupBy 等聚合操作以及在这些操作的上的聚合函数。聚合操作符其实也就是转换算子，可以在 Dataset.scala RDD.scala 中查看。聚合函数定义在 org.apache.spark.sql.functions 中。函数签名  @group为 agg_funcs。

在讲转换算子的时候，已经简单提到了 groupBy，groupByKey，agg 这些聚合操作符。可以在回顾一下。

#### RelationGroupedDataset 与 KeyValueGroupedDataset
RelationGroupedDataset 是 DataFrame 聚合计算的接口，groupBy，cube，rollup，pivot 算子会生成 RelationGroupedDataset。其支持的聚合计算函数都定义在 spark-sql 的 RelationGroupedDataset.scala 里面。

KeyValueGroupedDataset 用于 TypedColumn 的聚合计算，其作用的数据集往往是自定义的 Scala 对象，而不是 Rows。由 groupByKey 算子生成。其支持的聚合计算函数都定义在 spark-sql 的 KeyValueGroupedDataset.scala 里面。

因为 KeyValueGroupedDataset 处在试验阶段，两者支持的聚合计算函数有些差别，具体可以查看源码。

#### groupBy

![](https://tva1.sinaimg.cn/large/00831rSTly1gd7rp1yu06j313a0a4mzz.jpg)

![](https://tva1.sinaimg.cn/large/00831rSTly1gd7rptny42j313c0m878r.jpg)

groupBy 就是返回 key 及 key 对应的数据集，不能保证每组有序。因此如果你想保证分组内有序，可能会用到下面的 Window Agg。使用 groupBy 的代价比较大，是先通过 shuffle 将各个 Key 对应的数据拉到各个对应分区下，再进行聚合计算。注释里建议使用 aggregateByKey 或者 reduceByKey。另外 Dataset groupBy 接收的参数是 String 类型。

aggregateByKey 是先聚合计算，在合并分区，相对来说计算量小，所以性能比较好。接收一个初始值，一个分区内聚合函数，一个分区结果合并函数作为参数。更多使用可以参考[aggreagteByKey](https://gist.github.com/tmcgrath/dd8a0f5fb19201deb65f)。

```scala
scala> val nums = spark.range(10).withColumn("remainder", $"id" % 2)
nums: org.apache.spark.sql.DataFrame = [id: bigint, remainder: bigint]

scala> nums.show()
+---+---------+
| id|remainder|
+---+---------+
|  0|        0|
|  1|        1|
|  2|        0|
|  3|        1|
|  4|        0|
|  5|        1|
|  6|        0|
|  7|        1|
|  8|        0|
|  9|        1|
+---+---------+

scala> scala> nums.agg(sum("id")).show()
+-------+
|sum(id)|
+-------+
|     45|
+-------+
scala> nums.groupBy("remainder")
res4: org.apache.spark.sql.RelationalGroupedDataset = RelationalGroupedDataset: [grouping expressions: [remainder: bigint], value: [id: bigint, remainder: bigint], type: GroupBy]

scala> nums.groupBy("remainder").agg(sum("id")).show()
+---------+-------+
|remainder|sum(id)|
+---------+-------+
|        0|     20|
|        1|     25|
+---------+-------+

scala> val rdd = sc.parallelize(Seq((1, 2), (1, 4), (2, 5), (2, 6)))
rdd: org.apache.spark.rdd.RDD[(Int, Int)] = ParallelCollectionRDD[12] at parallelize at <console>:24

scala> rdd.collect
res19: Array[(Int, Int)] = Array((1,2), (1,4), (2,5), (2,6))

scala> rdd.aggregateByKey(0)((a, b) => a + b, (res1, res2) => res1 +res2).collect
res20: Array[(Int, Int)] = Array((1,6), (2,11))
```

#### groupByKey
![](https://tva1.sinaimg.cn/large/00831rSTly1gd7rq7b0l6j30zw0jg0wi.jpg)

groupByKey 还处在试验阶段，接收一个函数作为参数，返回 KeyValueGroupedDataset。想的是让分组的条件可以更加的灵活，不局限于基于列名的分组。比如基于数组里的第几个元素。与 groupBy 一样，是先 shuffle ，在聚合计算。通过下面的代码，我们可以看到 Dataset + groupByKey 后面跟的计算函数比较少，不支持 sum，avg 等。另外还需要注意这里已经是 TypedColumn。

```scala
scala> case class People(name:String, salary:Int)
defined class People

scala> val ds = Seq(People("Mike", 1000), People("Mike", 600), People("David", 400)).toDS
ds: org.apache.spark.sql.Dataset[People] = [name: string, salary: int]

scala> ds.groupByKey(_.salary)
res21: org.apache.spark.sql.KeyValueGroupedDataset[Int,People] = KeyValueGroupedDataset: [key: [value: int], value: [name: string, salary: int]]

scala> ds.groupByKey(_.salary).sum("salary").show()
<console>:26: error: value sum is not a member of org.apache.spark.sql.KeyValueGroupedDataset[Int,People]
       ds.groupByKey(_.salary).sum("salary").show()

scala> ds.groupByKey(_.salary).agg(avg("salary")).show()
<console>:26: error: type mismatch;
 found   : org.apache.spark.sql.Column
 required: org.apache.spark.sql.TypedColumn[People,?]
       ds.groupByKey(_.salary).agg(avg("salary")).show()

scala> import org.apache.spark.sql.expressions.scalalang._
import org.apache.spark.sql.expressions.scalalang._

scala> ds.groupByKey(_.name).agg(typed.avg[People](_.salary)).show()
+-----+------------------------------------------+
|value|TypedAverage($line43.$read$$iw$$iw$People)|
+-----+------------------------------------------+
| Mike|                                     800.0|
|David|                                     400.0|
+-----+------------------------------------------+
```
#### agg
agg 一般作用于分组后的数据集上，也可以作用于整个数据集上。其具体的方法可以查看 spakr-sql Dataset.scala。agg 可以接收 map，expression 类型的参数。直接看例子吧

```scala
scala> nums.groupBy("remainder").agg(Map("id" -> "sum")).show()
+---------+-------+
|remainder|sum(id)|
+---------+-------+
|        0|     20|
|        1|     25|
+---------+-------+

scala> nums.groupBy("remainder").agg(sum("id").alias("sum"), avg("id").alias("avg")).show()
+---------+---+---+
|remainder|sum|avg|
+---------+---+---+
|        0| 20|4.0|
|        1| 25|5.0|
+---------+---+---+
```

### Window Aggregate
#### Window
窗口计算，这里的 window 像是有序的分组。window 相比 groupBy 保证了分组有序。emnn，当然了，你也可以自己选择初始化 window 的时候不进行 orderBy。

![](https://tva1.sinaimg.cn/large/00831rSTly1gd7rqjkae3j314q0es41o.jpg)

window 的源码在 spark.sql  的 expressions.window 中。从源码中可以看到 window 的类型是一个叫 windowSpec 的东西。点进去，可以发现创建一个 windowSpec 所需的东西 → parationBy，orderBy，Frame 边界。 parationBy 和 orderBy 比较容易理解。就是分区和区内排序。下面说要 Window Frame 的一些概念。

Frame 边界可以由 rowsbetween，rangeBetween 等指定。而边界会有一些变量和偏移量来指定。比如 （window.currentRow，2）的含义就是当前行和后面两行作为一个计算单元。

|变量|	描述|
|-------|--------|
|window.currentRow|	当前行
|window.unboundedPreceding	|分区内的第一行
|window.unboundedFollowing|	分区内的最后一行

下面的例子定义了几个 window，你应该已经发现了问题，这几个 window 的 parationBy，orderBy和边界都是一样的，但是基于 window 的计算结果确是不一样的。这是因为定义边界的方法不一样。 

|方法|	描述|
|------|-----|
|rowsBetween	|物理边界，rowsBetween(Window.currentRow, 1)，对于下面的例子来说，就是分区内当前行与前一行|
|rangeBetween	| 逻辑边界，rangeBetween(Window.currentRow, 1)，对于下面的例子来说，就是符合当前行 <= id <= 当前行的值 + 1 的所有行作为一个计算单元。rangeBetween(-1, 3)，就是 当前行的值 - 1 <= id <= 当前行的值 + 3 的所有行作为一个计算单元|


```scala
scala> val df = Seq((1, "a"), (1, "a"), (2, "a"), (1, "b"), (2, "b"), (3, "b")).toDF("id", "category")
df: org.apache.spark.sql.DataFrame = [id: int, category: string]

scala> import org.apache.spark.sql.expressions.Window
import org.apache.spark.sql.expressions.Window

scala> val window = Window.partitionBy("category").orderBy("id").rowsBetween(Window.currentRow, 1)
window: org.apache.spark.sql.expressions.WindowSpec = org.apache.spark.sql.expressions.WindowSpec@62ff2e08

scala> df.withColumn("sum", sum("id") over window).show()
+---+--------+---+
| id|category|sum|
+---+--------+---+
|  1|       b|  3|
|  2|       b|  5|
|  3|       b|  3|
|  1|       a|  2|
|  1|       a|  3|
|  2|       a|  2|
+---+--------+---+

scala> val window = Window.partitionBy("category").orderBy("id").rangeBetween(Window.currentRow, 1)
window: org.apache.spark.sql.expressions.WindowSpec = org.apache.spark.sql.expressions.WindowSpec@6fae2aa5

scala> df.withColumn("sum", sum("id") over window).show()
+---+--------+---+
| id|category|sum|
+---+--------+---+
|  1|       b|  3|
|  2|       b|  5|
|  3|       b|  3|
|  1|       a|  4|
|  1|       a|  4|
|  2|       a|  2|
+---+--------+---+
```

#### Window Aggregate Functions
除了和 groupBy 一样，有 sum，max，avg 等函数外。window 还为我们提供了处理每个分组内行与行之间计算的方法。

|方法|	描述|
|----|-----|
|rank	|排行
|dense_rank	|排行
|ntile	|排行
|precent_rank	|
|cume_dist	|累计概率分布
|row_number	|增加行号列
|lag	|计算当前行与前 offset 行的差值，没有会为 null，可以设置 defaultValue。
|lead	|计算当前行与后 offset 行的差值，没有会为 null，可以设置 defaultValue。
|rank |遇到重复值和 dense_rank 遇到重复值的处理方式是不一样的。rank 遇到重复值使用相同排行，但是整体排行会增加，而 dense_rank 不会增加。

```scala
val dataset = spark.range(9).withColumn("bucket", 'id % 3)

import org.apache.spark.sql.expressions.Window
val byBucket = Window.partitionBy('bucket).orderBy('id)

scala> dataset.union(dataset).withColumn("rank", rank over byBucket).show
+---+------+----+
| id|bucket|rank|
+---+------+----+
|  0|     0|   1|
|  0|     0|   1|
|  3|     0|   3|
|  3|     0|   3|
|  6|     0|   5|
|  6|     0|   5|
|  1|     1|   1|
|  1|     1|   1|
|  4|     1|   3|
|  4|     1|   3|
|  7|     1|   5|
|  7|     1|   5|
|  2|     2|   1|
|  2|     2|   1|
|  5|     2|   3|
|  5|     2|   3|
|  8|     2|   5|
|  8|     2|   5|
+---+------+----+

scala> dataset.union(dataset).withColumn("dense_rank", dense_rank over byBucket).show
+---+------+----------+
| id|bucket|dense_rank|
+---+------+----------+
|  0|     0|         1|
|  0|     0|         1|
|  3|     0|         2|
|  3|     0|         2|
|  6|     0|         3|
|  6|     0|         3|
|  1|     1|         1|
|  1|     1|         1|
|  4|     1|         2|
|  4|     1|         2|
|  7|     1|         3|
|  7|     1|         3|
|  2|     2|         1|
|  2|     2|         1|
|  5|     2|         2|
|  5|     2|         2|
|  8|     2|         3|
|  8|     2|         3|
+---+------+----------+
```
其他一些函数，我个人也写了一些示例，感兴趣可以运行一下
```scala
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.expressions.{Window, WindowSpec}
import org.apache.spark.sql.functions._

object window_aggregate {
  val spark = SparkSession.builder.master("local[*]").getOrCreate()
  import spark.implicits._

  /*
   * 详细可以查看源码，类型 org.apache.spark.sql.expressions.WindowSpec
   * val window:WindowSpec = Window.partitionBy("id").orderBy("year")
   */

  case class Salary(depName: String, empNo: Long, salary: Long)
  val empSalary = Seq(
    Salary("sales", 1, 5000),
    Salary("personnel", 2, 3900),
    Salary("sales", 3, 4800),
    Salary("sales", 4, 4800),
    Salary("personnel", 5, 3500),
    Salary("develop", 7, 4200),
    Salary("develop", 8, 6000),
    Salary("develop", 9, 4500),
    Salary("develop", 10, 5200),
    Salary("develop", 11, 5200)).toDS

  def main(args: Array[String]): Unit = {
    /*
     * window Rank functions
     * rank
     * dense_rank
     * row_number
     */
    val nameWindowDesc = Window.partitionBy("depName").orderBy($"salary".desc)
    empSalary.withColumn("rank", rank() over nameWindowDesc).show()

    empSalary
      .withColumn("dense_rank", dense_rank() over nameWindowDesc)  // Top n Salary
      .filter($"dense_rank" <= 2)
      .show()


    /*
     * window Analytic functions
     * lag  计算当前行与前 offset 行, 没有会置null, 也可以设置参数 default_value
     * lead 计算当前行与后 offset 行
     * cume_dist 出现的概率累计分布
     *
     */
    val diffSalaryPerRow = empSalary.withColumn("diff", lag($"salary", 1) over nameWindowDesc)
    val diffSalaryTwoRow = empSalary.withColumn("diff", lead($"salary", 2) over nameWindowDesc)

    diffSalaryPerRow.show()
    diffSalaryTwoRow.show()

    empSalary
      .withColumn("cume_dist", cume_dist() over nameWindowDesc)
      .show()


    /*
     * window Aggregate functions
     * 注意一下rangeBetween, rowBetween, 说白了就是为window Frame 的计算设置边界。
     */
    val nameWindow = Window.partitionBy("depName")
    empSalary.withColumn("avg", avg($"salary") over nameWindow).show()
    empSalary.withColumn("avg", max($"salary") over nameWindow).show()

    val rangeWindow = Window.rangeBetween(Window.currentRow, 1)
    empSalary.withColumn("avg", sum($"salary") over rangeWindow).show() // 打印出来会是什么呢？

    val maxSalary = max($"salary").over(nameWindow) - $"salary"
    empSalary.withColumn("salary_max_diff", maxSalary).show()

    val orderWindow = Window.orderBy("salary") // 会报Warning, 没有partitionBy 会导致数据都到一个partition下面
    empSalary
      .withColumn("salary_total", sum("salary") over orderWindow)
      .show()


  }


Multidimensional Analysis
多维度分析。根据指定列的排列组合进行 groupBy。

cube / rollup
cube，rollup 都用于多维度分析。区别在于 cube 是对传入的列的所有组合来 groupBy，而 rollup 是层次级别的。比如下面的例子，cube 的操作是 (age, city)，(age)， (city)，全表分组。rollup的操作是 (age, city)，(age)，全表分组。

val columns = Seq("name", "age", "city", "vip_level", "view_count")
val users = Seq(
		("Tom", 10, "北京", 0, 111),
		("Jack", 20, "上海", 1, 3000),
		("David", 23, "北京", 3, 4000),
		("Mary", 18, "上海", 1, 1234),
		("Tony", 50, "深圳", 0, 200),
		("Group", 60, "北京", 0, 40),
		("Ali", 34, "上海", 4, 6666),
		("Alas", 45, "北京", 2, 10000)
	).toDF(columns: _*)

users
	.rollup("age", "city")
	.sum("view_count").alias("sum_view")
	.na.fill("None")
	.show()

users
	.cube("age", "city")
	.sum("view_count").alias("sum_view")
	.show()


pivot 透视
pivot 透视，利用 stack 反透视。关于透视表，请移步维基百科透视表。可以运行下面的例子自己看下。

val example = Seq(
      ("北京", 10000, 2015),
      ("北京", 11000, 2016),
      ("北京", 12000, 2017),
      ("上海", 10300, 2015),
      ("上海", 11700, 2016)
    ).toDF("city", "value", "year")

example.show()
val piv = example.groupBy("city").pivot("year").sum("value")
piv.show()

val unPiv = piv
	.selectExpr("city", "stack(3, '2015', `2015`, '2016', `2016`, '2017', `2017`) as (year, value)")
    .filter($"value".isNotNull)
unPiv.show()
```

