# Memcache分布式部署方案

## 前言

应该是很久之前，我开始研究[Memcache](http://www.danga.com/memcached/)，写了一系列的学习心得，比如《[Discuz!的Memcache缓存实现](http://www.ccvita.com/261.html)》等。后面的好几十条回复也让这篇文章成为了此博客中颇受关注的一员。

同时在百度和Google，关键词Memcache在长达一年多的时间里占据着第二位（第一位是官方），为很多需要了解或者应用Memcache的朋友提供了一些信息，但是我始终觉着还不够，于是本文诞生。

唠唠叨叨说了半天，如果你觉着前面啰嗦，请直接看最后一大段，那是本文的重点。

## 基础环境

其实基于PHP扩展的Memcache客户端实际上早已经实现，而且非常稳定。先解释一些名词，Memcache是danga.com的一个开源项目，可以类比于MySQL这样的服务，而PHP扩展的Memcache实际上是连接Memcache的方式。

首先，进行Memcache被安装具体可查看：

> - [Linux下的Memcache安装](http://www.ccvita.com/257.html)
> 
> - [Windows下的Memcache安装](http://www.ccvita.com/258.html)

其次，进行PHP扩展的安装，官方地址是[http://pecl.php.net/package/memcache](http://pecl.php.net/package/memcache)

最后，启动Memcache服务，比如这样

```sh
/usr/local/bin/memcached -d -p 11213 -u root -m 10 -c 1024 -t 8 -P /tmp/memcached.pid
/usr/local/bin/memcached -d -p 11214 -u root -m 10 -c 1024 -t 8 -P /tmp/memcached.pid
/usr/local/bin/memcached -d -p 11215 -u root -m 10 -c 1024 -t 8 -P /tmp/memcached.pid
```

启动三个只使用10M内存以方便测试。

## 分布式部署

PHP的PECL扩展中的memcache实际上在2.0.0的版本中就已经实现多服务器支持，现在都已经2.2.5了。请看如下代码

```php
$memcache = new Memcache;
$memcache->addServer('localhost', 11213);
$memcache->addServer('localhost', 11214);
$memcache->addServer('localhost', 11215);
$memStats = $memcache->getExtendedStats();
print_r($memStats);
```

通过上例就已经实现Memcache的分布式部署，是不是非常简单。

## 分布式系统的良性运行

在Memcache的实际使用中，遇到的最严重的问题，就是在增减服务器的时候，会导致大范围的缓存丢失，从而可能会引导数据库的性能瓶颈，为了避免出现这种情况，请先看Consistent hashing算法，中文的介绍可以参考这里，通过存取时选定服务器算法的改变，来实现。

修改PHP的Memcache扩展memcache.c的源代码中的

```c
"memcache.hash_strategy" = standard
```

为

```c
"memcache.hash_strategy" = consistent
```

重新编译，这时候就是使用Consistent hashing算法来寻找服务器存取数据了。

有效测试数据表明，使用Consistent hashing可以极大的改善增删Memcache时缓存大范围丢失的情况。

```
NonConsistentHash: 92% of lookups changed after adding a target to the existing 10
NonConsistentHash: 90% of lookups changed after removing 1 of 10 targets
ConsistentHash: 6% of lookups changed after adding a target to the existing 10
ConsistentHash: 9% of lookups changed after removing 1 of 10 targets
```

## 引用

- [0] [原文](http://www.ccvita.com/261.html)