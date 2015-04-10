#解决sqlplus连接oracle时乱码的问题

sqlplus是oracle数据库的一个客户端工具，在使用它连接oracle数据库时有时会出现乱码，原因是客户端与服务器端的字符集和编码不一致。

##服务器端的字符集编码

```
SQL> select * from nls_database_parameters where parameter like '%LANG%';

PARAMETER          VALUE
------------------ ------------
NLS_DATE_LANGUAGE  AMERICAN
NLS_LANGUAGE       AMERICAN


SQL> select * from nls_database_parameters where parameter like '%CHARACTERSET%';

PARAMETER               VALUE
----------------------- ------------
NLS_NCHAR_CHARACTERSET  AL16UTF16
NLS_CHARACTERSET        AL32UTF8
```

##客户端字符集编码

sqlplus使用shell环境变量指定的字符集编码，查看客户端的字符集编码：

```
[oracle@oracle12cR1 ~]$ env | grep LANG
NLS_LANG=AMERICAN_AMERICA.UTF8
LANG=en_US.UTF-8
```

可见目前客户端和服务器端的字符集编码一致，因此不会出现乱码。

如果两者不一致，那么可以在连接启动sqlplus之前，在shell执行以下命令：

```
export NLS_LANG=AMERICAN_AMERICA.UTF8
export LANG=en_US.UTF-8
```

要让以上命令在登录系统时就生效，就将它们添加到文件 ~/.bash_profile中。

```
[oracle@oracle12cR1 ~]$ vi ~/.bash_profile
[oracle@oracle12cR1 ~]$ source ~/.bash_profile
```