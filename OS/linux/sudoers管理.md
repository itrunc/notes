#sudoers管理

在Linux中可以使用 sudo 来使用其他用户（非当前登录用户）的权限执行命令。只有通过授权的用户才能使用 sudo，有sudo权限的用户成为 sudoers。sudoers是通过文件 /etc/sudoers 进行配置的。

```
$ ll /etc | grep sudo
-r--r-----   1 root root      745  2月 11  2014 sudoers
drwxr-xr-x   2 root root     4096  4月 17  2014 sudoers.d/
```

/etc/sudoers 涉及到系统很高级别的安全性，因此它的权限被设为 440，即任何用户（包括root）都不能直接修改它。当然，你可以使用 chmod 来修改权限，但不建议这么做。因为系统提供了 visudo 命令来编辑 sudoers，当然 visudo需要用root用户来执行。

让我们先来看看ubuntu默认是怎样来配置sudoers的。

```bash
sudo cat /etc/sudoers
```

```
#
# This file MUST be edited with the 'visudo' command as root.
#
# Please consider adding local content in /etc/sudoers.d/ instead of
# directly modifying this file.
#
# See the man page for details on how to write a sudoers file.
#
Defaults	env_reset
Defaults	mail_badpass
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root	ALL=(ALL:ALL) ALL

# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL

# Allow members of group sudo to execute any command
%sudo	ALL=(ALL:ALL) ALL

# See sudoers(5) for more information on "#include" directives:

#includedir /etc/sudoers.d
```

sudoers的配置格式（使用 man sudoers查看更多）为

```
who where=(as_whom) what
```

由以上配置文件内容可见，在User privilege specification部分只配置了 root可以以任何分组任何用户身份执行任何命令。然后配置两个group：admin和sudo，可以以任何用户身份执行任何命令。ubuntu中在正常情况下，用户是无法知道root的密码的，因为默认用户可以使用 sudo来执行所有需要root才能执行的命令。然而用户并未在sudoers配置文件里出现。

来看一下用户panpching的基本信息：

```
$ sudo cat /etc/passwd | grep panpching
panpching:x:1000:1000:panpching,,,:/home/panpching:/bin/bash
```

```
$ sudo cat /etc/group | grep panpching
adm:x:4:syslog,panpching
cdrom:x:24:panpching
sudo:x:27:panpching
dip:x:30:panpching
plugdev:x:46:panpching
lpadmin:x:108:panpching
panpching:x:1000:
sambashare:x:124:panpching
```

可见用户 panpching是从属于分组 sudo的。

假设现在有另一个用户 itrunc，我们如何将他加入sudoers呢？只需要将它加到 sudo组中就行了。

```bash
usermod -aG sudo itrunc
```

然而像 CentOS这种允许用户自己设置root密码，并且使用root登陆的系统，并没有为sudoers做那么多的配置（默认只在sudoers配置文件中为root做了配置）。在这种情况下将普通用户设为sudoers有多种方法：

* 方法一：使用命令 `su -` 切换到 root用户，并使用命令 `visudo` 进入编辑sudoers配置，并在其中添加一行 `username ALL=(ALL) ALL`
* 方法二：按照ubuntu的方式进行配置，即在添加一个用户组sudo，并在sudoers中配置用户组sudo的相关权限：
  
    ```
    su - #输入密码后切换到 root
    groupadd sudo #创建用户组sudo
    visudo #进入编辑sudoers，在其中添加一行：%sudo ALL=(ALL) ALL
    usermod -aG sudo username #保存后将用户添加到用户组 sudo中即可
    ```












