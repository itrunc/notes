#亦步亦趋在CentOS 6.4 64-bit编译安装nginx

在root下操作

Nginx的地址重写依赖Perl正则表达式，因此需要同时安装PCRE库。由于系统安装的PCRE无法被Nginx的configure监测到，所以需自行从网上下载PCRE包，在编译Nginx时使用–with-pcre参数一起编译。下载PCRE包并解压后移动到/opt/pcre目录下：

```
[root@itrunc.com home]# wget http://sourceforge.net/projects/pcre/files/pcre/8.34/pcre-8.34.tar.gz/download
[root@itrunc.com home]# tar -zxvf pcre-8.34.tar.gz
[root@itrunc.com home]# mv pcre-8.34 /opt/pcre
```

下载Nginx并解压后进入安装目录：

```
[root@itrunc.com home]# wget http://nginx.org/download/nginx-1.5.8.tar.gz
[root@itrunc.com home]# tar -zxvf nginx-1.5.8.tar.gz 
[root@itrunc.com home]# cd nginx-1.5.8
```

生成Makefile：

```
[root@itrunc.com nginx-1.5.8]# ./configure --prefix=/opt/nginx --with-pcre=/opt/pcre
checking for OS
 + Linux 2.6.32-358.el6.x86_64 x86_64
checking for C compiler ... found
 + using GNU C compiler
 + gcc version: 4.4.7 20120313 (Red Hat 4.4.7-3) (GCC) 
checking for gcc -pipe switch ... found
checking for gcc builtin atomic operations ... found
checking for C99 variadic macros ... found
checking for gcc variadic macros ... found
checking for unistd.h ... found
checking for inttypes.h ... found
checking for limits.h ... found
checking for sys/filio.h ... not found
checking for sys/param.h ... found
checking for sys/mount.h ... found
checking for sys/statvfs.h ... found
checking for crypt.h ... found
checking for Linux specific features
checking for epoll ... found
checking for EPOLLRDHUP ... found
checking for O_PATH ... not found
checking for sendfile() ... found
checking for sendfile64() ... found
checking for sys/prctl.h ... found
checking for prctl(PR_SET_DUMPABLE) ... found
checking for sched_setaffinity() ... found
checking for crypt_r() ... found
checking for sys/vfs.h ... found
checking for nobody group ... found
checking for poll() ... found
checking for /dev/poll ... not found
checking for kqueue ... not found
checking for crypt() ... not found
checking for crypt() in libcrypt ... found
checking for F_READAHEAD ... not found
checking for posix_fadvise() ... found
checking for O_DIRECT ... found
checking for F_NOCACHE ... not found
checking for directio() ... not found
checking for statfs() ... found
checking for statvfs() ... found
checking for dlopen() ... not found
checking for dlopen() in libdl ... found
checking for sched_yield() ... found
checking for SO_SETFIB ... not found
checking for SO_ACCEPTFILTER ... not found
checking for TCP_DEFER_ACCEPT ... found
checking for TCP_KEEPIDLE ... found
checking for TCP_FASTOPEN ... not found
checking for TCP_INFO ... found
checking for accept4() ... found
checking for int size ... 4 bytes
checking for long size ... 8 bytes
checking for long long size ... 8 bytes
checking for void * size ... 8 bytes
checking for uint64_t ... found
checking for sig_atomic_t ... found
checking for sig_atomic_t size ... 4 bytes
checking for socklen_t ... found
checking for in_addr_t ... found
checking for in_port_t ... found
checking for rlim_t ... found
checking for uintptr_t ... uintptr_t found
checking for system byte ordering ... little endian
checking for size_t size ... 8 bytes
checking for off_t size ... 8 bytes
checking for time_t size ... 8 bytes
checking for setproctitle() ... not found
checking for pread() ... found
checking for pwrite() ... found
checking for sys_nerr ... found
checking for localtime_r() ... found
checking for posix_memalign() ... found
checking for memalign() ... found
checking for mmap(MAP_ANON|MAP_SHARED) ... found
checking for mmap("/dev/zero", MAP_SHARED) ... found
checking for System V shared memory ... found
checking for POSIX semaphores ... not found
checking for POSIX semaphores in libpthread ... found
checking for struct msghdr.msg_control ... found
checking for ioctl(FIONBIO) ... found
checking for struct tm.tm_gmtoff ... found
checking for struct dirent.d_namlen ... not found
checking for struct dirent.d_type ... found
checking for sysconf(_SC_NPROCESSORS_ONLN) ... found
checking for openat(), fstatat() ... found
checking for getaddrinfo() ... found
checking for md5 in system md library ... not found
checking for md5 in system md5 library ... not found
checking for md5 in system OpenSSL crypto library ... found
checking for sha1 in system md library ... not found
checking for sha1 in system OpenSSL crypto library ... found
checking for zlib library ... found
creating objs/Makefile
 
Configuration summary
  + using PCRE library: /opt/pcre
  + OpenSSL library is not used
  + md5: using system crypto library
  + sha1: using system crypto library
  + using system zlib library
 
  nginx path prefix: "/opt/nginx"
  nginx binary file: "/opt/nginx/sbin/nginx"
  nginx configuration prefix: "/opt/nginx/conf"
  nginx configuration file: "/opt/nginx/conf/nginx.conf"
  nginx pid file: "/opt/nginx/logs/nginx.pid"
  nginx error log file: "/opt/nginx/logs/error.log"
  nginx http access log file: "/opt/nginx/logs/access.log"
  nginx http client request body temporary files: "client_body_temp"
  nginx http proxy temporary files: "proxy_temp"
  nginx http fastcgi temporary files: "fastcgi_temp"
  nginx http uwsgi temporary files: "uwsgi_temp"
  nginx http scgi temporary files: "scgi_temp"
```

编译并安装Nginx：

```
[root@itrunc.com nginx-1.5.8]# make && make install
```

完成安装检查一下安装目录：

```
[root@itrunc.com nginx-1.5.8]# ll /opt/nginx
total 16
drwxr-xr-x 2 root root 4096 Jan 12 14:43 conf
drwxr-xr-x 2 root root 4096 Jan 12 14:43 html
drwxr-xr-x 2 root root 4096 Jan 12 14:43 logs
drwxr-xr-x 2 root root 4096 Jan 12 14:43 sbin
```

检查一下运行文件：

```
[root@itrunc.com nginx-1.5.8]# cd /opt/nginx/sbin
[root@itrunc.com sbin]# ll
total 3112
-rwxr-xr-x 1 root root 3185918 Jan 12 14:43 nginx
```

启动nginx只需要运行一下/opt/nginx/sbin/nginx程序即可，然而此方式却不易于管理，关闭程序时只能使用kill -9命令杀进程。所幸官方已经替我们想到了这一步，提供了管理的脚本(网址)。

用vi创建一个名为nginx.server的文件：

```
[root@itrunc.com sbin]# vi nginx.server
```

该文件的内容如下：

```bash
#!/bin/sh
#
# nginx - this script starts and stops the nginx daemon
#
# chkconfig:   - 85 15 
# description:  Nginx is an HTTP(S) server, HTTP(S) reverse \
#               proxy and IMAP/POP3 proxy server
# processname: nginx
# config:      /etc/nginx/nginx.conf
# config:      /etc/sysconfig/nginx
# pidfile:     /var/run/nginx.pid
 
# Source function library.
. /etc/rc.d/init.d/functions
 
# Source networking configuration.
. /etc/sysconfig/network
 
# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0
 
nginx="/opt/nginx/sbin/nginx"
prog=$(basename $nginx)
 
NGINX_CONF_FILE="/opt/nginx/conf/nginx.conf"
 
[ -f /etc/sysconfig/nginx ] && . /etc/sysconfig/nginx
 
lockfile=/var/lock/subsys/nginx
 
make_dirs() {
   # make required directories
   user=`$nginx -V 2>&1 | grep "configure arguments:" | sed 's/[^*]*--user=\([^ ]*\).*/\1/g' -`
   if [ -z "`grep $user /etc/passwd`" ]; then
       useradd -M -s /bin/nologin $user
   fi
   options=`$nginx -V 2>&1 | grep 'configure arguments:'`
   for opt in $options; do
       if [ `echo $opt | grep '.*-temp-path'` ]; then
           value=`echo $opt | cut -d "=" -f 2`
           if [ ! -d "$value" ]; then
               # echo "creating" $value
               mkdir -p $value && chown -R $user $value
           fi
       fi
   done
}
 
start() {
    [ -x $nginx ] || exit 5
    [ -f $NGINX_CONF_FILE ] || exit 6
    make_dirs
    echo -n $"Starting $prog: "
    daemon $nginx -c $NGINX_CONF_FILE
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}
 
stop() {
    echo -n $"Stopping $prog: "
    killproc $prog -QUIT
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}
 
restart() {
    configtest || return $?
    stop
    sleep 1
    start
}
 
reload() {
    configtest || return $?
    echo -n $"Reloading $prog: "
    killproc $nginx -HUP
    RETVAL=$?
    echo
}
 
force_reload() {
    restart
}
 
configtest() {
  $nginx -t -c $NGINX_CONF_FILE
}
 
rh_status() {
    status $prog
}
 
rh_status_q() {
    rh_status >/dev/null 2>&1
}
 
case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart|configtest)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
            ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}"
        exit 2
esac
```

保存nginx.server文件后，将其修改为可执行脚本：

```
[root@itrunc.com sbin]# chmod 755 nginx.server
[root@itrunc.com sbin]# ll
total 3116
-rwxr-xr-x 1 root root 3185918 Jan 12 14:43 nginx
-rwxr-xr-x 1 root root    2622 Jan 12 14:58 nginx.server
```

将nginx.server复制到/etc/init.d/nginx：

```
[root@itrunc.com sbin]# cp nginx.server /etc/init.d/nginx
```

此时可用如下命令方式来管理nginx了：

```
[root@itrunc.com sbin]# /etc/init.d/nginx start
Starting nginx:                                            [  OK  ]
[root@itrunc.com sbin]# /etc/init.d/nginx status
nginx (pid 23444 23442) is running...
[root@itrunc.com sbin]# /etc/init.d/nginx stop
Stopping nginx:                                            [  OK  ]
```

最后一步，把nginx服务加入到chkconfig中：

```
[root@itrunc.com sbin]# chkconfig --add nginx
[root@itrunc.com sbin]# chkconfig | grep nginx
nginx           0:off   1:off   2:off   3:off   4:off   5:off   6:off
```

此时可用如下命令方式来管理nginx了：

```
[root@itrunc.com sbin]# service nginx start
Starting nginx:                                            [  OK  ]
[root@itrunc.com sbin]# service nginx status
nginx (pid 23588 23587) is running...
[root@itrunc.com sbin]# service nginx reload
nginx: the configuration file /opt/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /opt/nginx/conf/nginx.conf test is successful
Reloading nginx:                                           [  OK  ]
[root@itrunc.com sbin]# service nginx stop
Stopping nginx:                                            [  OK  ]
```

完成安装nginx，启动nginx服务后，通过浏览器访问localhost即可打开nginx的欢迎页了。