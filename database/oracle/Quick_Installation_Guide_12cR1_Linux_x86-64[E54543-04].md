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
###支持Oracle Linux 5 和 Red Hat Enterprise Linux 5 的 x86-64 发行版
###支持SUSE的 x86-64 发行版

##Linux所需的其他驱动和软件包
##检查所需的软件需求
##创建所需的系统用户组和用户
##配置内核参数与资源限制
##创建所需的目录
##配置Oracle软件所属的环境变量
##挂载产品光盘
##安装Oracle数据库
##安装Oracle数据库示例