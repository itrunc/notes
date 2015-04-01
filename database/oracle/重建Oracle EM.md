```
C:\Windows\System32>emctl status dbconsole
Environment variable ORACLE_UNQNAME not defined. Please set ORACLE_UNQNAME to database unique name.

C:\Windows\System32>set ORACLE_UNQNAME=orcl

C:\Windows\System32>emctl status dbconsole
OC4J Configuration issue. E:\app\Administrator\product\11.2.0\dbhome_1/oc4j/j2ee/OC4J_DBConsole_iss210002000579.isoftstone.com_orcl not found.

C:\Windows\System32>emca -deconfig dbcontrol db -repos drop

EMCA 开始于 2015-4-1 15:02:51
EM Configuration Assistant, 11.2.0.0.2 正式版
版权所有 (c) 2003, 2005, Oracle。保留所有权利。

输入以下信息:
数据库 SID: orcl
监听程序端口号: 1521
SYS 用户的口令:【此处输入密码，回车】
SYSMAN 用户的口令:【此处输入密码，回车】

是否继续? [是(Y)/否(N)]: y
2015-4-1 15:03:08 oracle.sysman.emcp.EMConfig perform
信息: 正在将此操作记录到 E:\app\Administrator\cfgtoollogs\emca\orcl\emca_2015_04_01_15_02_51.log。
2015-4-1 15:03:09 oracle.sysman.emcp.EMDBPreConfig performDeconfiguration
警告: 此数据库的 EM 尚未配置。无法执行特定于 EM 的操作。
2015-4-1 15:03:09 oracle.sysman.emcp.ParamsManager checkListenerStatusForDBControl
警告: 初始化 SQL 连接时出错。无法执行 SQL 操作
2015-4-1 15:03:09 oracle.sysman.emcp.EMReposConfig invoke
信息: 正在删除 EM 资料档案库 (此操作可能需要一段时间)...
2015-4-1 15:10:43 oracle.sysman.emcp.EMReposConfig invoke
信息: 已成功删除资料档案库
已成功完成 Enterprise Manager 的配置
EMCA 结束于 2015-4-1 15:10:46

C:\Windows\System32>sc delete OracleDBConsoleorcl
[SC] DeleteService 成功

C:\Windows\System32>emca -config dbcontrol db -repos create

EMCA 开始于 2015-4-1 15:27:41
EM Configuration Assistant, 11.2.0.0.2 正式版
版权所有 (c) 2003, 2005, Oracle。保留所有权利。

输入以下信息:
数据库 SID: orcl
监听程序端口号: 1521
监听程序 ORACLE_HOME [ E:\app\Administrator\product\11.2.0\dbhome_1 ]:【此处输入回车】
SYS 用户的口令:【此处输入密码，回车】
DBSNMP 用户的口令:【此处输入密码，回车】
SYSMAN 用户的口令:【此处输入密码，回车】
SYSMAN 用户的口令: 通知的电子邮件地址 (可选):【此处输入回车】
通知的发件 (SMTP) 服务器 (可选):【此处输入回车】
-----------------------------------------------------------------

已指定以下设置

数据库 ORACLE_HOME ................ E:\app\Administrator\product\11.2.0\dbhome_1


本地主机名 ................ iss210002000579.isoftstone.com
监听程序 ORACLE_HOME ................ E:\app\Administrator\product\11.2.0\dbhome_1
监听程序端口号 ................ 1521
数据库 SID ................ orcl
通知的电子邮件地址 ...............
通知的发件 (SMTP) 服务器 ...............

-----------------------------------------------------------------
是否继续? [是(Y)/否(N)]: y
2015-4-1 15:28:48 oracle.sysman.emcp.EMConfig perform
信息: 正在将此操作记录到 E:\app\Administrator\cfgtoollogs\emca\orcl\emca_2015_04_01_15_27_41.log。
2015-4-1 15:28:52 oracle.sysman.emcp.EMReposConfig createRepository
信息: 正在创建 EM 资料档案库 (此操作可能需要一段时间)...
2015-4-1 15:54:52 oracle.sysman.emcp.EMReposConfig invoke
信息: 已成功创建资料档案库
2015-4-1 15:55:24 oracle.sysman.emcp.EMReposConfig uploadConfigDataToRepository
信息: 正在将配置数据上载到 EM 资料档案库 (此操作可能需要一段时间)...
2015-4-1 15:56:41 oracle.sysman.emcp.EMReposConfig invoke
信息: 已成功上载配置数据
2015-4-1 15:57:03 oracle.sysman.emcp.util.DBControlUtil configureSoftwareLib
信息: 软件库已配置成功。
2015-4-1 15:57:03 oracle.sysman.emcp.EMDBPostConfig configureSoftwareLibrary
信息: 正在部署预配档案...
2015-4-1 15:58:17 oracle.sysman.emcp.EMDBPostConfig configureSoftwareLibrary
信息: 预配档案部署成功。
2015-4-1 15:58:17 oracle.sysman.emcp.util.DBControlUtil secureDBConsole
信息: 正在保护 Database Control (此操作可能需要一段时间)...
2015-4-1 15:58:35 oracle.sysman.emcp.util.DBControlUtil secureDBConsole
信息: 已成功保护 Database Control。
2015-4-1 15:58:35 oracle.sysman.emcp.util.DBControlUtil startOMS
信息: 正在启动 Database Control (此操作可能需要一段时间)...
2015-4-1 16:05:21 oracle.sysman.emcp.EMDBPostConfig performConfiguration
信息: 已成功启动 Database Control
2015-4-1 16:05:23 oracle.sysman.emcp.EMDBPostConfig performConfiguration
信息: >>>>>>>>>>> Database Control URL 为 https://iss210002000579.isoftstone.com:5500/em <<<<<<<<<<<
2015-4-1 16:05:25 oracle.sysman.emcp.EMDBPostConfig invoke
警告:
************************  WARNING  ************************

管理资料档案库已置于安全模式下, 在此模式下将对 Enterprise Manager 数据进行加密。
加密密钥已放置在文件 E:/app/Administrator/product/11.2.0/dbhome_1/iss210002000579.isoftstone.com_orcl/sysman/config/emkey.ora 中。请务必备份此文件, 因为如果此文件丢失, 则加密数据将不可用。

***********************************************************
已成功完成 Enterprise Manager 的配置
EMCA 结束于 2015-4-1 16:05:25

```

```
C:\Windows\System32>emctl status dbconsole
Environment variable ORACLE_UNQNAME not defined. Please set ORACLE_UNQNAME to database unique name.

C:\Windows\System32>set ORACLE_UNQNAME=orcl

C:\Windows\System32>emctl status dbconsole
Oracle Enterprise Manager 11g Database Control Release 11.2.0.1.0
Copyright (c) 1996, 2010 Oracle Corporation.  All rights reserved.
https://iss210002000579.isoftstone.com:5500/em/console/aboutApplication
Oracle Enterprise Manager 11g is running.
------------------------------------------------------------------
Logs are generated in directory E:\app\Administrator\product\11.2.0\dbhome_1/iss210002000579.isoftstone.com_orcl/sysman/log
```