#Oracle Business Intelligence快速安装指南

>注：下文将用Oracle BI作为Oracle Business Intelligence的简称

##安装概述

本文将介绍如何使用简易安装方式(Simple Install type)在单机环境中安装、配置、卸载Oracle BI。简易安装方式将以最少的步骤使用默认的设置来安装Oracle BI

>**提示**
>
>简易安装方式适合单机单用户环境，可用于示范、评估或开发。使用简易安装方式安装的Oracle BI不能添加其它组件进行扩展，也不能使用配置助手对实例进行配置。

###安装内容
Oracle BI包含如下产品：

* Oracle BI EE

  * Answers
  * Dashboards
  * Delivers
  * Repository Administration Tool
  * BI Job Manager
  * BI Catalog Manager
  * Oracle BI Add-in for Microsoft Office
  * Oracle BI Publisher
  * Oracle BI Composer

  >**提示**
  >
  >虽然你可以下载和安装 Oracle BI Add-in for Microsoft Office，但Oracle建议使用Smart View来下载和安装。更多信息请参考《[Oracle Fusion Middleware User's Guide for Oracle Business Intelligence Enterprise Edition](https://docs.oracle.com/cd/E28280_01/bi.1111/e10544/toc.htm)》中的"[Downloading BI Desktop Tools](https://docs.oracle.com/cd/E28280_01/bi.1111/e10544/getstart.htm#BIEUG13062)"

* Oracle BI Publisher

* Oracle Real-Time Decisions

* Oracle Essbase Suite

  关于Oracle BI中的Oracle Essbase的更多内容，请参考《[Oracle Fusion Middleware System Administrator's Guide for Oracle Business Intelligence Enterprise Edition](https://docs.oracle.com/cd/E28280_01/bi.1111/e10541/toc.htm)》中的"[Introduction to Using Essbase and Associated Components in Oracle Business Intelligence](https://docs.oracle.com/cd/E28280_01/bi.1111/e10541/essbase_intro.htm#BIESG6176)"

你可以使用以下任意一种产品组合方式来安装：

* Oracle Real-Time Decisions 或者 Oracle BI Publisher
* Oracle Real-Time Decisions 和 Oracle BI Publisher
* Oracle BI EE 和 Oracle BI Publisher
* Oracle BI EE、Oracle BI Publisher、Oracle Real-Time Decisions 或 Oracle Essbass Suite
* Oracle BI EE、Oracle BI Publisher、Oracle Real-Time Decisions、Oracle Essbase Suite

需要知道的是Oracle BI EE包含Oracle BI Publisher，因此安装Oracle BI EE时Oracle BI Publisher是自动选择安装的。如果你想要安装Oracle Essbase Suite，那么Oracle BI EE和Oracle BI Publisher是必须安装的。

Oracle BI 11g安装向导会为你选择安装的产品创建所需的所有基础组件，所有的已安装产品都需共享同一个WebLogic域下的相同的Oracle Fusion基础中间件。

使用一个WebLogic域的所有Oracle BI产品必须同时安装和配置。你不能安装部分产品，以后再在同一个WebLogic域下安装其他产品。例如，如果你选择安装Oracle BI EE而不安装Oracle Real-Time Decisions，那么以后在该WebLogic域下你不能再安装Oracle Real-Time Decisions。即是说任何已包含Oracle BI 11g产品的WebLogic域不能再扩展包含其他Oracle Fusion中间件产品。

###配置内容
当你选择简易方式安装，安装向导会为所有组件使用默认的配置参数。

你需要定义一个文件夹来安装Oracle BI，该文件夹会成为中间件主目录(Middleware home)。如果文件夹不存在，那么安装向导会为你创建它。如果你选择一个已存在的文件夹，那么文件夹内容必须为空。

更多的中间件主目录信息，请参考 [Oracle Fusion Middleware Installation Planning Guide](https://docs.oracle.com/cd/E28280_01/install.1111/b32474/toc.htm)

##系统需求与验证
这部分内容请参考以下在Oracle Technology Network上的文档：

* Oracle Fusion中间件系统需求、前提和规格，请参考 [Oracle Fusion Middleware System Requirements and Specifications](http://www.oracle.com/technetwork/middleware/ias/downloads/fusion-requirements-100147.html)。该文档包含硬件和软件需求的相关信息：磁盘空间、内存，以及所需的系统库、程序包、补丁。
* Oracle Fusion中间件验证，请参考 [Oracle Fusion Middleware Supported System Configurations](http://www.oracle.com/technetwork/middleware/ias/downloads/fusion-certification-100350.html)。该文档包含如下相关信息：支持的安装类型、平台、操作系统、数据库、JDK、和第三方产品
* 请阅读Oracle Fusion Middleware Release Notes中Oracle BI的相关章节

##安装前准备

在安装Oracle BI之前，你必须先执行以下任务：

###安装和配置数据库
Oracle BI的安装需要可用的数据库。数据库不必与安装组件同一机器，但必须已经启动。数据库必须兼容RCU，RCU将会在数据库中创建Oracle BI所需的schemas

>**提示** 
>
>RCU只在Linux和Windows操作系统上可用。

最新的数据库兼容信息，请参考[Oracle Fusion Middleware Certification document](http://www.oracle.com/technetwork/middleware/ias/downloads/fusion-certification-100350.html)。在你安装好数据库后，需确保数据库按照[Repository Creation Utility Requirements](http://www.oracle.com/technetwork/middleware/ias/downloads/fusion-requirements-100147.html)章节所描述的系统需求和规范进行配置。

###获取Repository Creation Utility(RCU)
RCU有独立的安装光盘，你也可以从OTN下载ZIP格式的安装包，下载地址：[Repository Creation Utility](http://www.oracle.com/technetwork/middleware/bi-enterprise-edition/downloads/bus-intelligence-11g-165436.html)。下载.zip文件后，解压到你选择好的一个目录中，该目录将作为 RCU_HOME 目录

>**提示** 
>
>在Windows系统中确保解压后的目录路径中没有空格。

RCU仅支持32位Linux和windows平台。无论是Linux RCU还是Windows RCU都可用在任意兼容的数据库平台创建所需的schemas

###启动RCU
步骤一：进入RCU安装程序所在目录（以下方式选一）

* 如果你有RCU安装光盘，那么插入光盘并进入bin目录
* 如果你从OTN下载zip文件并解压到RCU_HOME，那么进入该目录的bin目录

步骤二：根据你的操作系统类型执行安装程序

* UNIX
  
  ```bash
  ./rcu
  ```
* Windows
  
  ```bash
  rcu.bat
  ```

步骤三：选择安装或者卸载

* 如果你将要安装Oracle BI，那么使用RCU创建所需的schemas。请参考 [Section 3.4, "Creating Schemas for Oracle Business Intelligence."](https://docs.oracle.com/cd/E28280_01/bi.1111/e16518/toc.htm#CACJJDFD)
* 如果你将要卸载Oracle BI，那么使用RCU删除schemas。请参考 [Section 5.5, "Dropping the Oracle Business Intelligence Schemas."](https://docs.oracle.com/cd/E28280_01/bi.1111/e16518/toc.htm#CACEAHIC)

###为Oracle BI创建所需的Schemas
如果你将在Microsoft SQL Server或者IBM DB2数据库中为Oracle BI创建schemas，那么请先阅读 [System Requirements and Specification document](http://www.oracle.com/technetwork/middleware/ias/downloads/fusion-requirements-100147.html) 中的相关章节。基于Microsoft SQL Server安装请阅读《Creating Oracle Business Intelligence Schemas in a Microsoft SQL Server Database.》，基于IBM DB2安装请阅读《RCU Prerequisites for IBM DB2 Databases.》

* 启动RCU

  请参考上一节
  
* 欢迎界面

  点击 **Next**
  
* 创建仓库界面

  选择 **Create**，点击 **Next**
  
* 数据库链接设置界面

  如果你使用Oracle数据库，则提供如下信息：
  
  * 主机名(Host name)：数据库所在的主机的计算机名(格式：`host.domain.com`)，如果数据库为Oracle RAC，那么填虚拟IP名或者其中一个节点名
  * 端口(Port)：数据库监听端口号。Oracle数据库默认的端口号为1521
  * 数据库名(Database Name)：数据库服务名。数据库服务名可以从初始化参数文件中找SERVICE_NAMES参数。如果SERVICE_NAMES未定义，那么可使用由DB_NAME和DB_DOMAIN参数定义的全局数据库名。如果数据库为Oracle RAC，那么可使用其中一个节点的服务名，例如：`sales.foobar.com.example`
  * 用户名(Username)：拥有DBA或SYSDBA权限的用户名，默认为SYS
  * 密码(Password)：以上用户的密码
  * 角色(Role)：选择以上用户的角色，SYS用户必须是SYSDBA

  如果你使用Microsoft SQL Server数据库，则提供如下信息：
  
  * Unicode支持(Unicode Support)：在下拉框中选择 **Yes** 或者 **No**
  * 服务器名(Server Name)：可输入主机名、IP地址或完整的服务器域名
  * 端口号(Port)：数据库监听的端口号
  * 数据库名(Database Name)
  * 用户名(Username)：拥有DBA或SYSDBA权限的用户名
  * 密码(Password)：以上用户的密码
  
  如果你使用IBM DB2数据库，则提供如下信息：
  
  * 服务器名(Server Name)：数据库所在的主机名或IP地址或域名
  * 端口号(Port)：数据库监听的端口号
  * 数据库名(Database Name)
  * 用户名(Username)：拥有DB Owner权限的用户名
  * 密码(Password)：以上用户的密码
  
  点击 **Next**，会打开依赖检查界面。如果有错误，界面上会显示出错信息。需解决了所有错误之后再点击 **Next** 继续。如果检查全部通过，点击 **OK** 继续

* 选择组件界面

  在界面上方选择 **Create a new Prefix** 创建一个新的前缀。如果你是数据库示例的唯一用户，那么可以使用默认前缀 **DEV**。如果该数据库示例还会被其他中间件用户所用，那么请参考 [Oracle Fusion Middleware Repository Creation Utility User's Guide](https://docs.oracle.com/cd/E28280_01/doc.1111/e14259/toc.htm)。
  
  点击 **Business Intelligence** 复选框，这样就自动选择了Oracle BI所需的Metadata Services(MDS)和所使用的schemas
  
  >**提示** 
  >
  >* 如果你的组织已经在数据库中拥有一个MDS schema，你就不必再创建一个，而可以用现有的。如果这样，那么在界面上取消Metadata Services schema选项，转而配置已有的MDS schema的相关信息
  >* 不要选中 Oracle AS Repository Componets复选框，因为它会创建许多Oracle BI不需要的schemas
  >* 记住schema名称和前缀，你将会在后续的安装中需要它们。后续用到的schema名称是由前缀和本界面的名称联结的字符串，格式为`prefix_schemaname`。例如，你使用默认的前缀 `DEV`，并将schema设为 `BIPLATFORM`，那么完整的schema名为 `DEV_BIPLATFORM`
  
  点击 **Next**，则打开依赖检查界面。如果出错，界面上会显示错误信息，你需要解决所有错误后再点击 **Next** 以继续。如果检查通过，点击 **OK** 继续。

* Schema密码设置界面

  在界面上方选择 **User same password for all schemas**
  
  在密码输入框中输入密码，并在确认密码输入框中再次输入密码。
  
  >**提示** 
  >
  >记住schema的密码，你将在后续的安装中需要使用它

* 表空间映射界面

  点击 **Next**，则打开创建表空间的界面。如果有错误发生，则界面上将显示错误信息。你需要解决所有错误之后再点击 **Next** 以继续。如果创建成功，则点击 **OK** 继续。

* 安装信息概要界面

  点击 **Create**，则打开创建schema界面。如果有错误发生，则界面上会显示错误信息。你需要解决所有错误后再点击 **Next** 以继续。如果成功创建schema，则点击 **OK**继续

* 完成界面
  
  点击 **Close**。

关于Repository Creation Utility(RCU)的更多信息，请参考 [Oracle Fusion Middleware Repository Creation Utility User's Guide](https://docs.oracle.com/cd/E28280_01/doc.1111/e14259/toc.htm)

###获取Oracle BI 11g安装文件

Oracle BI 11g安装包以以下形式存在：

* Oracle BI 11g安装光盘
* [Oracle Technology Network(OTN)](http://www.oracle.com/technetwork/middleware/bi-enterprise-edition/downloads/bus-intelligence-11g-165436.html)
* [Oracle Software Delivery Cloud](http://edelivery.oracle.com/)

如果是从网上下载的zip文件，那么请解压到你指定的目录中。该目录将作为 `bi_installer_loc`。

>**提示** 
>
>在Windows系统中，请确保解压目录中不包含空格

##安装 Oracle BI

本节介绍如何使用Oracle BI 11g安装程序在Windows、Linux、UNIX操作系统安装Oracle BI。Oracle BI产品包含Oracle BI EE、Oracle BI Publisher、Oracle Essbase和Oracle Real-Time Decisions。Oracle BI 11安装程序将按照你所选择安装Oracle BI产品，并且自动对它们进行配置。

###在安装Oracle BI之前须知

在开始安装Oracle BI之前，请确保已完成以下内容：

* 阅读基于你所使用平台的文档Oracle Fusion Middleware Release Notes中关于Oracle Business Intelligence的章节，确保你能够理解Oracle BI和文档提及的功能的区别，以及当前发布版本的一些问题
* 阅读本文的 **安装概述** 章节，确保你能够理解安装Oracle BI过程中相关的选项和特性。
* 阅读本文的 **系统需求和验证** 章节，确保你的安装环境满足最小需求
* 在启动Oracle BI安装程序之前，确保数据库已安装并已经在运行
* 阅读本文的 **安装前准备** 章节，确保已经使用RCU创建了Oracle BI所需的schemas
* 确保你能够以系统管理员的权限启动安装程序。例如，在Windows7或Windows2008系统中，需以 **Run as Administrator**执行安装程序。
* 如果你将在一台以DHCP分配地址的机器上安装Oracle BI，那么你需要做一些额外的配置。请参考文档Oracle Fusion Middleware Installation Planning Guide中的章节 [Installing on DHCP Hosts](http://www.oracle.com/pls/topic/lookup?ctx=as111170&id=ASINS282)
* 需要注意，你不能使用相同的 MW_HOME 来安装 Enterprise Performance Management 和 Oracle BI。
* 如果你将在一台已安装 Oracle BI 10g 的机器上安装 Oracle BI 11g，那么请在安装 Oracle BI 11g之前关闭 Oracle BI 10g 实例。如果要将 Oracle BI 10g 升级到 11g，请参考文档 [Oracle Fusion Middleware Upgrade Guide for Oracle Business Intelligence](https://docs.oracle.com/cd/E28280_01/upgrade.1111/e16452/toc.htm)
* 如果将在Windows操作系统安装 Oracle BI 11g，需确保环境变量`_JAVA_OPTIONS`未被设置。可使用如下方式确保 _JAVA_OPTIONS 未被使用(选其一)：

  * 打开命令行，将当前目录转向`C:`，并执行命令`set _JAVA_OPTIONS`，如果返回信息`Environment variable _JAVA_OPTIONS not defined`，则变量未被使用
  * 右键“我的电脑” 》 “属性” 》“高级”，点击“环境变量”。在用户变量和系统变量中查找是否存在 _JAVA_OPTIONS。
  
  如果 _JAVA_OPTIONS 已设置，或者你有相关问题，请联系你的系统管理员咨询。

* 确保你的数据库没有为了安全做硬化(hardened)，Oracle BI不支持硬化数据库(hardened database)

###启动Oracle BI 11安装程序

打开命令行窗口，执行以下基于你的操作系统的命令以打开安装程序：

* UNIX
  
  ```bash
  cd bi_installer_loc/Disk1
  ./runInstaller.sh
  ```
  >提示
  >不支持使用root用户来执行Oracle 11g安装程序

* Windows
  
  ```bash
  cd bi_installer_loc\Disk1
  setup.exe
  ```

###安装过程

* 启动 Oracle BI 11g安装程序，请参考上一节
* 欢迎界面，点击 **Next**
* 安装升级界面，在如下选项中选择其一

  * Skip Software Updates (一般选中该项)
  
    你可以选中该选项，以跳过下载和安装软件的升级内容
    
  * Search My Oracle Support for Updates
  
    如果你拥有 My Oracle Support账户，你可以输入账户名和密码，则向导自动从 My Oracle Support上下载并安装升级包
    
    输入你的帐号信息后，你可以点击 **Test Connection** 测试链接
    
    如果你需要配置代理服务器，点击 **Proxy Settings**。打开代理设置界面，输入代理服务器地址、端口号、用户名、密码
  
  * Search Local Directory for Updates
  
    如果本地已有可升级的程序包，你可以启用该选项并配置路径。在本地路径输入框中输入升级包所在的目录，或者点击 **Browser** 浏览并选择目录
    
  点击 **Next** 以继续。

* 依赖检查界面
  
  安装程序会检查你的机器是否满足Oracle BI的所有依赖，如果不满足，则会显示错误信息。如果有错误发生，则解决所有错误后点击 **Retry** 重新检查依赖（推荐）。一直重复此操作直到满足所有依赖。
  
  如果需要退出安装进程来解决依赖错误，点击 **Abort**
  
  如果忽略错误或警告信息，点击 **Continue** 以继续安装（不推荐）
  
  >**提示** 
  >
  >如果你未解决所有依赖错误或警告，安装可能出现异常

  依赖检查完成，且全部通过后，点击 **Next**

* 选择安装类型

  默认地，选中了简易安装(Simple Install Type)。点击 **Next**
  
* 确定安装位置

  输入安装目录，或者点击 **Browser** 选择目录。如果你选择的目录已存在，则它必须是是一个空目录。如果目录不存在，则安装向导会创建它。安装向导会执行该目录为中间件主目录，并将在其中创建Oracle home、Instance home、WebLogic home和Domain home
  
  完成安装目录的定义后，点击 **Next**

* 管理员信息
  
  为系统管理员配置用户名和密码，点击 **Next**
  
* 配置需要安装的组件
  
  默认地，所有组件都会选中。保持所有组件选中，点击 **Next**
  
* BIPLATFORM Schema设置界面
  
  配置数据库类型、连接字符串、BIPLATFORM schema的用户名和密码
  
  连接字符串根据数据库类型参考以下格式：
  
  数据库类型 | 格式 | 描述 | 案例
  ---------- | ---- | ---- | ----
  Oracle | host:port:service_name | 完整的主机名:监听端口号:数据库服务名或别名 | mycomputer.foobar.com.example:1526:bi
  基于RAC的Oracle | host1:port1:instance1^host2:port2:instance2[@service_name] | 节点主机名:节点端口号:实例名，多个节点用^隔开。service_name为数据库服务名，可选 | computer1.foobar.com.example:1526:rac1^computer2.foobar.com.example:1526:rac2^computer3.foobar.com.example:1526:rac3@bi
  IBM DB2 | host:port:db_name | 主机名:端口号:数据库名 | mycomputer.foobar.com.example:446:mydatabase
  微软SQL Server | host:port:[instance_name]:db_name | instance_name为数据库实例名，是可选的，如果忽略则默认使用host中定义的实例名 | mycomputer.foobar.com.example:1443:yourinstance:mydatabase
  
  点击 **Next**

* MDS Schema设置界面

  配置数据库类型、连接字符串、MDS schema的用户名和密码
  
  连接字符串根据数据库类型参考上表
  
  点击 **Next**
  
* 安全升级界面

  输入你的 My Oracle Support 邮箱地址和密码(可选)，点击 **Next**
  
* 安装内容概要

  界面上显示所有配置好的安装设置，点击 **Install** 开始安装
  
* 安装进度界面

  界面上显示安装进度，无需任何操作
  
  >**提示** 
  >
  >在安装过程中，会弹出WebLogic Server命令行窗口。请忽略它，因为它会自动关闭
  
  当安装完成时，点击 **Next** 
  
* 进程配置界面

  如果配置失败，界面上会显示错误信息，解决所有错误并点击 **Retry** （推荐）。所有的错误和警告信息都可以在安装日志文件中找到，安装日志存储在：
  
  * UNIX
    
    ```
    USER_HOME/oraInventory/logs/
    ```
    
  * Windows
    
    ```
    C:\\Program Files\Oracle\Inventory\logs\
    ```
    
  如果不打算解决错误强制进入下一步，点击 **Continue** （不推荐）。中止安装和配置进程，点击 **Abort**。
  
  当配置完成且没有错误或警告发生时，点击 **Next**

* 安装完成界面

  记住界面上显示的URL地址和端口号，点击 **Finish**

###安装之后

当简易安装结束后，管理系统会启动，浏览器会打开并转到Oracle BI实例的首页。默认的Oracle BI地址：

组件 | 默认URL | 默认端口号
---- | ---- | ----
WebLogic Console | http://host:port/console | 7001
Enterprise Manager | http://host:port/em | 7001

##卸载 Oracle BI

(待续)

##参考文献
[1] [Fusion Middleware Quick Installation Guide for Oracle Business Intelligence](https://docs.oracle.com/cd/E28280_01/bi.1111/e16518/toc.htm)