---
title: 常见的SQL优化
categories: BigData
tags: MySQL
abbrlink: 5c09ddf8
date: 2020-12-09 15:48:04
---

### 前言
关系型数据库中常见的 SQL 优化。挺久前写过的笔记了，应该借鉴了挺多文章，侵删。
<!--more-->

### 常见的 SQL 优化
#### 操作符 <> 优化
通常 <> 操作符无法使用索引，如果 amount 为100的订单极少，这种数据分布严重不均的情况下，有可能使用索引。
```sql
select id from orders where amount != 100;
```

鉴于这种不确定性，采用 union 聚合搜索结果。
```sql
(select id from orders where amount > 100)
 union all
(select id from orders where amount < 100 and amount > 0)
```

#### or 优化
在Innodb引擎下or无法使用组合索引
```sql
select id, product_name from orders where mobile_no = '13421800407' or user_id = 100;
```
OR 无法命中 mobile_no + user_id 的组合索引，可采用 union

```sql
(select id, product_name from orders where mobile_no = '13421800407')
union
(select id, product_name from orders where user_id = 100)
```

#### in 优化
in 适合主表大子表小，exists 适合主表小子表大。

```sql
select id from orders where user_id in (select id from user where level = 'VIP');
select id from orders where user_id in (1, 2, 3);
```

有时可以用 join 来替代 in 操作。查询条件是连续的话可以用 between 代替 in
```sql
select o.id from orders o left join user u on o.user_id = u.id where level = 'VIP'
select id from orders where user_id between 1 and 3;
```

#### 不做列运算
通常在 where 子句里 = 左边进行表达式或者函数操作会导致无法正确使用索引
```sql
select id from orders where id / 2 = 4;
select name from orders where substring(name, 1, 3) = 'SQL';
```
可以改写成如下格式
```sql
select id from orders where id = 4 * 2;
select name from orders where name like 'SQL%';
```
#### like 优化
下面这样写在 description 建立索引的情况下并不会命中索引
```sql
select description from order where description like '%keyword%';
```
改写成如下
```sql
select description from order where description like 'keyword%';
```
#### 进行 null 值判断
直接判断 null 值 会导致引擎放弃使用索引
```sql
select name from orders where name is null;
```
可以为 null 值填充上有意义的默认值之后在进行过滤判断
```sql
select name from orders where name = 0;
```
#### limit 优化
limit 查询起始值越大查询越慢
```sql
select * from orders limit 1000000, 10;
```
缩小 limit 的查询范围来进行优化
```sql
select * from orders where id > (select id from orders order by id desc limit 1000000,1) order by id desc limit 0,10
```
#### 强制使用索引

```sql
select name from orders with index(索引名) from orders;
```

### 实践

#### 问题
腾讯 DBBrain 上的参赛题。现有 order，order_item 两张数据表。需要优化 select.sql 和 update.sql  中的 sql 语句来应对模拟访问造成的数据库压力等问题。在本地的话，就是优化一下 sql 的执行实践就可以了。

[数据源下载](https://pan.baidu.com/s/1J08immFGH5ewjoILKEH9_g) 提取密码：qq28
```sql
order 表

CREATE TABLE `order` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `creator` varchar(24) NOT NULL,
  `price` varchar(64) NOT NULL,
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

order_item 表

CREATE TABLE `order_item` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `parent` bigint(20) NOT NULL,
  `status` int(11) NOT NULL,
  `type` varchar(12) NOT NULL DEFAULT '0',
  `quantity` int(11) NOT NULL DEFAULT '1',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```
select.sql，执行用时 2.19 秒

```sql
SELECT *
FROM   `order` o
       INNER JOIN order_item i ON i.parent = o.id
ORDER  BY o.status ASC,
          i.update_time DESC
LIMIT  0, 20
```

update.sql，执行用时比较长，在本地运行直接卡住了

```sql
update `order` set
create_time = now()
where id in (
    select parent from order_item where type = 2
)
```


#### 解决方案
update.sql， type 是 varchar 类型，而 where 子句中 type = 2，类型不匹配。对 type，parent 字段上建立组合索引，将 in 子查询改为 join（这里的数据量不是很大）

```sql
alter table `order` add index idx_1(type, parent);

update `order` o inner join (
   select type, parent from `order_item` where type = '2' group by type, parent
) i on o.id = i.parent set create_time = now();
```
select.sql

```sql
SELECT o.*,i.*
FROM   (
         (SELECT o.id, i.id item_id
          FROM   `order` o
          INNER JOIN order_item i ON i.parent =o.id
          WHERE  o.status = 0
          ORDER  BY i.update_time DESC
          LIMIT  0, 20
         )
          UNION ALL
         (SELECT o.id, i.id item_id FROM `order` o
           INNER JOIN order_item i ON i.parent =o.id
           WHERE  o.status = 1
           ORDER  BY i.update_time DESC
           LIMIT  0, 20
         )
        ) tmp
       INNER JOIN `order` o ON tmp.id = o.id
       INNER JOIN order_item i ON tmp.item_id =i.id
ORDER  BY o.status ASC,
          i.update_time DESC
LIMIT  0, 20
```

### 阅读
#### Blog
[How do database indexes work? And, how do indexes help?](https://www.programmerinterview.com/database-sql/what-is-an-index/)
