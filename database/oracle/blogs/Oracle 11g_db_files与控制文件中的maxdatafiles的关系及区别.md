#Oracle 11g db_files 与 控制文件中的 maxdatafiles 的关系及区别

当使用CREATE DATABASE命令或CREATE CONTROFILE命令，MAXDATAFILES参数决定了控制文件中关于数据文件的大小尺寸——对控制文件的大小也有影响。但是，如果添加一个数据文件时，其编号已经超出了MAXDATAFILES的设定值，但是小于或等于DB_FILES的设定值，控制文件会自动扩展以满足容纳更多的数据文件信息。

有人测试过，得出如下结论： 如果 db_files 足够，每当超过控制文件中的 maxdatafiles，maxdatafiles会翻倍增加(动态增加)。有兴趣可以自己测试一下。 

假设，db_files = 600 ，通过trace查看控制文件中的 maxdatafiles =500 ，当数据文件增加到 501个的时候，maxdatafiles 会自动扩展到 500 *２= 1000 ,  我们增加文件数到 601的时候， 系统会因为 db_files=600而报错 ORA-00059: 超过 DB_FILES 的最大值。 我们需要增加 db_files 参数值，不能动态更改，需要重新启动数据库生效。 比如增加到 db_files = 4096, 那么当数据文件增加到 1001 时， 控制文件中的 maxdatafiles 会自动翻倍，增加到 1000 * 2 = 2000,  以此类推， 文件增加到 2001 时，没有超过db_file 4096 , 不会报错，但是控制文件中的 maxdatafiles 会翻倍，增加到 2000*2=4000 个 。

##原文连接

* [1] [Oracle 11g db_files 与 控制文件中的 maxdatafiles 的关系及区别](http://blog.itpub.net/35489/viewspace-1350873)