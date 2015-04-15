#在Ubuntu中搭建nodejs环境

nodejs下载页面：

```
https://nodejs.org/download/
```

根据操作系统版本选择下载软件包：Linux Binaries(.tar.gz)，这个软件包是已经编译过的，下载后解压即可用。

解压：

```
panben@ubuntu:~/Downloads$ tar zxvf node-v0.12.2-linux-x64.tar.gz
```

移动：

```
panben@ubuntu:~/Downloads$ sudo cp -R node-v0.12.2-linux-x64 /opt/nodejs
```

修改环境变量。

编辑文件：

```
panben@ubuntu:~$ vi ~/.profile
```

追加以下2行：

```
PATH="/opt/nodejs/bin:$PATH"
NODE_PATH="/opt/nodejs:/opt/nodejs/lib/node_modules"
```

保存后，执行

```
panben@ubuntu:~$ source ~/.profile
```

测试：

```
panben@ubuntu:~$ node -v
v0.12.2
panben@ubuntu:~$ npm -v
2.7.4
```

做一下链接

```
sudo ln -s /opt/nodejs/bin/node /usr/bin/node
sudo ln -s /opt/nodejs/bin/npm /usr/bin/npm
```