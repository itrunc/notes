# 亦步亦趋在CentOS 64-bit下编译安装php

在安装php之前先确保已经安装GD库，如果未安装，则可使用yum方式快捷安装GD：

```
[root@mophee home]# yum install gd
```

下载安装包并解压后进入安装目录：

```
[root@mophee home]# wget http://cn2.php.net/get/php-5.5.8.tar.gz/from/this/mirror
[root@mophee home]# tar -zxvf php-5.5.8.tar.gz 
[root@mophee home]# cd php-5.5.8
```

生成Makefile，最主要的是指定安装目录为/opt/php和启用enable-fpm：

```
[root@mophee php-5.5.8]# ./configure --prefix=/opt/php --enable-fpm --with-mysql=/usr/local/mysql --enable-zip --enable-mbstring --enable-pdo --enable-exif --enable-xml --with-libxml-dir --with-curl --with-openssl --with-mysqli --with-zlib --with-gd --with-pdo-mysql=/usr/local/mysql --with-iconv
```

执行安装：

```
[root@mophee php-5.5.8]# make && make install
```

创建配置文件：

```
[root@mophee php-5.5.8]# cp php.ini-* /opt/php/etc/ 
[root@mophee php-5.5.8]# cp php.ini-development /opt/php/etc/php.ini 
[root@mophee php]# cp /opt/php/etc/php-fpm.conf.default /opt/php/etc/php-fpm.conf 
[root@mophee php]# cd /opt/php 
[root@mophee php]# ll etc 
total 268 
-rw-r--r-- 1 root root 1092 Jan 12 17:27 pear.conf 
-rw-r--r-- 1 root root 21826 Jan 12 17:34 php-fpm.conf 
-rw-r--r-- 1 root root 21826 Jan 12 17:26 php-fpm.conf.default 
-rw-r--r-- 1 root root 70977 Jan 12 17:30 php.ini 
-rw-r--r-- 1 root root 70977 Jan 12 17:29 php.ini-development 
-rw-r--r-- 1 root root 71009 Jan 12 17:29 php.ini-production
```

以上主要新增了两个有效配置文件：php.ini和php-fpm.conf，其中顾名思义，php.ini是php的配置文件，php-fpm.conf是php-fpm的配置文件。那么php-fpm是什么？php-fpm是fastcgi_params的管理程序。php-fpm通过其配置文件php-fpm.conf中的listen参数配置监听的地址和端口。启动php-fpm：

```
[root@mophee php]# sbin/php-fpm 
 
[root@mophee php]# ps aux | grep php-fpm
root      4155  0.0  0.3 281588  4492 ?        Ss   20:15   0:00 php-fpm: master process (/opt/php/etc/php-fpm.conf)
nobody    4156  0.0  0.3 281588  4208 ?        S    20:15   0:00 php-fpm: pool www
nobody    4157  0.0  0.3 281588  4212 ?        S    20:15   0:00 php-fpm: pool www
root      4167  0.0  0.0 103244   836 pts/0    S+   20:15   0:00 grep php-fpm
```

进一步配置php-fpm和nginx使他们能够进行通信，以让nginx支持php。

查看/opt/php/etc/php-fpm.conf文件，查找listen参数：

```
listen = 127.0.0.1:9000
```

在nginx的配置文件/opt/nginx/conf/nginx.conf中配置如下：

```
[root@mophee home]# vi /opt/nginx/conf/nginx.conf
 
        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            include        fastcgi_params;
        }
```
至此，完成php安装，并且nginx支持php。

配置开机启动

创建可执行文件：

```
[root@com sbin]# vim php-fpm.server
```

内容如下：

```bash
#! /bin/sh
### BEGIN INIT INFO
# Provides:          php-fpm
# Required-Start:    $remote_fs $network
# Required-Stop:     $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts php-fpm
# Description:       starts the PHP FastCGI Process Manager daemon
### END INIT INFO
 
prefix=/opt/php
exec_prefix=${prefix}
 
php_fpm_BIN=${exec_prefix}/sbin/php-fpm
php_fpm_CONF=${prefix}/etc/php-fpm.conf
php_fpm_PID=${prefix}/var/run/php-fpm.pid
 
php_opts="--fpm-config $php_fpm_CONF --pid $php_fpm_PID"
 
wait_for_pid () {
    try=0
 
    while test $try -lt 35 ; do
 
        case "$1" in
            'created')
            if [ -f "$2" ] ; then
                try=''
                break
            fi
            ;;
 
            'removed')
            if [ ! -f "$2" ] ; then
                try=''
                break
            fi
            ;;
        esac
 
        echo -n .
        try=`expr $try + 1`
        sleep 1
 
    done
 
}
 
case "$1" in
    start)
        echo -n "Starting php-fpm "
 
        $php_fpm_BIN --daemonize $php_opts
 
        if [ "$?" != 0 ] ; then
            echo " failed"
            exit 1
        fi
 
        wait_for_pid created $php_fpm_PID
 
        if [ -n "$try" ] ; then
            echo " failed"
            exit 1
        else
                echo " done"
        fi
    ;;
 
    stop)
        echo -n "Gracefully shutting down php-fpm "
 
        if [ ! -r $php_fpm_PID ] ; then
            echo "warning, no pid file found - php-fpm is not running ?"
            exit 1
        fi
 
        kill -QUIT `cat $php_fpm_PID`
 
        wait_for_pid removed $php_fpm_PID
 
        if [ -n "$try" ] ; then
            echo " failed. Use force-quit"
            exit 1
        else
                echo " done"
        fi
    ;;
 
    force-quit)
        echo -n "Terminating php-fpm "
 
        if [ ! -r $php_fpm_PID ] ; then
            echo "warning, no pid file found - php-fpm is not running ?"
            exit 1
        fi
 
        kill -TERM `cat $php_fpm_PID`
 
        wait_for_pid removed $php_fpm_PID
 
        if [ -n "$try" ] ; then
            echo " failed"
            exit 1
        else
                echo " done"
        fi
    ;;
 
    restart)
        $0 stop
        $0 start
    ;;
 
    reload)
 
        echo -n "Reload service php-fpm "
 
        if [ ! -r $php_fpm_PID ] ; then
            echo "warning, no pid file found - php-fpm is not running ?"
            exit 1
        fi
 
        kill -USR2 `cat $php_fpm_PID`
 
        echo " done"
    ;;
 
    *)
        echo "Usage: $0 {start|stop|force-quit|restart|reload}"
        exit 1
    ;;
 
esac
```

修改为可执行：

```
[root@com sbin]# chmod +x php-fpm.server 
[root@com sbin]# ll
总用量 32424
-rwxr-xr-x. 1 root root 33197125 7月   1 14:21 php-fpm
-rwxr-xr-x. 1 root root     3398 7月   1 15:07 php-fpm.server
```

copy到/etc/init.d/下并添加chkconfig管理：

```
[root@com sbin]# cp php-fpm.server /etc/init.d/php
[root@com sbin]# chkconfig --add php
[root@com sbin]# chkconfig | grep php
php             0:关闭    1:关闭    2:启用    3:启用    4:启用    5:启用    6:关闭
```

则可以使用service php start开启php，service php stop关闭php