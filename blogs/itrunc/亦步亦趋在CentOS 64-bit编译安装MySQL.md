# 亦步亦趋在CentOS 64-bit编译安装MySQL

在CentOS中安装MySQL有三种方式：yum安装、rpm安装和编译安装。yum安装最便捷，但是所安装的mysql版本会相对比较低。rpm方式安装也相对便捷。编译安装最繁琐，如果非要将繁琐说是一项优点的话，那么它可以让你更了解mysql。

创建用户组：

```
[root@itrunc.com home]# groupadd mysql
[root@itrunc.com home]# groupadd dba
```

创建mysql用户并设定密码：

```
[root@itrunc.com home]# useradd -g mysql -G dba mysql
[root@itrunc.com home]# passwd mysql
```

下载安装包并解压缩后复制到安装目录/usr/local/mysql：

```
[root@itrunc.com home]# wget http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.15-linux-glibc2.5-x86_64.tar.gz
[root@itrunc.com home]# tar -zxvf mysql-5.6.15-linux-glibc2.5-x86_64.tar.gz
[root@itrunc.com home]# mv mysql-5.6.15-linux-glibc2.5-x86_64 /usr/local/mysql
```

由于我们在root下操作，所以需修改一下mysql安装目录的所有者：

```
[root@itrunc.com home]# chown -R mysql:mysql /usr/local/mysql
```

好的习惯是将mysql数据文件存放在安装目录以外的地方：

```
[root@itrunc.com home]# mkdir -p /opt/mysql/data
[root@itrunc.com home]# chown -R mysql:mysql /opt/mysql
```

将当前目录切换到/usr/local/mysql，并执行安装：

```
[root@itrunc.com home]# cd /usr/local/mysql
[root@itrunc.com mysql]# scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/opt/mysql/data --user=mysql
```

安装信息如下：

```
Installing MySQL system tables...2014-01-12 16:17:46 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2014-01-12 16:17:46 3676 [Note] InnoDB: The InnoDB memory heap is disabled
2014-01-12 16:17:46 3676 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2014-01-12 16:17:46 3676 [Note] InnoDB: Compressed tables use zlib 1.2.3
2014-01-12 16:17:46 3676 [Note] InnoDB: Using Linux native AIO
2014-01-12 16:17:46 3676 [Note] InnoDB: Using CPU crc32 instructions
2014-01-12 16:17:46 3676 [Note] InnoDB: Initializing buffer pool, size = 128.0M
2014-01-12 16:17:46 3676 [Note] InnoDB: Completed initialization of buffer pool
2014-01-12 16:17:47 3676 [Note] InnoDB: The first specified data file ./ibdata1 did not exist: a new database to be created!
2014-01-12 16:17:47 3676 [Note] InnoDB: Setting file ./ibdata1 size to 12 MB
2014-01-12 16:17:47 3676 [Note] InnoDB: Database physically writes the file full: wait...
2014-01-12 16:17:47 3676 [Note] InnoDB: Setting log file ./ib_logfile101 size to 48 MB
2014-01-12 16:17:52 3676 [Note] InnoDB: Setting log file ./ib_logfile1 size to 48 MB
2014-01-12 16:17:54 3676 [Note] InnoDB: Renaming log file ./ib_logfile101 to ./ib_logfile0
2014-01-12 16:17:54 3676 [Warning] InnoDB: New log files created, LSN=45781
2014-01-12 16:17:54 3676 [Note] InnoDB: Doublewrite buffer not found: creating new
2014-01-12 16:17:54 3676 [Note] InnoDB: Doublewrite buffer created
2014-01-12 16:17:54 3676 [Note] InnoDB: 128 rollback segment(s) are active.
2014-01-12 16:17:54 3676 [Warning] InnoDB: Creating foreign key constraint system tables.
2014-01-12 16:17:54 3676 [Note] InnoDB: Foreign key constraint system tables created
2014-01-12 16:17:54 3676 [Note] InnoDB: Creating tablespace and datafile system tables.
2014-01-12 16:17:54 3676 [Note] InnoDB: Tablespace and datafile system tables created.
2014-01-12 16:17:54 3676 [Note] InnoDB: Waiting for purge to start
2014-01-12 16:17:54 3676 [Note] InnoDB: 5.6.15 started; log sequence number 0
2014-01-12 16:17:55 3676 [Note] Binlog end
2014-01-12 16:17:55 3676 [Note] InnoDB: FTS optimize thread exiting.
2014-01-12 16:17:55 3676 [Note] InnoDB: Starting shutdown...
2014-01-12 16:17:56 3676 [Note] InnoDB: Shutdown completed; log sequence number 1625977
OK
 
Filling help tables...2014-01-12 16:17:56 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2014-01-12 16:17:56 3701 [Note] InnoDB: The InnoDB memory heap is disabled
2014-01-12 16:17:56 3701 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2014-01-12 16:17:56 3701 [Note] InnoDB: Compressed tables use zlib 1.2.3
2014-01-12 16:17:56 3701 [Note] InnoDB: Using Linux native AIO
2014-01-12 16:17:56 3701 [Note] InnoDB: Using CPU crc32 instructions
2014-01-12 16:17:56 3701 [Note] InnoDB: Initializing buffer pool, size = 128.0M
2014-01-12 16:17:56 3701 [Note] InnoDB: Completed initialization of buffer pool
2014-01-12 16:17:56 3701 [Note] InnoDB: Highest supported file format is Barracuda.
2014-01-12 16:17:56 3701 [Note] InnoDB: 128 rollback segment(s) are active.
2014-01-12 16:17:56 3701 [Note] InnoDB: Waiting for purge to start
2014-01-12 16:17:57 3701 [Note] InnoDB: 5.6.15 started; log sequence number 1625977
2014-01-12 16:17:57 3701 [Note] Binlog end
2014-01-12 16:17:57 3701 [Note] InnoDB: FTS optimize thread exiting.
2014-01-12 16:17:57 3701 [Note] InnoDB: Starting shutdown...
2014-01-12 16:17:58 3701 [Note] InnoDB: Shutdown completed; log sequence number 1625987
OK
 
To start mysqld at boot time you have to copy
support-files/mysql.server to the right place for your system
 
PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !
To do so, start the server, then issue the following commands:
 
  /usr/local/mysql/bin/mysqladmin -u root password 'new-password'
  /usr/local/mysql/bin/mysqladmin -u root -h mophee password 'new-password'
 
Alternatively you can run:
 
  /usr/local/mysql/bin/mysql_secure_installation
 
which will also give you the option of removing the test
databases and anonymous user created by default.  This is
strongly recommended for production servers.
 
See the manual for more instructions.
 
You can start the MySQL daemon with:
 
  cd . ; /usr/local/mysql/bin/mysqld_safe &
 
You can test the MySQL daemon with mysql-test-run.pl
 
  cd mysql-test ; perl mysql-test-run.pl
 
Please report any problems with the ./bin/mysqlbug script!
 
The latest information about MySQL is available on the web at
 
http://www.mysql.com
 
Support MySQL by buying support/licenses at http://shop.mysql.com
 
New default config file was created as /usr/local/mysql/my.cnf and
will be used by default by the server when you start it.
You may edit this file to change server settings
```

安装完毕，默认在安装目录下创建配置文件my.cnf，该文件是support-files目录下默认配置文件的副本。修改my.cnf文件，将其中部分参数的注释去掉，并设定相关的值：

```
[root@itrunc.com mysql]# vi my.cnf
innodb_buffer_pool_size = 128M
basedir = /usr/local/mysql
datadir = /opt/mysql/data
port = 3306
socket = /tmp/mysql.sock
sort_buffer_size = 2M
read_rnd_buffer_size = 2M
```

mysql服务脚本在support-files目录下可以找到，将它复制到/etc/init.d/目录下并注册成为系统服务：

```
[root@itrunc.com mysql]# cp support-files/mysql.server /etc/init.d/mysql
[root@itrunc.com mysql]# chkconfig | grep mysql
[root@itrunc.com mysql]# chkconfig --add mysql
[root@itrunc.com mysql]# chkconfig | grep mysql
mysql           0:off   1:off   2:on    3:on    4:on    5:on    6:off
[root@itrunc.com mysql]# chkconfig mysql off
[root@itrunc.com mysql]# chkconfig | grep mysql
mysql           0:off   1:off   2:off   3:off   4:off   5:off   6:off
```

此时可以通过如下方式启动mysql服务：

```
[root@itrunc.com mysql]# service mysql start
Starting MySQL........................                     [  OK  ]
```

初步安装完成，但root还是空密码，需为之设置密码：

```
[root@itrunc.com mysql]# bin/mysqladmin -u root password '123456'
```

在/usr/local/bin/下建立/usr/local/mysql/bin/mysql的连接，则以后无需敲一大串绝对路径即可登录mysql：

```
[root@itrunc.com mysql]# ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql
[root@itrunc.com mysql]# ll /usr/local/bin | grep mysql
lrwxrwxrwx 1 root   root       26 Jan 12 16:28 mysql -> /usr/local/mysql/bin/mysql
```

登录测试一下：

```
[root@itrunc.com mysql]# mysql -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.6.15 MySQL Community Server (GPL)
 
Copyright (c) 2000, 2013, Oracle and/or its affiliates. All rights reserved.
 
Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.
 
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
 
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| test               |
+--------------------+
4 rows in set (0.01 sec)
```

大功告成，其实真的很简单。