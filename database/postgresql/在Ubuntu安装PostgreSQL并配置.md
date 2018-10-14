# 一、安装

### 1、安装

使用如下命令，会自动安装最新版，这里为9.5

```bash
sudo apt-get install postgresql
```

安装完成后，默认会：

（1）创建名为"postgres"的Linux用户

（2）创建名为"postgres"、不带密码的默认数据库账号作为数据库管理员

（3）创建名为"postgres"的表

安装完成后的一些默认信息如下：

```
config /etc/postgresql/9.5/main 
data /var/lib/postgresql/9.5/main 
locale en_US.UTF-8 
socket /var/run/postgresql 
port 5432
```

### 2、psql命令

安装完后会有PostgreSQL的客户端psql，通过 `sudo -u postgres psql` 进入，提示符变成： `postgres=#`

在这里可用执行SQL语句和psql的基本命令。可用的基本命令如下：

```
\password：设置密码
\q：退出
\h：查看SQL命令的解释，比如\h select。
\?：查看psql命令列表。
\l：列出所有数据库。
\c [database_name]：连接其他数据库。
\d：列出当前数据库的所有表格。
\d [table_name]：列出某一张表格的结构。
\du：列出所有用户。
\e：打开文本编辑器。
\conninfo：列出当前数据库和连接的信息。
```
 
# 二、修改数据库默认账号的密码

### 1、登录

使用psql命令登录数据库的命令为：

```bash
psql -U dbuser -d exampledb -h 127.0.0.1 -p 5432
```

上面命令的参数含义如下：-U指定用户，-d指定数据库，-h指定服务器，-p指定端口。

输入上面命令以后，系统会提示输入dbuser用户的密码。

psql命令存在简写形式：

如果当前Linux系统用户，同时也是PostgreSQL用户，则可以省略用户名（-U参数的部分）

如果PostgreSQL内部还存在与当前系统用户同名的数据库，则数据库名也可以省略。

### 2、修改默认管理员账号的密码

以Linux用户"postgres"的身份（此时只有该用户有psql命令）执行psql客户端，进入该客户端的提示符界面（这里系统用户名、数据库用户名、数据库名都为postgres，故可采用简写形式）

```bash
sudo -u postgres psql
```

```bash
postgres=# alter user postgres with password '123456';
```

这样，管理员"postgres"的密码就为"123456"。

退出psql客户端命令：\q

若要删除该管理员的密码，则可用命令：`sudo -u postgres psql -d postgres`

# 三、修改Linux用户的密码

这个其实与安装postgresql关系不大。

以Linux用户"postgres"为例，对其运行passwd命令：

```
zsm@ubuntu:/etc/postgresql/9.5/main$ sudo -u postgres passwd //也可以 sudo passwd postgres
Changing password for postgres.
(current) UNIX password: 
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
```

# 四、配置数据库以允许远程连接访问

安装完成后，默认只能本地才能连接数据库，其他机子访问不了，需要进行配置。（以下示例开放了最大连接权限，实际配置根据你的需要而定）

### 1、修改监听地址，并启用密码验证

```bash
sudo gedit /etc/postgresql/9.5/main/postgresql.conf 
```

将 `#listen_addresses = 'localhost'` 的注释去掉并改为 `listen_addresses = '*'`

将 `#password_encryption = on` 的注释去掉

### 2、修改可访问用户的IP段

```bash
sudo gedit /etc/postgresql/9.5/main/pg_hba.conf 
```

在文件末尾添加： host all all 0.0.0.0 0.0.0.0 md5 ，表示允许任何IP连接

### 3、重启数据库

```bash
sudo /etc/init.d/postgresql restart
```

### 4、5432端口的防火墙配置

```bash
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 5432 -j ACCEPT
```

# 五、添加新用户和新数据库

### 法一：使用PostgreSQL客户端psql

运行系统用户"postgres"的psql命令，进入客户端：

```bash
sudo -u postgres psql
```

创建用户"xiaozhang"并设置密码：

```
postgres=# create user xiaozhang with password '123456';
```

创建数据库exampledb，所有者为xiaozhang：

```
postgres=# create database exampledb owner xiaozhang;
```

将exampledb数据库的所有权限赋予xiaozhang，否则xiaozhang只能登录psql，没有任何数据库操作权限：

```
grant all privileges on database exampledb to xiaozhang;
```

### 法二：使用shell命令行

安装PostgreSQL后提供了createuser和createdb命令行程序。

首先创建数据库用户"xiaozhang1"，并指定为超级用户：

```bash
sudo -u postgres createuser --superuser xiaozhang1;
```

接着登录psql控制台设置其密码后退出：

```
zsm@ubuntu:~$ sudo -u postgres psql
psql (9.5.3)
Type "help" for help.

postgres=# \password xiaozhang1;
Enter new password: 
Enter it again: 
postgres=# \q
```

然后在shell命令行下创建数据库并指定所有者：

```bash
sudo -u postgres createdb -O xiaozhang1 exampledb1;
```

### 法三：使用paadmin3以管理员连接数据库后创建
 
经过法一、法二操作后，执行  postgres=# \du  得到用户列表

执行 postgres=# \l 得到数据库列表

若要删除用户（如删除xiaozhang）可先 `postgres=# drop database example;` 再 `postgres=# drop user xiaozhang;` 。

将某用户改为超级管理员： `alter user xiaozhang with superuser; `

# 六、基本数据库操作命令

```SQL
# 创建新表 
CREATE TABLE user_tbl(name VARCHAR(20), signup_date DATE);
# 插入数据 
INSERT INTO user_tbl(name, signup_date) VALUES('张三', '2013-12-22');
# 选择记录 
SELECT * FROM user_tbl;
# 更新数据 
UPDATE user_tbl set name = '李四' WHERE name = '张三';
# 删除记录 
DELETE FROM user_tbl WHERE name = '李四' ;
# 添加栏位 
ALTER TABLE user_tbl ADD email VARCHAR(40);
# 更新结构 
ALTER TABLE user_tbl ALTER COLUMN signup_date SET NOT NULL;
# 更名栏位 
ALTER TABLE user_tbl RENAME COLUMN signup_date TO signup;
# 删除栏位 
ALTER TABLE user_tbl DROP COLUMN email;
# 表格更名 
ALTER TABLE user_tbl RENAME TO backup_tbl;
# 删除表格 
DROP TABLE IF EXISTS backup_tbl;
```

postgis相关：

安装postgis扩展： create extension postgis 

使用示例：

```sql
CREATE TABLE cities ( id int4, name varchar(50) );
select AddGeometryColumn('cities','pt',-1,'GEOMETRY',2);
SELECT * from cities;
INSERT INTO cities (id, pt, name) VALUES (1,ST_GeomFromText('POINT(-0.1257 51.508)',4326),'北京');
INSERT INTO cities (id, pt, name) VALUES (2,ST_GeomFromText('POINT(-81.233 42.983)',4326),'天津');
INSERT INTO cities (id, pt, name) VALUES (3,ST_GeomFromText('POINT(27.91162491 -33.01529)',4326),'河北');
```
