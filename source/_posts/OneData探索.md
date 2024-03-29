---
title: OneData探索
abbrlink: 918e25c9
date: 2022-03-25 11:29:45
categories: BigData
tags: OneData
---

### 前言

2021 年下半年主要做的是 IMP 实时/离线数据流的摄入以及涉及的各种 BI 报表工作。IMP 即内部营销平台，也可以叫作端内广告投放，作为最前置的业务，IMP 整个链路横跨广告投放、策略分流、落地页、微信导流、短信/PUSH、成单等多个垂直业务单元。随着业务需求的频繁迭代，之前构建的业务数仓暴露出来越来越多的问题，表、字段的命名不统一，同一业务不同表之间的逻辑耦合，相同指标不同口径实现的来回对数也对数据研发侧造成了很大困扰，由此本身产出的数据指标的置信性也开始受到挑战。

基于以上问题，2022 年开始做了一些离线业务数仓方向上的调研以及落地规划。目标是在支撑业务快速迭代开发的前提下，统一化字段业务口径，规范化离线数据开发，降低离线表的存储资源，去除逻辑的冗余开发，提高离线 ETL 的开发效率。

本文主要介绍个人基于 OneData 的一些看法，并举一些例子。

<!--more-->

### 什么是 onedata 
官方的解释是：阿里云 OneData 数据中台解决方案基于大数据存储和计算平台为载体，以 OneModel 统一数据构建及管理方法论为主干，OneID 核心商业要素资产化为核心，实现全域链接、标签萃取、立体画像，以数据资产管理为皮，数据应用服务为枝叶的松耦性整体解决方案。其数据服务理念根植于心，强调业务模式，在推进数字化转型中实现价值。具体如图所示：

![](https://timemachine-blog.oss-cn-beijing.aliyuncs.com/img/ali_oneData.png)

可以理解为 oneData 就是提供规范定义和开发标准，借助工具或者文档实现维度和指标的统一管理，在此基础上进行标准建模，对内对外提供统一的基础数据层，以期实现相同数据加工一次即可用的目的。

### oneData 体系架构
![](https://timemachine-blog.oss-cn-beijing.aliyuncs.com/img/OneData%20%E4%BD%93%E7%B3%BB%E6%9E%B6%E6%9E%84%20%281%29.png)

说是 oneData 的体系架构，更多是一种抽象出数据体系组成的方法，是实现 oneData 之路的第一步，一般分为以下三个步骤。

1. 业务板块划分：根据业务属性，将业务划分出几个相对独立的板块，使业务板块之间的指标或业务重叠性较小。
2. 规范定义：结合行业的数据仓库建设经验和数据自身特点，设计出的一套数据规范命名体系，规范定义将会被用在模型设计中。
3. 模型设计：以维度建模理论为基础，基于维度建模总线架构，构建一致性的维度和事实（进行规范定义），同时，在落地表模型时，基于自身业务特点，设计一套规范命名体系。

在规范定义阶段会涉及到以下一些基础概念：

- 数据域：也叫主题域，指面向业务分析，将业务过程或者维度进行抽象的集合。数据域是需要抽象提炼，并且长期维护和更新的，但不轻易变动。在划分数据域时，既能涵盖当前所有的业务需求，又能在新业务进入时无影响的包含进已有的数据域中和拓展新的数据域。数据域的概念是为了更好划分管理数仓，类似文件夹中的子文件夹的概念，如果没有数据域的概念，一个数仓下上千张表的划分和管理是也是比较困难的。

- 业务过程：指企业的业务活动事件，如广告位的请求，曝光，可见曝光，点击都是业务过程。需要注意业务过程是一个不可拆分的行为事件。

- 维度：维度是度量的环境，用来反映业务的一类属性。这类属性的集合构成一个维度，也可以称为实体对象。维度属于一个数据域，如时间维度（年/月/日等），用户维度（年级、性别等）。

- 维度属性：维度属性隶属于一个维度，如用户维度里的年级，性别都是独立的维度属性。

- 原子指标/度量：原子指标和度量含义相同，都是基于某一业务事件行为下的度量，是业务定义中不可在拆分的指标，如落地页曝光等。

- 修饰类型：是对修饰词的一种抽象划分，从属与某个业务域，如课程维下的课程学科等。与维度的划分有点类似。

- 修饰词：指除了统计维度以外指标的业务场景限定抽象。

- 时间周期：用来明确数据统计的时间范围和时间点，如最近一小时等。

- 派生指标：派生指标=时间周期+修饰词+原子指标。派生指标是有实际业务含义，可以直接取数据的指标，通过限定指标的组成要素来唯一精确定义每个指标。当维度，原子指标，时间周期/修饰词都确定的时候就可以唯一确定一个派生指标，同时给出具体数值。如最近一小时内 365 资源位的点击次数。

在理解了上述概念之后，就可以根据业务需求调研的结果抽象出每个数据域下的层次结构，制定一些规范（一般包括字段命名规范，模型命名规范，数据流向规范），并以此规范进行后续数据模型的设计和优劣与否的判断标准。

### 规范定义

#### 字段命名规范
主要是词根表的建立，个人理解为词根是描述一件事物的最小单词，通过建立基础词根表，以不同词根的组合作为某个业务字段的命名来保证字段名称的规范和统一性。这里的词根也包含专业名词。

示例：

|词根	|含义|  简写 |
|-------|--------|-------|
| advert | 广告 |  ad  |
| postition | 位置 | pos |
| id  | id |  |

广告位 id 就可以命名为 adpos_id。

#### 指标定义规范
指标一般分为原子指标和派生指标。指标命名可以基于以上的字段的命名规范由不同词根组合而来。指标定义规范一般包含命名，口径，类型（sum 还是 count distinct ），从属的业务过程，以上三点在加上时间周期和修饰词就构建成了派生指标。在 BI 层通常还会配置复合指标，比如 ctr/cvr 等。

#### 模型设计规范
模型分层
<img src="https://timemachine-blog.oss-cn-beijing.aliyuncs.com/img/%E5%88%86%E5%B1%82.png" width="60%" height="50%">
- ODS：原始数据层，存放原始数据，数据保持原貌不做处理。
- DW ：数据仓库层，是为企业所有级别的决策制定过程，提供所有类型数据支持的战略集合，是一个包含所有主题的通用集合。包含 DWD、DWS。
- DWD：明细数据层，存储的都是以事实表为主，该层的事实表又叫明细事实表。DWD 层做数据的标准化，为后续的处理提供干净、统一、标准的数据。在 DWD 层的操作：
	- 过滤，去除掉丢失关键信息的数据、去除格式错误的数据、去除无用字段。
	- 统一，打点数据不够规范，不同业务的打点逻辑可能不同，在 DWD 层做统一。如布尔类型，有用 0，1 数字标识，也有用 0，1 字符串标识，也有用 true，false 字符串标识别。如字符串空值有 "",也有 null。如日期有秒级时间戳，也有毫秒时间戳。
	- 映射，例如将字符串映射成枚举值。
	- 按照数据域划分。
- DWS：数据服务层，按照业务划分，在该层按照不同的维度聚合计算指标，生成字段比较多的宽表，用于提供后续的业务查询，OLAP分析，数据分发等。
- DIM：维表层，存储所有的维度信息。按照不同的维度主题划分。
- ADS：数据应用层，面向实际的数据需求，以 DWD 或者 DWS 层的数据为基础，组成的各种统计报表。

数据流向规范
<img src="https://timemachine-blog.oss-cn-beijing.aliyuncs.com/img/shucangliuxiang.png" width="60%" height="50%">

- 只有 dwd 和 dim 可以使用 ods 层数据。
- dwd 之间不能同层调用，原因是不能跨数据域调用。
- dws 之间可以互相调用，组合成不同数据域下的链路转化宽表。
- dim 从 dwd 事实表中获取或者从 ods 层直接获取，不能直接将 ods 层表作为 dim 使用。
- ads 层只能通过 dwd 和 dws 取数，并且要尽量避免直接从 dwd 取数，如果要取数的话，需要考虑是否可以建立 dws 宽表。
- 对于其他业务团队提供的 dwd 表，首先考虑建立 dws 表，再者同步成业务交集下的 dwd 事实表。

#### 模型命名规范
模型分层 + 业务板块 + 数据主题 + {可选的业务过程} + {可选的粒度} +  调度周期，比如 dwd_imp_ad_click_di

#### 表文档规范
在平台基建不完善时，可以考虑结合 confluence 来对表文档进行集中管理，但是比较麻烦，这里不太建议。个人感觉的 oneData 各种规范的保证其实是强依赖于平台工具的，比如阿里的 dataworks。

#### 模型设计
主要基于维度建模的思想来进行模型设计，主要考虑以下几个因素

- 易用性，大多数数仓表不仅仅要提供给上下游研发使用，分析师和运营也有取数需求，表模型的设计要尽量便于他人理解。
- 拓展性，由于业务迭代添加字段时不用对下游业务使用造成太大的扰动。
- 低成本，合理的字段冗余可以提高 sql 的性能，避免多余的 join 操作。这里的低成本并非是简单的低存储，更多是存储成本和查询性能的平衡。
- 高效性，良好的查询性能，通常依赖于合理的分区和索引来实现，存储方面的话就是数据的分布。


### 实施过程
阿里巴巴大数据之路第五章有对应的图，这里就不重新搞了，这里实施过程其实可以在抽象下，下面实践会介绍并举一些示例。

1. 业务需求调研。
2. 依据 oneData 的体系架构进行数据域划分，抽象业务过程和维度。
3. 明确规范定义
	- 指标规范（指标分层，是否要借助工具或者文档来进行指标的统一建立与管理）。
	- 命名规范（字段命名规范，词根表，维度修饰词文档的维护）。
	- 模型设计规范（模型分层，模型命名，数据流向等）
	- 码值维护。
4. 构建总线矩阵，以全局整体的视角来看每个业务过程所涉及到的维度。
5. 模型设计
	- 依据第二步抽象的维度和指标进行维表和事实表设计。
	- 模型评审，保障交付。

### 一些问题
之前看 oneData 时的一些问题，其实应该也不算问题，oneData 作为一个方法论，只是起到总纲的作用，不能教条主义，要结合本身的业务场景来灵活调整，最终形成适合自己的 onedata。
- 维度属性和修饰词的区别在哪里？既然已经作为修饰词了，那么就可以作为维度，为何还要区分成两个概念？
- 汇总表和事实表的区别在哪里？
只有汇总表会涉及到指标的概念，事实表仅仅是描述事件行为。
- 构建总线矩阵的意义在哪里？
- oneData 的核心思想是什么？
- 维表有没有必要进行合并，什么场景下合并？
要理解主从维表的概念
- ods 的维表为啥要同步到 dim 一份，仅仅是为了统一规范？
- 粒度和维度的区别在哪里？
粒度更偏向于描述事实的深度，比如小时粒度，天粒度，月粒度。而维度是描述事实的角度，更水平也更细。
- 针对前置业务板块用到了后续转化链路业务下的数据域中的表，是需要把后续链路业务板块划作一个数据域放到前置业务中去，还是做完全的业务隔离呢？
- 主题域和数据域的区别在哪里？
- 业务过程该怎么划分，要不要拆分到最细？这里分别对应的就是单事务事实表和多事务事实表。什么场景下该拆分到最细，什么场景下又该合并？
- dwd，dws 层原则上不允许跨数据域，如果要跨数据域该怎么办？是新建数据域还是通过视图的方式提供？
- oneDtata 整体的实施过程强依赖工具，尤其是规范定义部分，如果没有工具功能保证的话，不可避免的会出现规范定义问题，最常见的就是字段命名不统一。

### 实践
看了 oneData 一段时间后，其实非常的晦涩难懂，总感觉是虚无缥缈，另外这个东西的设计与重构的周期是非常长的，并且还要考虑中间业务需求的变动造成的已确定表模型的更改以及双跑过程中的队列资源。基于以上问题，对以上 oneData 的实施过程在做细分。

下面的内容都会基于广告投放下的广告请求业务过程来做举例。

#### 数据域及业务过程划分
上面已经介绍了数据域及业务过程的概念。对于涉及对个垂直业务单元的业务线来说，其涉及到的每个业务单元可以看做一个数据域，比如博主所做的 IMP ，就可以划分为广告投放，落地页，成单等等数据域。
这里以广告投放数据域为例，业务过程大致可以划分为内部与外部
- 内部，运营侧在后台对广告计划，单元，创意的创建。
- 外部，用户产生的广告请求，广告曝光，广告可见曝光，广告点击。


#### 数仓规划 

##### 构建总线矩阵
主要是明确该数据域下所涉及到的所有业务过程以及每个业务过程所涉及到的维度 
![](https://timemachine-blog.oss-cn-beijing.aliyuncs.com/img/zongxianjuzhen.png)

##### 明确指标
![](https://timemachine-blog.oss-cn-beijing.aliyuncs.com/img/mingquezhibiao.png)

##### 整体设计
![](https://timemachine-blog.oss-cn-beijing.aliyuncs.com/img/zhengtisheji.png)

#### 数据标准 

##### 定义字段标准 
根据规范定义中的词根表来设计该数据域下每个业务过程所涉及到的字段以及业务含义。

##### 定义枚举值
针对字段标准中字段，关联其对应的枚举值

##### 定义度量

#### 数据指标  

##### 定义原子指标

##### 定义修饰词

##### 定义时间周期

##### 构建派生指标

#### 模型设计


### 总结
OneData 仅仅是一个思想，或者说是一种做事的通用方法。我们不应囿于这个个概念，而是应该结合具体的业务场景去思考如何落地，在实践中归纳出适合自己业务的 'OneData'。这里其实我把它归纳成了五步，然后没一步都需要详细的业务调研和评审环节，甚至工具来保证其强规范性
- 数据域及业务过程划分
- 数仓规划
- 数据标准 
- 数据指标
- 模型设计
- 模型评审
- 资源预估











