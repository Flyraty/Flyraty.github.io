---
title: "transform -\_transformations chain"
tags: Spark
categories: BigData
abbrlink: '3e030130'
date: 2020-04-10 14:19:17
---
### 前言
transform 是一个灵活的转换算子，接收一个自定义的函数作为参数来处理计算逻辑。它最大的功能是链接多个自定义的转换算子，简化代码，将相似的计算统一起来。本文会通过两个例子来介绍 transform 的功能。
<!--more-->

### transfrom
#### 均值计算填充数组中的空值
根据数组每个值前四项的均值来填充 -1 ，不足四项，则按照前面的长度来计算均值。在 Build-In Functions 里面抛出过这个问题。当然我们可以写 UDF 来处理数组。这里用 transform 的实现是这样的。我们只需要考虑均值计算的逻辑即可。

```scala
import org.apache.spark.sql.{DataFrame, SparkSession}


object transform {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder().master("local")
      .config("spark.ui.port", "14040").getOrCreate()
    import org.apache.spark.sql.functions._
    import spark.implicits._
    val colNames = Seq("vendor", "20190101", "20190102", "20190103", "20190104",
      "20190105", "20190106", "20190107", "20190108", "20190109")
    var ds = Seq(
      ("20015545", 1, 2, 3, 4, 5, 6, 7, 8, 9),
      ("20015546", 11, 12, 13, 14, 15, 16, 17, 18, -1),
      ("20015547", 11, 12, -1, 14, 15, 16, 17, 18, -1))
      .toDF(colNames: _*)

    val valColNames = colNames.drop(1)

    def averageFunc(colNames: Seq[String]) = {
      val markCols = colNames.map(col(_))
      markCols.foldLeft(lit(0)) { (x, y) => x + y } / markCols.length
    }

    def replaceCol(colIdx: Int, colNames: Seq[String])(df: DataFrame): DataFrame = {
      val colI = colNames(colIdx)
      val start = if (colIdx >= 4) colIdx - 4 else 0
      val cols = colNames.slice(start, colIdx)
      println(cols)
      val checkVal = udf((v: Int) => v != -1)
      if (cols.length == 0) df else df.withColumn(colI, when(checkVal(col(colI)), col(colI)).otherwise(averageFunc(cols)))
    }

    ds.show()
    valColNames.indices.foreach(idx => {
      ds = ds.transform(replaceCol(idx, valColNames))
      ds.show()
    })

  }
}
```


#### 一列变多列
根据 Array[Array[String]] 生成多列。Array[String] 长度为二，以第一个值为列名，第二个值为列值。

```scala
def cusExplodeArray(columns: Seq[String])(df: DataFrame): DataFrame = {
    var dfi = df
    for (i <- 0 until columns.size) {
      if (i == 0) {
        dfi = dfi.withColumn(columns(i), col("fill_revenue_list")(i)(0))
      } else {
        dfi = dfi.withColumn(columns(i), col("fill_revenue_list")(i))
      }
    }
    dfi
  }
```  

#### 去除过多的 withColumn
withColumn 用来生成新列或者对现有列做一些改变。假设我们有一个数据集有上百个字段，其中很多字段要求 String → Int。我们肯定是不能写上百个 withColumn 的。这时候就可以通过 transform 来统一处理类似的计算处理逻辑。

```scala
def transformInt(columns: Seq[String])(df: DataFrame) = {
    var dfi = df
    for (column <- columns) {
      dfi = dfi.withColumn(column, col(s"$column").cast("int"))
    }
    dfi
 }
```  
