---
title: Scala实用指南-从Java到Scala
tags: Scala
categories: Scala
abbrlink: 1f41a4db
date: 2020-06-02 14:24:40
---
### 前言
接触 Scala 小半年，主要用来写 Spark SQL。不得不感叹这东西的学习曲线，入门简单，深入难，好多姿势不懂什么意思，往往写不出 Scala 的特性。现在基本就是拿来当简洁版的 Java 来用，囿于这种想法，常常觉得为啥别人写的 Scala 这么炫，姿势这么多。但是其实忽略了简洁也正是 Scala 相比 Java 的一个优点。
本文主要介绍 Scala 的简洁性，用比 java 更少的代码量来达到同样的效果甚至更好，更容易让人理解。 不深究其中的一些特性，仅仅展现，让我们知道可以这样做。
<!--more-->

### Scala-简洁的Java
#### 减少样板代码
以简单的 for 循环代码为例，分别用 Java 和 Scala 实现
```java
public class Greetings {
 	public static void main(String[] args) {
 		for(int i = 1; i < 4; i++) {
 			System.out.print(i + ",");
 		}
 		System.out.println("Scala Rocks!!!"); 
 }
 ```
可以看下用 Scala 改写后的代码。

- 去掉了多余的代码结尾分号，降低了代码噪声。
- 简单的 print 输出。 去除了没有什么实际意义的 Greetings 类。
- 函数式代码风格的引用使得我们可以一行书写 for 循环。
- 去除了变量类型的显式声明

在这里，你可能有很多疑问，这些问题我们可以先放一放，尽管先熟悉 Scala 的代码风格结构，后面文章会解释。

- 为什么调用方法不用 .？比如 to foreach 的调用。
- 为什么函数可以作为方法的参数？
- 为什么不需要显示声明变量类型？

```scala
object Greeting{
	1 to 3 foreach(i => print(s"$i,"))
	println("Scala Rocks!!!")
}
```

#### 不可变性
Scala 中用 var 或者 val 来声明变量。val 声明的变量是不可变的，相当于 final。不可变是 FP 的重要特性，减少了代码副作用，状态不会改变，只是迭代转换变成了新的状态。

```scala
scala> val a = 1
a: Int = 1

scala> val a = 2
a: Int = 2

scala> a = 3
<console>:12: error: reassignment to val
       a = 3
```
咦？不是说了 val 定义的是不可变的吗，怎么 a 变了？这是 shadow 机制，其实就是 a 的引用发生了变化。直接修改 a = 3 就不一样了，会造成编译错误。
像上边的 for 循环中的 i 值其实也并没有跟着变化，在每次循环过程中，我们都创建一个不同的名为 i 的 val 变量。我们不会
在循环中不经意地改变变量 i 的值，因为变量 i 是不可变的。

####v类型推断
在 Scala 中不必每次都显式声明类型。Scala 自己会根据上下文信息，推断出变量或者函数的返回值信息。可以自己 scala REPL 中试下。
最后也可以看到，scala 允许去除 return 关键字。返回值及类型和函数方法中的最后一行有关。

```scala
scala> def a() = 1
a: ()Int

scala> a
res0: Int = 1

scala> def a(x:Int) = println(x)
a: (x: Int)Unit

scala> a(1)
1

scala> def a() = {1;"1"}
<console>:11: warning: a pure expression does nothing in statement position; multiline expressions might require enclosing parentheses
       def a() = {1;"1"}
                  ^
a: ()String

scala> a
res3: String = 1
```
#### 高阶函数
最常见的 map，reduce，fold，filter。接收函数值作为参数，这些高阶函数其实是提高了代码的复用性。像对列表中的元素做操作，不必再每次以命令式的风格循环代码计算，而是只需要用高阶函数接收一个操作函数，告诉编译器我要做什么，而不是怎么做。

```scala
scala> val seq = 1 until 5 toArray
seq: Array[Int] = Array(1, 2, 3, 4)

scala> seq.map(_*2)
res4: Array[Int] = Array(2, 4, 6, 8)

scala> seq.reduce(_+_)
res5: Int = 10

scala> seq.filter(i => i % 2 == 0)
res6: Array[Int] = Array(2, 4)

scala> seq.fold(0)(Math.max)
res7: Int = 4
```
#### 元组和多重赋值
Scala 中函数允许返回多个值，其实是个元组。而 Java 中如果需要返回多个值，还要构造额外的类
```scala
def getPersonInfo(primaryKey: Int) = {
 ("Venkat", "Subramaniam", "venkats@agiledeveloper.com")
}
val (firstName, lastName, emailAddress) = getPersonInfo(1)
val info = getPersonInfo(1)
println(info._1)
pringln(info._2)
```
#### 隐式类型转换，隐式参数
Scala 中的隐式转换是个很神奇的东西，有时候会让人感觉莫名其妙，但是却很强大。Scala 中可以直接调用 2.toString，但是 Int 类型并没有这样的方法，这里其实是 Int 自动转换成了 RichInt。这里先只说下隐式参数和隐式类型转换。
```scala
// 隐式参数, 如果参数没有定义且被 implicit 修饰，会在当前作用域内查找相同类型的隐式参数

object implicitParams {
  def foo(amount:Float)(implicit rate: Float) = println(amount * rate)
}

// 隐式类型转换 编译器在当前作用域查找类型转换方法，对数据类型进行转换。

object implicitTypeTra {
  implicit def doubleToInt(i: Double) = i.toInt
  def typeTra(i: Int) = println(i)
}

import implicitParams._
import implicitTypeTra._
implicit val rat = 0.3f
foo(10)
typeTra(3.5)
```
看下上面的例子，并没有出现编译错，隐式转换为我们自动解决了。emnn，某种意义上可以说隐式转换是一种编译器自我修复机制。通过定义某些隐式转换，我们也减少了代码量。

#### 操作符重载
Scala 中没有绝对意义的操作符，+ - * / 都是方法，因此都可以重写以支持自定义类型的操作。
```scala
class Complex(val real: Int, val imaginary: Int) {
 	def +(operand: Complex): Complex = {
  		new Complex(real + operand.real, imaginary + operand.imaginary)
 	}
 	override def toString: String = {
 		val sign = if (imaginary < 0) "" else "+"
 		s"$real$sign${imaginary}i"
 	}
}
```
#### 权限控制
在不使用任何访问修饰符的情况下，Scala 默认认为类、字段和方法都是公开的。不用在额外写 public 关键字。