#修改初始化参数db_files

创建大表，对表进行较多分区。由于每个分区都使用独立的表空间，导致数据文件数目超出范围。

```
Error report -
SQL Error: ORA-00059: maximum number of DB_FILES exceeded
00059. 00000 -  "maximum number of DB_FILES exceeded"
*Cause:    The value of the DB_FILES initialization parameter was exceeded.
*Action:   Increase the value of the DB_FILES parameter and warm start.
```

默认情况下，db_files=200

```
SQL> show parameter db_files

NAME                                 TYPE        VALUE
------------------------------------ ----------- -----------
db_files                             integer     200
```

使用以下命令将 db_files 参数改大。修改 db_files 之后必须重启数据库。

```
SQL> alter system set db_files=2000 scope=both;
alter system set db_files=2000 scope=both
                 *
ERROR at line 1:
ORA-02095: specified initialization parameter cannot be modified


SQL> alter system set db_files=2000 scope=spfile;

System altered.

SQL> shutdown immediate
Database closed.
Database dismounted.
ORACLE instance shut down.
```

重启数据库之后，查看 db_files 大小

```
SQL> show parameter db_files

NAME                                 TYPE        VALUE
------------------------------------ ----------- --------------
db_files                             integer     2000
```
