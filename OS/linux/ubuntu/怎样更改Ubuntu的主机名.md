#怎样更改Ubuntu的主机名

修改主机名只需修改两个配置文件：/etc/hostname 和 /etc/hosts

修改 /etc/hostname，该文件只有一行，即主机名。

```bash
vi /etc/hostname
```

用新的主机名替换该文件的内容。

由于 /etc/hosts 配置了主机名和网络地址的映射关系，所以我们修改了主机名之后需立即更新该文件。

```bash
vi /etc/hosts
```

```
127.0.0.1	localhost
127.0.1.1	**itrunc.newname**

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

>**提示**
>
>在非必须更改主机名的情况下，不要去修改它，因为可能导致一些应用程序异常。