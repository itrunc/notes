#Oracle口令文件

Oracle口令文件位于 $ORACLE_HOME/dbs(Linux) 或 $ORACLE_HOME/database(Windows)。

如果SID为orcl，则口令文件名为 orapworcl。口令文件内容如下：

```
[oracle@oracle11g ~]$ strings $ORACLE_HOME/dbs/orapworcl
]\[Z
ORACLE Remote Password file
INTERNAL
92FC8C4FD583B7E6
4BFA5CB43DC202BB
```

默认情况下只有sys用户拥有sysdba权限，拥有sysdba权限的用户可以在数据库实例未启动的情况下连接数据库。如果有用户被授予sysdba权限，则口令文件中就会添加该用户的口令

```
[oracle@oracle11g ~]$ sqlplus /nolog

SQL*Plus: Release 11.2.0.1.0 Production on Mon Apr 13 16:09:04 2015

Copyright (c) 1982, 2009, Oracle.  All rights reserved.

SQL> conn / as sysdba
Connected.
SQL> grant sysdba to system;

Grant succeeded.

SQL> exit
Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options
[oracle@oracle11g ~]$ strings $ORACLE_HOME/dbs/orapworcl
]\[Z
ORACLE Remote Password file
INTERNAL
92FC8C4FD583B7E6
4BFA5CB43DC202BB
SYSTEM
BEA528777BF39BAE
```

口令文件可使用 orapwd 进行重建，该命令的用法如下：

```
[oracle@oracle11g ~]$ orapwd
Usage: orapwd file=<fname> entries=<users> force=<y/n> ignorecase=<y/n> nosysdba=<y/n>

  where
    file - name of password file (required),
    password - password for SYS will be prompted if not specified at command line,
    entries - maximum number of distinct DBA (optional),
    force - whether to overwrite existing file (optional),
    ignorecase - passwords are case-insensitive (optional),
    nosysdba - whether to shut out the SYSDBA logon (optional Database Vault only).

  There must be no spaces around the equal-to (=) character.
```

