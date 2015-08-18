#db_files对于oracle使用内存的影响

db_files参数限制了数据库数据文件总的个数，datafiles数目达到db_files指定后数据库不能添加新的数据文件，如果需要修改要重新重启数据库

所以这个参数都会有一定的预留，但是如果预先设置太大的话会影响oracle内存的使用

下面采取极端的 200 vs 20000 来做一个简单的比较

首先我们来看其对SGA的影响

db_files=200

```
SQL> show sga

Total System Global Area  555559728 bytes
Fixed Size                   731952 bytes
Variable Size             385875968 bytes
Database Buffers          167772160 bytes
Redo Buffers                1179648 bytes
```
```
SQL> create table b as select * from v$sgastat;

Table created.
```

```
SQL> show parameter db_files

NAME       TYPE      VALUE
---------- --------- -------
db_files   integer   200
```

db_files=20000

```
Total System Global Area 1444753456 bytes
Fixed Size                   733232 bytes
Variable Size            1275068416 bytes
Database Buffers          167772160 bytes
Redo Buffers                1179648 bytes
Database mounted.
Database opened.
```

```
SQL> create table e as select * from v$sgastat;

Table created.
```

```
SQL> show parameter db_files

NAME       TYPE      VALUE
---------- --------- -------
db_files   integer   20000
```

可以看出shared pool部分20000的db_files比200的db_files多了848M，这个多出来的值不是固定的，和其他参数还有关系，如果在正式环境上会高出更多

我遇到过db_files参数设置为10000比设置为1000要使用2G空间的情况

上面我对v$sgastat做了两次snapshot,现在我们可以看看是哪个component占用了这些空间

```
SQL>  select b.pool,b.name,b.bytes before,e.bytes after,e.bytes-b.bytes delta from b,e
2   where b.pool=e.pool and b.name=e.name and b.bytes!=e.bytes order by delta desc;

POOL        NAME                           BEFORE      AFTER      DELTA
----------- -------------------------- ---------- ---------- ----------
shared pool free memory                 300344592  948654528  648309936  –　600M
shared pool Checkpoint queue              2053120  204805120  202752000  —  200M
shared pool FileOpenBlock                 7517528   16440360    8922832
shared pool enqueue                       1833832    4568752    2734920
shared pool enqueue resources              662048    3236424    2574376
shared pool KGK heap                         6904     640600     633696
shared pool fixed allocation callback         560        640         80
shared pool trigger inform                    344        216       -128
shared pool sim memory hea                1274744    1274040       -704
shared pool KQR M PO                       118832      11288    -107544
shared pool KQR L PO                       414720     235544    -179176
shared pool KGLS heap                      898344     390168    -508176
shared pool miscellaneous                30526568   29338032   -1188536
shared pool library cache                 4324488    2925224   -1399264
shared pool sql area                      5029320    1234712   -3794608

15 rows selected.
```

下面来看看对PGA的影响，PGA中有一部分内存空间是用来存放opened file descriptors，db_files参数设置越高，这部分预留空间越大

db_files=200

```
SQL> select min(value) from v$sesstat s,v$statname n
2   where s.statistic# = n.statistic# and
3  n.name = ‘session pga memory’
4  /

MIN(VALUE)
------------
118760
```

db_files=20000

```
SQL> select min(value) from v$sesstat s,v$statname n
2   where s.statistic# = n.statistic# and
3  n.name = ‘session pga memory’
4  /

MIN(VALUE)
-------------
1866088
```

如果按照1000个process计算的话，PGA的差距大约为1.6G

```
SQL>  select 1000*(1866088-118760)/power(1024,3) from dual;

1000*(1866088-118760)/POWER(1024,3)
------------------------------------
1.62732601
```

所以db_files不要预留太大，否则会大大影响到内存空间的使用

##原文连接

* [1] [db_files对于oracle使用内存的影响](http://www.dbafan.com/blog/?p=92)