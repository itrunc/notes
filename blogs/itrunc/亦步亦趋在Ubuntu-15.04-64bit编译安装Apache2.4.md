# 亦步亦趋在Ubuntu 15.04 64-bit编译安装 Apache2.4

* 下载 apache 2.4： http://httpd.apache.org/download.cgi#apache24
* 下载 APR, APR-util: http://apr.apache.org/download.cgi

```
$ ll
total 10388
drwxr-xr-x  4 panben panben    4096  9月  9 14:04 ./
drwxr-xr-x 16 panben panben    4096  9月  9 11:48 ../
-rwxrw-r--  1 panben panben 1031613  9月  9 13:53 apr-1.5.2.tar.gz
-rwxrw-r--  1 panben panben  874044  9月  9 13:54 apr-util-1.5.4.tar.gz
-rw-rw-r--  1 panben panben 6899517  9月  9 09:37 httpd-2.4.16.tar.gz
```

## Requirements

The following requirements exist for building Apache httpd:

### APR and APR-Util 

Make sure you have APR and APR-Util already installed on your system. If you don't, or prefer to not use the system-provided versions, download the latest versions of both APR and APR-Util from [Apache APR](http://apr.apache.org/), unpack them into /httpd_source_tree_root/srclib/apr and /httpd_source_tree_root/srclib/apr-util (be sure the directory names do not have version numbers; for example, the APR distribution must be under /httpd_source_tree_root/srclib/apr/) and use ./configure's --with-included-apr option. On some platforms, you may have to install the corresponding -dev packages to allow httpd to build against your installed copy of APR and APR-Util. 

### Perl-Compatible Regular Expressions Library (PCRE) 

This library is required but not longer bundled with httpd. Download the source code from http://www.pcre.org, or install a Port or Package. If your build system can't find the pcre-config script installed by the PCRE build, point to it using the --with-pcre parameter. On some platforms, you may have to install the corresponding -dev package to allow httpd to build against your installed copy of PCRE. 

Ubuntu下安装PRCE

```
$ sudo apt-get update
$ sudo apt-get install libpcre3 libpcre3-dev
```

### Disk Space 

Make sure you have at least 50 MB of temporary free disk space available. After installation the server occupies approximately 10 MB of disk space. The actual disk space requirements will vary considerably based on your chosen configuration options, any third-party modules, and, of course, the size of the web site or sites that you have on the server. 

### ANSI-C Compiler and Build System 

Make sure you have an ANSI-C compiler installed. The [GNU C compiler (GCC)](http://gcc.gnu.org/) from the [Free Software Foundation (FSF)](http://www.gnu.org/) is recommended. If you don't have GCC then at least make sure your vendor's compiler is ANSI compliant. In addition, your PATH must contain basic build tools such as make. 

### Accurate time keeping 

Elements of the HTTP protocol are expressed as the time of day. So, it's time to investigate setting some time synchronization facility on your system. Usually the ntpdate or xntpd programs are used for this purpose which are based on the Network Time Protocol (NTP). See the [NTP homepage](http://www.ntp.org/) for more details about NTP software and public time servers. 

### Perl 5 [OPTIONAL] 

For some of the support scripts like apxs or dbmmanage (which are written in Perl) the Perl 5 interpreter is required (versions 5.003 or newer are sufficient). If no Perl 5 interpreter is found by the configure script, you will not be able to use the affected support scripts. Of course, you will still be able to build and use Apache httpd.

## 解压源码包并进入解压后的目录

```
$ tar -zxvf httpd-2.4.16.tar.gz
$ tar -zxvf apr-1.5.2.tar.gz
$ tar -zxvf apr-util-1.5.4.tar.gz
$ mv apr-1.5.2 httpd-2.4.16/srclib/apr
$ mv apr-util-1.5.4 httpd-2.4.16/srclib/apr-util
$ cd httpd-2.4.16/
```

## 编译

```
$ ./configure --prefix=/opt/httpd --with-included-apr
$ make
$ sudo make install
```

## 配置

```
$ sudo gedit conf/httpd.conf
```

## 启动

```
$ sudo bin/apachectl -k start
```
