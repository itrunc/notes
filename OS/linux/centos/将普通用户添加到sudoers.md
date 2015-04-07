#CentOS将普通用户添加到sudoers中

打开终端（应用程序 > 系统工具 > 终端），输入命令：

```bash
su -
```

输入root用户的密码，回车进入root。

输入命令：

```bash
visudo
```

进入sudoers的编辑状态，找到以下行：

```
# %wheel	ALL=(ALL)	ALL
```

将行首的 # 去掉，保存。

为用户添加用户组：

```bash
usermod -aG wheel ben
```

以上命令为用户ben添加用户组wheel。

重启系统。

```bash
reboot
```
