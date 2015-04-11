#解决BIEE控制台中文乱码的问题

BIEE安装在 E:\app\BIEE11G，

那么打开文件：

```
E:\app\BIEE11G\user_projects\domains\bifoundation_domain\bin\setDomainEnv.cmd，
```

查找这一行：

```
set JAVA_OPTIONS=%JAVA_OPTIONS%
```

大概在第448行，最后一次设置JAVA_OPTIONS。

修改为：

```
set JAVA_OPTIONS=%JAVA_OPTIONS% -Dfile.encoding=GBK
```

因为简体中文版windows命令行的默认字符集编码是GBK