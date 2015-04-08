#CentOS静态网络配置

网络配置主要涉及到以下文件：

##/etc/sysconfig/network

这里主要设置网关，该文件初始内容如下：

```
NETWORKING=yes
HOSTNAME=centos64.itrunc.com
```

* **NETWORKING**：表示系统是否使用网络，一般设置为yes，表示能使用网络。设为no则不能使用网络，许多系统服务程序也无法启动
* **HOSTNAME**：主机名

修改内容为：

```
NETWORKING=yes
NETWORKING_IPV6=no
HOSTNAME=centos64.itrunc.com
GATEWAY=192.168.100.2
```

添加了两个参数：

* **NETWORKING_IPV6**：表示是否使用IPV6，yes则使用IPV6，no则使用IPV4
* **GATEWAY**：网关IP地址，可向网管咨询。如果使用VMware虚拟机，可通过如下方式查看：编辑》虚拟网络编辑器》选择NAT模式的网卡》NAT设置

##/etc/sysconfig/network-scripts/ifcfg-eth0

这里主要设置IP地址、网络等，该文件初始内容如下：

```
DEVICE=eth0
TYPE=Ethernet
UUID=e77502c2-be8c-455d-87ef-9838c1bde482
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=dhcp
HWADDR=xx:xx:xx:xx:xx:xx
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth0"
```

* DEVICE：设备名称
* TYPE：网络类型
* UUID
* ONBOOT：是否启动系统时连接网络
* NM_CONTROLLED：是否使用net manager管理
* BOOTPROTO：IP地址类型，设为dhcp为自动获取，设为none或static为静态地址
* HWADDR：MAC地址
* DEFROUTE
* PEERDNS
* PEERROUTES
* IPV4_FAILURE_FATAL
* IPV6INIT
* NAME

修改为：

```
DEVICE=eth0
TYPE=Ethernet
UUID=e77502c2-be8c-455d-87ef-9838c1bde482
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
HWADDR=xx:xx:xx:xx:xx:xx
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth0"
IPADDR=192.168.100.19
NETMASK=255.255.255.0
# NETWORK=192.168.100.0
BROADCAST=192.168.100.255
```

* BOOTPROTO：将IP地址获取类型改为静态
* IPADDR：指定IP地址
* NETMASK 或 NETWORK：前者通过子网掩码来指定网段，后者直接指定网络
* BROADCAST：指定广播地址
  
##/etc/resolv.conf

这里主要设置DNS，该文件的初始内容如下：

```
domain localdomain
search localdomain itrunc.com
nameserver 192.168.100.2
```

可以添加更多的DNS服务器：

```
nameserver 8.8.8.8
```

添加google域名服务器
  
##/etc/hosts

这里主要设置主机名与IP地址的映射关系，主机只有一张网卡的话不需要修改。该文件初始内容如下：

```
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
```

可以选择性地添加一行：

```
192.168.100.19	centos64.itrunc.com
```

##重载网络配置

```
service network restart
```

或者

```
/etc/init.d/network restart
```