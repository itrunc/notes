#Oracle数据库快速安装指南

* 版本：12c Release 1
* 平台：Linux x86-64
* 编号：[E54543-04](http://docs.oracle.com/database/121/LTDQI/toc.htm)
* 日期：2014年10月
* 译者：大人一号
* 翻译日期：2015年3月27日

##概述

该指南将描述如何使用默认的安装选项来安装Oracle数据库。

###该指南包括以下内容：

* 配置操作系统以支持Oracle数据库
* 使用典型的安装选项在本地文件系统中安装Oracle数据库
* 配置一个通用的数据库

###成功安装Oracle数据库后：

* 运行数据库和默认的Oracle网络监听程序
* 运行Oracle数据库企业管理器(Oracle Enterprise Manager Database Express)，并且可使用浏览器进行访问

###该指南不包含的内容：

* 使用高级安装选项安装软件
* 在一个已经安装Oracle软件的系统中安装软件
* 安装Oracle集群和RAC(Oracle Real Application Clusters)
* 手工配置UDP和TCP内核参数
* 使用如ASM(Oracle Automatic Storage Management)的存储选项
* 安装和配置Oracle网格基础组件(Oracle Grid Infrastructure)
* 自动配置预安装Oracle的Oracle Linux
* 检查已挂载的共享内存文件系统

###获得更多的安装信息，请参考：

* 如果你想要在单机中安装Oracle，请参考：[Oracle Database Installation Guide for Linux](http://docs.oracle.com/database/121/LADBI/toc.htm)
* 如果你想要在一个独立的服务器上安装oracle网格组件，请参考 [Oracle Database Installation Guide for Linux](http://docs.oracle.com/database/121/LADBI/toc.htm) 中的 [Oracle Grid Infrastructure](http://docs.oracle.com/database/121/LADBI/oraclerestart.htm#LADBI999) 章节
* 如果你想要安装Oracle RAC，请参考 [Oracle Grid Infrastructure Installation Guide for Linux](http://docs.oracle.com/database/121/CWLIN/toc.htm) 和 [Oracle Real Application Clusters Installation Guide for Linux and UNIX](http://docs.oracle.com/database/121/RILIN/toc.htm)。这些指南会描述如何安装Oracle集群和Oracle RAC。

##以root用户登录系统

在安装过程中必须使用root用户来执行相关操作。

(此处省略部分内容)

##配置Oracle数据库

###检查服务器硬件和内存配置

可执行以下命令检查当前操作系统信息：

* 执行以下命令可确定物理内存大小

  ```bash
  grep MemTotal /proc/meminfo
  ```

  如果物理内存无法满足最小的内存需求，那么在继续安装之前，你需要为机器添加内存。

* 执行以下命令可确定已分配的交换区(swap)大小

  ```bash
  grep SwapTotal /proc/meminfo
  ```

  如果需要增加交换区，可参考操作系统相关的文档。

* 执行以下命令可确定可用的临时目录(/tmp)大小

  ```bash
  df -h /tmp
  ```

* 执行以下命令可确定磁盘空间大小

  ```bash
  df -h
  ```

* 执行以下命令可确定空闲内存(RAM)和交换区(swap)大小

  ```bash
  free
  ```

* 执行以下命令可确定系统架构信息

  ```bash
  uname -m
  ```
  
  需验证处理器的架构。例如必须在以上命令的执行结果中包含 `x86_64` 。

###常规需求

* 确保系统运行在 runlevel 3 或 runlevel 5
* 确保显卡支持1024×768以上的分辨率。

###存储需求

* 确保系统磁盘满足如下列出的最小需求

  安装类型 | 磁盘空间
  --------|---------
  企业版(Enterprise Edition) | 6.4GB
  标准版(Standard Edition) | 6.1GB
  单机标准版(Standard Edition One) | 6.1GB

  额外的磁盘空间需求，无论是在文件系统还是Oracle ASM上安装，都必须预留快速闪回区(fast recovery area)的磁盘空间

* 临时目录 /tmp 空间需求为 1GB

  如果该目录的空间没有满足需求，可按照如下方式进行改造：
  
  * 删除该目录下无用的文件，以达到所需的空闲空间
  * 专门为 oracle 用户设置 TMP 和 TMPDIR 环境变量
  * 扩展 /tmp 目录的空间大小

###内存需求

物理内存的最小需求是 1GB，推荐 2GB 或以上

下表描述物理内存大小与其对应的交换区大小建议

内存大小 | 交换区空间
--------|-----------
1GB ~ 2GB | 1.5倍内存
2GB ~ 16GB | 与内存相同大小
大于 16GB | 16GB

##检查操作系统的安全性

确保操作系统是安全的

##操作系统需求

根据你将要安装的产品去验证所需的操作系统内核和已安装的程序包。

本文档列出的相关需求只针对本文头部显示的日期有效。更多的内核需求信息可参考[OTN](http://www.oracle.com/technetwork/indexes/documentation/index.html)上的资料。

OUI(Oracle Universal Installer)会执行系统检查以验证所需的程序包已安装，请在启动OUI前进行验证以确保检查顺利通过。

>**提示**
>
>除非系统进行升级，oracle不支持集群中的节点使用不同的操作系统，那么这些操作系统都支持Oracle。

##x86-64 Linux平台下的操作系统需求

以下列出的需求仅针对在x86-64平台发布的Linux适用。

>**提示**
>
>* The Oracle Unbreakable Enterprise Kernel can be installed on x86-64 servers running either Oracle Linux 5 Update 5, or Red Hat Enterprise Linux 5 Update 5. As of Oracle Linux 5 Update 6, the Oracle Unbreakable Enterprise Kernel is the default system kernel. An x86 (32-bit) release of Oracle Linux including the Oracle Unbreakable Enterprise Kernel is available with Oracle Linux 5 update 7 and later.
>* The 32-bit packages listed in the following sections are required only for 32-bit client installs.

###支持Oracle Linux 7 和 Red Hat Enterprise Linux 7 的 x86-64 发行版
###支持Oracle Linux 6 和 Red Hat Enterprise Linux 6 的 x86-64 发行版

参考以下信息来检查Oracle Linux 6和Red Hat Linux 6发行版：

* SSH
  
  确保已安装OpenSSH。
  
* Oracle Linux 6
  
  在Unbreakable Linux Network上订阅Oracle Linux 6频道，或者配置Oracle公共yum为一个yum仓库，然后安装Oracle预装的RPM。RPM可安装所有Oracle基础组建所需的内核包，用于安装Oracle数据库，以及其他的系统配置。支持以下发行版：
  
  * Oracle Linux 6 with the Unbreakable Enterprise kernel: 2.6.39-200.24.1.el6uek.x86_64 及以上
  * Oracle Linux 6 with the Red Hat Compatible kernel: 2.6.32-71.el6.x86_64 及以上
	
* Red Hat Enterprise Linux 6
  
  支持以下发行版：
  
  * Red Hat Enterprise Linux 6: 2.6.32-71.el6.x86_64 及以上
  * Red Hat Enterprise Linux 6 with the Unbreakable Enterprise Kernel: 2.6.32-100.28.5.el6.x86_64及以上

* Packages for Oracle Linux 6 and Red Hat Enterprise Linux 6
  
  必须已安装以下包（或更高版本）：
  
  ```
  binutils-2.20.51.0.2-5.11.el6 (x86_64)
  compat-libcap1-1.10-1 (x86_64)
  compat-libstdc++-33-3.2.3-69.el6 (x86_64)
  compat-libstdc++-33-3.2.3-69.el6 (i686)
  gcc-4.4.4-13.el6 (x86_64)
  gcc-c++-4.4.4-13.el6 (x86_64)
  glibc-2.12-1.7.el6 (i686)
  glibc-2.12-1.7.el6 (x86_64)
  glibc-devel-2.12-1.7.el6 (x86_64)
  glibc-devel-2.12-1.7.el6 (i686)
  ksh
  libgcc-4.4.4-13.el6 (i686)
  libgcc-4.4.4-13.el6 (x86_64)
  libstdc++-4.4.4-13.el6 (x86_64)
  libstdc++-4.4.4-13.el6 (i686)
  libstdc++-devel-4.4.4-13.el6 (x86_64)
  libstdc++-devel-4.4.4-13.el6 (i686)
  libaio-0.3.107-10.el6 (x86_64)
  libaio-0.3.107-10.el6 (i686)
  libaio-devel-0.3.107-10.el6 (x86_64)
  libaio-devel-0.3.107-10.el6 (i686)
  libXext-1.1 (x86_64)
  libXext-1.1 (i686)
  libXtst-1.0.99.2 (x86_64)
  libXtst-1.0.99.2 (i686)
  libX11-1.3 (x86_64)
  libX11-1.3 (i686)
  libXau-1.0.5 (x86_64)
  libXau-1.0.5 (i686)
  libxcb-1.5 (x86_64)
  libxcb-1.5 (i686)
  libXi-1.3 (x86_64)
  libXi-1.3 (i686)
  make-3.81-19.el6
  sysstat-9.0.4-11.el6 (x86_64)
  ```

###支持Oracle Linux 5 和 Red Hat Enterprise Linux 5 的 x86-64 发行版
###支持SUSE的 x86-64 发行版

##Linux额外所需的其他驱动和软件包

以下驱动和程序包并非必须安装，但你可以选择性地按如下指引进行安装。

###Open Database Connectivity的安装
###Linux上PAM的安装
###Oracle Messaging Gateway的安装
###Lightweight Directory Access Protocol的安装
###Linux开发环境的安装

确保你的系统按照如下开发环境需求进行配置：

* Java Database Connectivity
  
  Oracle Java Database Connectivity需要包含JNDI扩展的JDK 6（1.6.0_37，或1.6的更高更新版）
  
* Oracle Call Interface(OCI)
  
  OCI需要包含JNDI扩展的JDK 6（1.6.0_37，或1.6的更高更新版）
  
* Oracle C++ / Oracle C++ Call Interface / Pro*C/C++ / Oracle XML Developer's Kit(XDK)
  
  此处省略
  
* Pro*COBOL
  
  Micro Focus Server Express 5.1

###Web浏览器的安装

##检查所需的软件

可按照以下步骤检查系统是否已满足软件需求

1. 断定Linux的发行版
  
  ```bash
  cat /etc/oracle-release
  cat /etc/redhat-release
  lsb_release -id
  ```
  
2. 断定内核是否所需的版本
  
  ```bash
  uname -r
  ```
  
  Oracle Linux 6将显示：
  
  ```
  2.6.39-100.7.1.el6uek.x86_64
  ```
  
  Review the required errata level for your distribution. If the errata level is previous to the required minimum errata update, then obtain and install the latest kernel update from your Linux distributor.

3. 断定是否已经安装了所需的软件包：
  
  ```bash
  rpm -q package_name
  ```
  
  如果你还想了解特殊的系统结构信息，使用如下命令：
  
  ```bash
  rpm -qa --queryformat "%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n" | grep package_name
  ```
  
  你也可以一次性检查多个程序包：
  
  ```bash
  rpm -q binutils compat-libstdc++ gcc glibc libaio libgcc libstdc++ make sysstat unixodbc
  ```
  
  如果所需的程序未安装，则请从Linux光盘或者网上安装所依赖的程序包。

##创建所需的系统用户组和用户

安装oracle需要以下用户组和用户

* The Oracle Inventory group (如，oinstall)
* The OSDBA group (如，dba)
* The Oracle软件所有者 (如，oracle)
* The OSOPER group (可选的，如，oper)

###检查oinstall组是否已存在

```bash
more /etc/oraInst.loc
```

如果以上显示oinstall组名，则用户组已经存在。如果oraInst.loc文件存在，则它的内容如下：

```
inventory_loc=/u01/app/oraInventory
inst_group=oinstall
```

###检查dba组是否存在

```bash
grep dba /etc/group
```

如果以上命令输出中显示dba组名，则存在。

###如果有需要，输入一下命令创建oinstall和dba组

```bash
/usr/sbin/groupadd oinstall
/usr/sbin/groupadd dba
```

###检查oracle用户是否存在，并且属于正确的用户组

```bash
id oracle
```

如果用户oracle存在，以上命令会显示它所属的用户组的信息。命令的输入与以下内容类似：

```
uid=440(oracle) gid=200(oinstall) groups=201(dba),202(oper)
```

###如果有需要，修改用户oracle

* 如果oracle用户已存在，但它的主要用户组不是oinstall，或者它不是dba组成员
  
  ```bash
  /usr/sbin/usermod -g oinstall -G dba oracle
  ```
  
* 如果oracle用户不存在
  
  ```bash
  /usr/sbin/useradd -g oinstall -G dba oracle
  ```
  
  以上命令会创建oracle用户，并且它的主要用户组为oinstall，它还属于dba组。

###使用以下命令设置oralce用户的密码

```bash
passwd oracle
```

##配置内核参数与资源限制

验证下表中的内核参数数值比表中的提供的最小值大。以下仅提供最小值，Oracle建议在生产环境中需调整这些参数值以优化系统性能。

参数 | 最小值 | 文件
------ | ------ | ------
semmsl | 250 | /proc/sys/kernel/sem
semmns | 32000 | 同上
semopm | 100 | 同上
semmni | 128 | 同上
shmall | 40%的物理内存（按页）。如果oracle软件支持多个数据库或者使用一个大SGA，那么该值需设为总数 | /proc/sys/kernel/shmall
shmmax | 物理内存的一半（按字节） | /proc/sys/kernel/shmmax
shmmni | 4096 | /proc/sys/kernel/shmmni
panic_on_oops | 1 | /proc/sys/kernel/panic_on_oops
file-max | 6815744 | /proc/sys/fs/file-max
ip_local_port_range | 最小9000，最大65500 | /proc/sys/net/ipv4/ip_local_port/range
rmem_default | 262144 | /proc/sys/net/core/rmem_default
rmem_max | 4194304 | /proc/sys/net/core/rmem_max
wmem_default | 262144 | /proc/sys/net/core/wmem_default
wmem_max | 1048576 | /proc/sys/net/core/wmem_max
aio-max-nr | 1048576，该参数限制并发，需设为某个值以避免I/O失败 | /proc/sys/fs/aio-max-nr

>**提示**
>
>如果这些参数的当前值比以上建议的最小值大，那么无需修改

##创建所需的目录
##配置Oracle软件所属的环境变量
##挂载产品光盘
##安装Oracle数据库
##安装Oracle数据库示例