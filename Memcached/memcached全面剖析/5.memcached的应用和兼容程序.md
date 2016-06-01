#memcached全面剖析--5. memcached的应用和兼容程序

- **发表日**：2008/7/30
- **作者**：长野雅广(Masahiro Nagano)
- **原文链接**：http://gihyo.jp/dev/feature/01/memcached/0005

前几次的文章在这里：

- [第1次](http://charlee.li/memcached-001.html)
- [第2次](http://charlee.li/memcached-002.html)
- [第3次](http://charlee.li/memcached-003.html)
- [第4次](http://charlee.li/memcached-004.html)

我是Mixi的长野。memcached的连载终于要结束了。到[上次](http://charlee.li/memcached-004.html)为止，我们介绍了与memcached直接相关的话题，本次介绍一些mixi的案例和实际应用上的话题，并介绍一些与memcached兼容的程序。

##mixi案例研究

mixi在提供服务的初期阶段就使用了memcached。 随着网站访问量的急剧增加，单纯为数据库添加slave已无法满足需要，因此引入了memcached。 此外，我们也从增加可扩展性的方面进行了验证，证明了memcached的速度和稳定性都能满足需要。 现在，memcached已成为mixi服务中非常重要的组成部分。

![memcached-0005-01.png](img/memcached-0005-01.png)

图1 现在的系统组件

###服务器配置和数量

mixi使用了许许多多服务器，如数据库服务器、应用服务器、图片服务器、 反向代理服务器等。单单memcached就有将近200台服务器在运行。 memcached服务器的典型配置如下：

- CPU：Intel Pentium 4 2.8GHz
- 内存：4GB
- 硬盘：146GB SCSI
- 操作系统：Linux（x86_64）

这些服务器以前曾用于数据库服务器等。随着CPU性能提升、内存价格下降， 我们积极地将数据库服务器、应用服务器等换成了性能更强大、内存更多的服务器。 这样，可以抑制mixi整体使用的服务器数量的急剧增加，降低管理成本。 由于memcached服务器几乎不占用CPU，就将换下来的服务器用作memcached服务器了。

###memcached进程

每台memcached服务器仅启动一个memcached进程。分配给memcached的内存为3GB， 启动参数如下：

```
/usr/bin/memcached -p 11211 -u nobody -m 3000 -c 30720
```

由于使用了x86_64的操作系统，因此能分配2GB以上的内存。32位操作系统中， 每个进程最多只能使用2GB内存。也曾经考虑过启动多个分配2GB以下内存的进程， 但这样一台服务器上的TCP连接数就会成倍增加，管理上也变得复杂， 所以mixi就统一使用了64位操作系统。

另外，虽然服务器的内存为4GB，却仅分配了3GB，是因为内存分配量超过这个值， 就有可能导致内存交换(swap)。连载的第2次中 前坂讲解过了memcached的内存存储“slab allocator”，当时说过，memcached启动时 指定的内存分配量是memcached用于保存数据的量，没有包括“slab allocator”本身占用的内存、 以及为了保存数据而设置的管理空间。因此，memcached进程的实际内存分配量要比 指定的容量要大，这一点应当注意。

mixi保存在memcached中的数据大部分都比较小。这样，进程的大小要比 指定的容量大很多。因此，我们反复改变内存分配量进行验证， 确认了3GB的大小不会引发swap，这就是现在应用的数值。

###memcached使用方法和客户端

现在，mixi的服务将200台左右的memcached服务器作为一个pool使用。 每台服务器的容量为3GB，那么全体就有了将近600GB的巨大的内存数据库。 客户端程序库使用了本连载中多次提到车的Cache::Memcached::Fast， 与服务器进行交互。当然，缓存的分布式算法使用的是第4次介绍过的 Consistent Hashing算法。

- [Cache::Memcached::Fast - search.cpan.org](http://search.cpan.org/dist/Cache-Memcached-Fast/)

应用层上memcached的使用方法由开发应用程序的工程师自行决定并实现。 但是，为了防止车轮再造、防止Cache::Memcached::Fast上的教训再次发生， 我们提供了Cache::Memcached::Fast的wrap模块并使用。

####通过Cache::Memcached::Fast维持连接

Cache::Memcached的情况下，与memcached的连接（文件句柄）保存在Cache::Memcached包内的类变量中。 在mod_perl和FastCGI等环境下，包内的变量不会像CGI那样随时重新启动， 而是在进程中一直保持。其结果就是不会断开与memcached的连接， 减少了TCP连接建立时的开销，同时也能防止短时间内反复进行TCP连接、断开 而导致的TCP端口资源枯竭。

但是，Cache::Memcached::Fast没有这个功能，所以需要在模块之外 将Cache::Memcached::Fast对象保持在类变量中，以保证持久连接。

```
package Gihyo::Memcached;

use strict;
use warnings;
use Cache::Memcached::Fast;

my @server_list = qw/192.168.1.1:11211 192.168.1.1:11211/;
my $fast;  ## 用于保持对象

sub new {
    my $self  = bless {}, shift;
    if ( !$fast ) {
        $fast = Cache::Memcached::Fast->new({ servers => \@server_list });
    }
    $self->{_fast} = $fast;
    return $self;
}

sub get {
   my $self = shift;
   $self->{_fast}->get(@_);
}
```

上面的例子中，Cache::Memcached::Fast对象保存到类变量$fast中。

####公共数据的处理和rehash

诸如mixi的主页上的新闻这样的所有用户共享的缓存数据、设置信息等数据， 会占用许多页，访问次数也非常多。在这种条件下，访问很容易集中到某台memcached服务器上。 访问集中本身并不是问题，但是一旦访问集中的那台服务器发生故障导致memcached无法连接， 就会产生巨大的问题。

连载的第4次中提到，Cache::Memcached拥有rehash功能，即在无法连接保存数据的服务器的情况下， 会再次计算hash值，连接其他的服务器。

但是，Cache::Memcached::Fast没有这个功能。不过，它能够在连接服务器失败时， 短时间内不再连接该服务器的功能。

```
my $fast = Cache::Memcached::Fast->new({
    max_failures     => 3,
    failure_timeout  => 1
});
```

在failure_timeout秒内发生max_failures以上次连接失败，就不再连接该memcached服务器。 我们的设置是1秒钟3次以上。

此外，mixi还为所有用户共享的缓存数据的键名设置命名规则， 符合命名规则的数据会自动保存到多台memcached服务器中， 取得时从中仅选取一台服务器。创建该函数库后，就可以使memcached服务器故障 不再产生其他影响。

##memcached应用经验

到此为止介绍了memcached内部构造和函数库，接下来介绍一些其他的应用经验。

###通过daemontools启动

通常情况下memcached运行得相当稳定，但mixi现在使用的最新版1.2.5 曾经发生过几次memcached进程死掉的情况。架构上保证了即使有几台memcached故障 也不会影响服务，不过对于memcached进程死掉的服务器，只要重新启动memcached， 就可以正常运行，所以采用了监视memcached进程并自动启动的方法。 于是使用了daemontools。

daemontools是qmail的作者DJB开发的UNIX服务管理工具集， 其中名为supervise的程序可用于服务启动、停止的服务重启等。

- [daemontools](http://cr.yp.to/daemontools.html)

这里不介绍daemontools的安装了。mixi使用了以下的run脚本来启动memcached。

```
#!/bin/sh

if [ -f /etc/sysconfig/memcached ];then
        . /etc/sysconfig/memcached
fi

exec 2>&1
exec /usr/bin/memcached -p $PORT -u $USER  -m $CACHESIZE -c $MAXCONN $OPTIONS
```

###监视

mixi使用了名为“nagios”的开源监视软件来监视memcached。

- [Nagios: Home](http://www.nagios.org/)

在nagios中可以简单地开发插件，可以详细地监视memcached的get、add等动作。 不过mixi仅通过stats命令来确认memcached的运行状态。

```
define command {
command_name                   check_memcached
command_line                   $USER1$/check_tcp -H $HOSTADDRESS$ -p 11211 -t 5 -E -s 'stats\r\nquit\r\n' -e 'uptime' -M crit
}
```

此外，mixi将stats目录的结果通过rrdtool转化成图形，进行性能监视， 并将每天的内存使用量做成报表，通过邮件与开发者共享。

###memcached的性能

连载中已介绍过，memcached的性能十分优秀。我们来看看mixi的实际案例。 这里介绍的图表是服务所使用的访问最为集中的memcached服务器。

![memcached-0005-02.png](img/memcached-0005-02.png)

图2 请求数

![memcached-0005-03.png](img/memcached-0005-03.png)

图3 流量

![memcached-0005-04.png](img/memcached-0005-04.png)

图4 TCP连接数

从上至下依次为请求数、流量和TCP连接数。请求数最大为15000qps， 流量达到400Mbps，这时的连接数已超过了10000个。 该服务器没有特别的硬件，就是开头介绍的普通的memcached服务器。 此时的CPU利用率为：

![memcached-0005-05.png](img/memcached-0005-05.png)

图5 CPU利用率

可见，仍然有idle的部分。因此，memcached的性能非常高， 可以作为Web应用程序开发者放心地保存临时数据或缓存数据的地方。

##兼容应用程序

memcached的实现和协议都十分简单，因此有很多与memcached兼容的实现。 一些功能强大的扩展可以将memcached的内存数据写到磁盘上，实现数据的持久性和冗余。 连载第3次介绍过，以后的memcached的存储层将变成可扩展的（pluggable），逐渐支持这些功能。

这里介绍几个与memcached兼容的应用程序。

- repcached: 为memcached提供复制(replication)功能的patch。
- Flared: 存储到QDBM。同时实现了异步复制和fail over等功能。
- memcachedb: 存储到BerkleyDB。还实现了message queue。
- Tokyo Tyrant: 将数据存储到Tokyo Cabinet。不仅与memcached协议兼容，还能通过HTTP进行访问。

###Tokyo Tyrant案例

mixi使用了上述兼容应用程序中的Tokyo Tyrant。Tokyo Tyrant是平林开发的 Tokyo Cabinet DBM的网络接口。它有自己的协议，但也拥有memcached兼容协议， 也可以通过HTTP进行数据交换。Tokyo Cabinet虽然是一种将数据写到磁盘的实现，但速度相当快。

mixi并没有将Tokyo Tyrant作为缓存服务器，而是将它作为保存键值对组合的DBMS来使用。 主要作为存储用户上次访问时间的数据库来使用。它与几乎所有的mixi服务都有关， 每次用户访问页面时都要更新数据，因此负荷相当高。MySQL的处理十分笨重， 单独使用memcached保存数据又有可能会丢失数据，所以引入了Tokyo Tyrant。 但无需重新开发客户端，只需原封不动地使用Cache::Memcached::Fast即可， 这也是优点之一。关于Tokyo Tyrant的详细信息，请参考本公司的开发blog。

- [mixi Engineers’ Blog - Tokyo Tyrantによる耐高負荷DBの構築](http://alpha.mixi.co.jp/entry/2008/10694/)
- [mixi Engineers’ Blog - Tokyo Cabinet Tyrantの新機能](http://alpha.mixi.co.jp/entry/2008/10696/)

##总结

到本次为止，“memcached全面剖析”系列就结束了。我们介绍了memcached的基础、内部结构、 分散算法和应用等内容。读完后如果您能对memcached产生兴趣，就是我们的荣幸。 关于mixi的系统、应用方面的信息，请参考本公司的开发blog。 感谢您的阅读。


##引用

- [1] [原文](http://charlee.li/memcached-005.html)