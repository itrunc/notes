#在Ubuntu15.04_x64下搭建LAMP开发环境

##基本安装

```
$ sudo apt-get install apache2 php5-mysql libapache2-mod-php5 mysql-server
```

期间会弹出窗口提示输入 MySQL root 用户密码。


##添加组件

```
$ sudo apt-get install php5 [TAB] [TAB]
php5                php5-gdcm           php5-librdf         php5-odbc           php5-recode         php5-twig
php5-adodb          php5-gearman        php5-libvirt-php    php5-pecl-http      php5-redis          php5-uprofiler
php5-apcu           php5-geoip          php5-mapscript      php5-pecl-http-dev  php5-remctl         php5-vtkgdcm
php5-cgi            php5-geos           php5-mcrypt         php5-pgsql          php5-rrd            php5-xcache
php5-cli            php5-gmp            php5-memcache       php5-phpdbg         php5-sasl           php5-xdebug
php5-common         php5-gnupg          php5-memcached      php5-pinba          php5-snmp           php5-xhprof
php5-curl           php5-igbinary       php5-midgard2       php5-propro         php5-solr           php5-xmlrpc
php5-dbg            php5-imagick        php5-ming           php5-propro-dev     php5-sqlite         php5-xsl
php5-dev            php5-imap           php5-mongo          php5-ps             php5-ssh2           php5-yac
php5-enchant        php5-interbase      php5-msgpack        php5-pspell         php5-stomp          php5-zmq
php5-exactimage     php5-intl           php5-mysql          php5-radius         php5-svn            
php5-facedetect     php5-json           php5-mysqlnd        php5-raphf          php5-sybase         
php5-fpm            php5-lasso          php5-mysqlnd-ms     php5-raphf-dev      php5-tidy           
php5-gd             php5-ldap           php5-oauth          php5-readline       php5-tokyo-tyrant
```

###添加 GD 和 Curl组件
$sudo apt-get install php5-gd php5-curl