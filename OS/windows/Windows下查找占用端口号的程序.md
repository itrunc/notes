#Windows下查找占用端口号的程序

打开CMD（Windows命令行），输入命令：

```
C:\Windows\System32>netstat -ano | findstr "LISTENING" | findstr ":80"
  TCP    0.0.0.0:80             0.0.0.0:0              LISTENING       7972
```

该命令用于查找正在监听（LISTENING）状态且占用了 80 端口的进程号为 7972 (最后一列) 。

使用查找到的进程号进而查找进程，输入以下命令：

```
C:\Windows\System32>tasklist | findstr "7972"
nginx.exe                     7972 Console                    1      5,856 K
```

以上得知，nginx.exe占用了 80 端口。

> netstat 显示协议统计和当前 TCP/IP 网络连接
>
> netstat [-a] [-b] [-e] [-f] [-n] [-o] [-p proto] [-r] [-s] [-t] [interval]
> 
> * -a  显示所有连接和侦听端口；
> * -b  显示在创建每个连接或侦听端口时涉及的可执行程序。在某些情况下，已知可执行程序承载多个独立的组件，这些情况下，显示创建连接或侦听端口时涉及的组件序列。此情况下，可执行程序的名称位于底部 [ ] 中，它调用的组件位于顶部，直至达到 TCP/IP。注意：此选项可能很耗时，并且在您没有足够权限时可能失败。
> * -e  显示以太网统计。此选项可以与 -s 选项结合使用。
> * -f  显示外部地址的完全限定域名 （FQDN）。
> * -n  以数字形式显示地址和端口号。
> * -o  显示拥有的与每个连接关联的进程 ID。
> * -p proto  显示 proto 指定的协议的连接；proto可取值为：TCP, UDP, TCPv6 或 UDPv6。如果与 -s 选项一起用来显示每个协议的统计， proto 可取值为： IP, IPv6, ICMP, ICMPv6, TCP, TCPv6, UDP 或 UPDv6。
> * -r  显示路由表。
> * -s  显示每个协议的统计。默认情况下，显示 IP, IPv6, ICMP, ICMPv6, TCP, TCPv6, UDP 和 UPDv6 的统计；-p 选项可用于指定默认的子网。
> * -t  显示当前连接卸载状态
>
>interval 重新显示指定的统计，各个显示间暂停的间隔秒数。按 CTRL+C 停止重新显示统计。如果省略，则 netstat将打印当前的配置信息一次。