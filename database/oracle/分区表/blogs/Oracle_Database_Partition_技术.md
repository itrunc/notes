#Oracle Database Partition 技术 

##Partition介绍

分区就是将一个非常大的 table 或者 index 按照某一列的值，分解为更小的，易于管理的逻辑片段---分区。将表或者索引分区不会影响SQL语句以及DML语句，就和使用非分区表一样，每个分区拥有自己的segment，因为，DDL能够将比较大的任务分解为更小的颗粒。分区表只有定义信息，只有每个存放数据的分区才有各自的segment。

就好象拥有多个相同列名，列类型的一个大的视图。

##收益

使用分区功能，可以提供的收益，可以从下面几个方面阐述：

###性能

可以减少检索数据的总量，因为拥有partition pruning 以及partition-wise joins。

* **partition pruning**：当谓词中（连接条件）带有partition key的时候，OracleDatabase可以自动的将不需要的partition裁剪掉，不需检索额外的partition 。
* **partition-wise joins**：两个表做join的时候，partitionkey 作为连接条件，OracleDatabase可以将连接操作分成多个单表和每个partition的join piece。对于单线程来说，每次join的工作量小了，可以减少系统的开销。而对于多线程来说，每个join piece 都可以使用多线程，可以加快检索时间（但是消耗更多的cpu）。

###管理

使用分区技术，可以将管理维护大表或者索引的操作，分成多个维护片段，可以更灵活的管理和维护这些schema object。举个具体的例子来说，这里有一个装有重要文件的重达100公斤的箱子，你需要将它搬到办公室去，这是非常累的，甚至是无法达成的。但是如果使用了分区技术，等于将100公斤的箱子10等分，这时候，就可以每次搬一个小箱子即可。

###可用性

因为分区表中的每个分区在物理层面上都是隔离的------每个分区拥有自己的segment。所以当其中的一个分区不可用的时候，不会影响另外的分区。
 
##Partition 分类

Partition可以简单分为范围、哈希、列表三种方式。以下说明了每种分区方式的适用场景。

###Range Partitioning 适用场景

* 表中的数据经常被执行范围扫描，比如说订单时间。这个时候使用Range Partitioning OracleDatabase可以提供Partition pruing 功能，大大减少了查询时间。
* 维护定期清理的数据，比如说，应用需求，为了保证效率，只要求12个月内的在线数据。如果使用了Range分区，可以在每个月数据来的时候使用分区交换的功能，将新的数据加载到分区表中，然后直接将最老的那个月的数据删除，或者归档。分区使用的是多个segment，所以这些操作都是非常有效率的。如果单表，那么可能需要dml语句，查询后再删除数据，性能非常低下，备份操作也是如此。如果使用Range分区，那么可能只需要一个ddl语句即可。
* 维护大表数据。一个非常大的表数据的备份，恢复，消耗都是非常巨大的。但是如果使用Range分区，按照时间维护数据的性能将会有很大的提升。比如说备份操作，假设使用数据泵来备份某一个月份的数据，如果是非分区表，需要使用查询语句。但是如果使用Range分区，则可以省略掉查询这部分的操作，保证了效率。

Range Partitioning 比较适用时间列，当然也有其他的适用场景，比如说那些连续的Column Value映射的行有特殊意义的，人的年龄、商品价位等。

11g开始，支持一种新的Range Partition方式，Interval partition，它可以根据选项自动创建需要的分区。

###List Partitioning适用场景

相对于Range Partition ，适合分散的Column Value 映射的行有特殊意义的情况。比如说统计国内数据，可以使用区域来创建分区。这样可以在加载或者统计区域数据的时候更加有效率。

 
###Hash Partitioning适用场景

这个分区比较适合平均I/O的场景。比如说，有一个大表，经常被访问，那么大表所在的表空间上面的I/O操作将非常频繁，这个时候可以将Hash Partition 放在不同的表空间上（表空间在不同的物理磁盘上），平均每个磁盘上面的I/O负载。防止单一磁盘I/O负载过高的情况。（Hash partition 也支持partition pruing ，但这无疑是没有意义的）

##原文链接

* [1] [Oracle Database Partition 技术](http://blog.csdn.net/renfengjun/article/details/8301361)