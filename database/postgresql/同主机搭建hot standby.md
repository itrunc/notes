#Windows同一环境搭建hot standby

本文将记录如何在一台Windows机器上跑多个PostgreSQL实例，实现主从结构读写分离（运用replication stream）。请不要质疑这样做有什么意义，并非所有人都像壕们一样有那么多机器供他们玩耍。

* 主机操作系统：Windows 7
* 数据库：PostgreSQL 9.3，postgresql安装在`D:\PostgreSQL\`目录下
* master信息：
  * **HOST**: localhost 或 127.0.0.1
  * **PORT**: 5432
  * **DATADIR**: D:\PostgreSQL\data
* slave信息：
  * **HOST**: localhost 或 127.0.0.1 (与master相同)
  * **PORT**: 5431 (与master不同)
  * **DATADIR**: D:\PostgreSQL\data-slave1 (与master不同，而已在任意位置)

> 说明：PostgreSQL只需安装一次

##master端的操作

1. 创建一个用于流复制的用户
  ```sql
  CREATE USER repuser
    REPLICATION
    LOGIN
    CONNECTION LIMIT 3
    ENCRYPTED PASSWORD 'repuser';
  ```
2. 修改**pg_hba.conf**配置文件(该文件在data目录下)，添加以下一行：
  ```
  host    replication     repuser         127.0.0.1/32            md5
  ```
3. 修改**postgresql.conf**配置文件(该文件在data目录下)，确保打开这些参数并作如下类似配置：
  ```sh
  port = 5432
  wal_level = hot_standby
  max_wal_senders = 4
  archive_mode = on
  archive_command = 'copy "%p" "D:/PostgreSQL/archive/%f"'
  hot_standby = on
  wal_keep_segments = 64
  ```
4. 启动master数据库实例
  ```
  D:\PostgreSQL>bin\pg_ctl start -D data -l master.log
  正在启动服务器进程
  ```
4. 备份master
  
  用psql客户端连接数据库：
  ```
  D:\PostgreSQL>bin\psql -p5432 -Upostgres
  psql (9.3.1)
  输入 "help" 来获取帮助信息.
  
  postgres=# select pg_start_backup('itrunc.com');
   pg_start_backup
  -----------------
   0/19000028
  (1 行记录)
  ```
  手动将D:\PostgreSQL\data文件夹复制一份，并命名为data-slave1，然后结束备份：
  ```
  postgres=# select pg_stop_backup(), current_timestamp;
  NOTICE:  pg_stop_backup complete, all required WAL segments have been archived
   pg_stop_backup |            now
  ----------------+----------------------------
   0/190000F0     | 2014-11-21 13:37:38.226+08
  (1 行记录)
  ```
  退出psql客户端：
  ```
  postgres=# \q
  ```

##slave端的操作
1. 修改data-slave1目录（刚刚备份时复制出来的）
  
  进入data-slave1目录
  * 删除文件 postmaster.pid
  * 删除目录 pg_xlog 里的所有内容
2. 修改**postgresql.conf**配置文件，确保这些参数做如下类似配置：
  ```sh
  port = 5431 #由于是在同一台机，所以端口必须与master不同
  hot_standby = on
  ```
3. 从share目录（在postgresql根目录下）中拷贝文件`recovery.conf.sample`，粘贴到data-slave1中，并重命名为`recovery.conf`
4. 修改**recovery.conf**配置文件，确保打开这些参数并做如下类似配置：
  ```sh
  standby_mode = on
  trigger_file = 'D:\PostgreSQL\data\postgresql.trigger.5432'
  primary_conninfo = 'host=localhost port=5432 user=repuser password=repuser keepalives_idle=60'
  ```
  * trigger_file参数中`D:\PostgreSQL\data`是master的数据库目录，`5432`是master监听的端口号
  * primary_conninfo参数配置的是从slave连接master所需要的一些基本信息
5. 启动slave1
  ```
  D:\PostgreSQL>bin\pg_ctl start -D data-slave1 -l slave1.log
  正在启动服务器进程
  ```

##查看进程
以下进程树信息说明已有两个postgres实例在本机运行
```
postgres.exe    (6816)
    postgres.exe    (1532)
    postgres.exe    (5732)
    postgres.exe    (5236)
    postgres.exe    (7776)
    postgres.exe    (2700)
    postgres.exe    (6388)
    postgres.exe    (5692)
postgres.exe    (8468)
    postgres.exe    (2548)
    postgres.exe    (8980)
    postgres.exe    (8200)
    postgres.exe    (8600)
    postgres.exe    (8444)
```
上边进程信息显示可知slave比master少2个进程

##验证
1. 用psql登录slave，切换到learning数据库(已存在test表)，从test表查询数据，并尝试往test表插入数据
  ```
  D:\PostgreSQL>bin\psql -p5431 -Upostgres
  psql (9.3.1)
  输入 "help" 来获取帮助信息.
  
  postgres=# \c learning
  您现在已经连线到数据库 "learning",用户 "postgres".
  learning=# select * from test;
   id |  name
  ----+--------
    1 | mophee
    2 | itrunc
  (2 行记录)
  
  learning=# insert into test(name) values('itrunc.com');
  ERROR:  cannot execute INSERT in a read-only transaction
  ```
  由此可见，slave是只读的，无法对其中的表进行更新。
2. 开启另外一个cmd，用psql登录master，切换到learning数据库，向test表插入一条新的记录
  ```
  D:\PostgreSQL>bin\psql -p5432 -Upostgres
  psql (9.3.1)
  输入 "help" 来获取帮助信息.
  
  postgres=# \c learning
  您现在已经连线到数据库 "learning",用户 "postgres".
  learning=# select * from test;
   id |  name
  ----+--------
    1 | mophee
    2 | itrunc
  (2 行记录)
  
  learning=# insert into test(name) values('itrunc.com');
  INSERT 0 1
  learning=# select * from test;
   id |    name
  ----+------------
    1 | mophee
    2 | itrunc
    3 | itrunc.com
  (3 行记录)
  ```
  test表已经在master被更新了
3. 在slave查询test表
  ```
  learning=# \conninfo
  以用户 "postgres" 的身份，通过套接字"/tmp"在端口"5431"连接到数据库 "learning"
  learning=# select * from test;
   id |    name
  ----+------------
    1 | mophee
    2 | itrunc
    3 | itrunc.com
  (3 行记录)
  ```
  可见，slave也实时地更新了

##附录：数据库启动和关闭脚本文件

注：由于数据库文件放在PostgreSQL的根目录下，所以这些脚本文件也放在根目录下。读者可根据实际部署环境进行修改。

* master启动脚本：
  ```bash
  @set datadir=%CD%\data
  @set logfile=%CD%\master.log
  %CD%\bin\pg_ctl start -D %datadir% -l %logfile%
  ```
* master关闭脚本：
  ```bash
  @set datadir=%CD%\data
  @set logfile=%CD%\master.log
  %CD%\bin\pg_ctl stop -D %datadir% -l %logfile% --mode=fast
  ```
* slave启动脚本：
  ```bash
  @set datadir=%CD%\data-slave1
  @set logfile=%CD%\slave1.log
  %CD%\bin\pg_ctl start -D %datadir% -l %logfile%
  ```
* slave关闭脚本
  ```bash
  @set datadir=%CD%\data-slave1
  @set logfile=%CD%\slave1.log
  %CD%\bin\pg_ctl stop -D %datadir% -l %logfile% --mode=fast
  ```

##参考资料
>1. [postgresql的hot standby(replication stream)](http://my.oschina.net/Kenyon/blog/54967)
