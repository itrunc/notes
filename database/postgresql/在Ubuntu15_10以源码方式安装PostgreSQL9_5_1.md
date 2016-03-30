#在Ubuntu 15.10以源码方式安装PostgreSQL 9.5.1

下载PostgreSQL[源码包](http://www.postgresql.org/ftp/source/)，解压缩并进入解压后的目录

```bash
tar -xvf postgresql-9.5.1.tar.bz2
cd postgresql-9.5.1
```

##安装依赖程序

```bash
sudo apt-get install systemtap-sdt-dev libreadline6-dev zlib1g-dev libssl-dev libpam-dev libxml2-dev libxslt-dev tcl8.6-dev libperl-dev libpython2.7-dev
```

以下configure打开的选项将依赖这些程序。如果在configure时未找到这些程序包则会抛出错误而中止。当遇到程序未找到时，可执行类似以下的命令查找相关程序

```
//以readline为例
ldconfig -p | grep readline	
    libreadline.so.6 (libc6,x86-64) => /lib/x86_64-linux-gnu/libreadline.so.6
	libguilereadline-v-18.so.18 (libc6,x86-64) => /usr/lib/x86_64-linux-gnu/libguilereadline-v-18.so.18
	libguilereadline-v-18.so (libc6,x86-64) => /usr/lib/x86_64-linux-gnu/libguilereadline-v-18.so
```

##Configure source tree

PostgreSQL将被安装在/opt/pgsql9.5.1中，并启用端口号5432。

```bash
./configure --prefix=/opt/pgsql9.5.1 --with-pgport=5432 --with-perl --with-tcl --with-tclconfig=/usr/lib/tcl8.6 --with-python --with-openssl --with-pam --without-ldap --with-libxml --with-libxslt --enable-thread-safety --with-wal-blocksize=16 --with-blocksize=16 --enable-dtrace --enable-debug
```

值得说明的是，如果启用Tcl `--with-tcl`，则需要使用选项 `--with-tclconfig=/usr/lib/tcl8.6` 告诉程序Tcl的安装路径，否则会报错 `configure: error: file 'tclConfig.sh' is required for Tcl`

Ubuntu 15.10默认安装的是tcl8.6，因此使用以上选项值。

##编译并安装

全部编译

```bash
make world
```

安装

```bash
sudo make install-world
```

安装后创建链接

```bash
sudo ln -s /opt/pgsql9.5.1 /opt/pgsql
```

##创建postgres用户

```bash
sudo adduser postgres
```

成功创建postgres系统用户后，以其身份登录，并配置环境变量

```bash
su - postgres

vi ~/.profile
```

在~/.profile中添加一下内容：

```
export PGPORT=5432
export PGDATA=/pgdata/pg_root
export LANG=en_US.utf8
export PGHOME=/opt/pgsql
export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
export PATH=$PGHOME/bin:$PATH
export MANPATH=$PGHOME/share/man:$MANPATH
export PGUSER=postgres
export PGHOST=$PGDATA
export PGDATABASE=postgres
```

保存后，退出postgres

##创建相关目录

根据以上设置的环境变量PGDATA，创建目录，并修改所有者为posgres

```bash
sudo mkdir -p /pgdata/pg_root
sudo chown -R postgres:postgres /pgdata
```

##初始化数据库

以postgres用户身份登录，并初始化数据库

```bash
su - postgres
initdb -D $PGDATA -E UTF8 --locale=C -U postgres -W
```

完成初始化后，退出postgres，以下将在启动数据库之前对系统参数和数据库参数作一些设置

##修改sysctl

```bash
sudo vi /etc/sysctl.conf
```

添加以下内容

```
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
kernel.shmmni = 4096
kernel.sem = 50100 64128000 50100 1280
fs.file-max = 7672460
net.ipv4.ip_local_port_range = 9000 65000
net.core.rmem_default = 1048576
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
```

执行以下命令使以上设置生效

```bash
sudo sysctl -p
```

##修改limits

```bash
sudo vi /etc/security/limits.conf
```

添加以下内容

```
* soft nofile 131072
* hard nofile 131072
* soft nproc 131072
* hard nproc 131072
* soft core unlimited
* hard core unlimited
* soft memlock 50000000
* hard memlock 50000000
```

##修改pg_hba

```bash
vi /pgdata/pg_root/pg_hba.conf
```

由于没有IPV6，所以将以下一行注释掉

```
#host    all             all             ::1/128                 trust
```

可进一步配置其它内容

##修改数据库参数

```bash
vi /pgdata/pg_root/postgresql.conf
```

查找以下参数，根据实际情况设置其值

```
listen_addresses = '0.0.0.0'
port = 5432
superuser_reserved_connections = 13
unix_socket_directories = '.'
unix_socket_permissions = 0700
tcp_keepalives_idle = 60
tcp_keepalives_interval = 10
tcp_keepalives_count = 10 
shared_buffers = 512MB
vacuum_cost_delay = 10
bgwriter_delay = 10ms
wal_writer_delay = 10ms
log_destination = 'csvlog'
logging_collector = on 
log_directory = 'pg_log' 
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_file_mode = 0600
log_truncate_on_rotation = on
log_rotation_age = 1d
log_rotation_size = 10MB
log_checkpoints = on
log_connections = on
log_disconnections = on
log_error_verbosity = verbose
```

##启动数据库

```bash
pg_ctl start
```

```
ps aux | grep postgres

postgres  73042  0.0  0.8 638376 34980 pts/2    S    18:20   0:00 /opt/pgsql9.5.1/bin/postgres
postgres  73043  0.0  0.0  81204  3180 ?        Ss   18:20   0:00 postgres: logger process    
postgres  73045  0.0  0.0 638376  3900 ?        Ss   18:20   0:00 postgres: checkpointer process  
postgres  73046  0.4  0.1 638376  6740 ?        Ss   18:20   0:01 postgres: writer process    
postgres  73047  0.0  0.0 638376  3900 ?        Ss   18:20   0:00 postgres: wal writer process  
postgres  73048  0.0  0.1 638780  6568 ?        Ss   18:20   0:00 postgres: autovacuum launcher process  
postgres  73049  0.0  0.1  83296  4140 ?        Ss   18:20   0:00 postgres: stats collector process 
```

##连接数据库

由于环境变量和数据库参数已经配置好，所以可以使用以下命令连接数据库：

```
psql
```

或者可以使用以下命令，连接特定的数据库：

```
psql -h 127.0.0.1 -p 5432 -U postgres postgres
```

##附：源码安装pgadmin3-1.22.1

下载最新的pgAdmin3源码包：http://www.postgresql.org/ftp/pgadmin3/release/

这里下载v1.22.1：https://ftp.postgresql.org/pub/pgadmin3/release/v1.22.1/src/pgadmin3-1.22.1.tar.gz

安装依赖包：

```sh
sudo apt-get install libwxgtk2.8-dev wx-common libpq-dev
```

配置，指定prefix和pgsql安装目录

```sh
./configure --prefix=/opt/pgadmin3-1.22.1 --with-pgsql=/opt/pgsql
```

安装

```sh
make all
make install
```
