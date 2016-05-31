#在Windows cmd命令行中用VC编译C程序

##环境信息

- 操作系统：Windows 7
- 已安装软件：cmd, Visual Studio 2013

##Hello World

```C
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    printf("Hello World!");
    return EXIT_SUCCESS;
}
```

保存为 test.c 文件

##编译程序

打开 cmd 命令行。如果使用powershell，需切换为cmd。

切换当前目录到 test.c 文件所在的目录。

执行以下脚本

```
set VS_HOME=C:\Program Files (x86)\Microsoft Visual Studio 12.0
set PATH=%VS_HOME%\VC\bin;%PATH%
set INCLUDE=%VS_HOME%\VC\include
set LIB=%VS_HOME%\VC\lib;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Lib
cl test.c
```

###说明

- 设置PATH环境变量，cl.exe 在 Visual Studio 安装目录下的 VC\bin 中
- 设置INCLUDE环境变量，程序中包含的头文件需存在于该环境变量指定的目录中
- 设置LIB环境变量，编译时需要用到的库文件需存在于该环境变量指定的目录中

过程如下：

```
Windows PowerShell
版权所有 (C) 2013 Microsoft Corporation。保留所有权利。

PS C:\Users\pqpan> cmd
Microsoft Windows [版本 6.1.7601]
版权所有 (c) 2009 Microsoft Corporation。保留所有权利。

C:\Users\pqpan>cd /test

C:\test>ls
test.c

C:\test>set VS_HOME=C:\Program Files (x86)\Microsoft Visual Studio 12.0

C:\test>set PATH=%VS_HOME%\VC\bin;%PATH%

C:\test>set INCLUDE=%VS_HOME%\VC\include

C:\test>set LIB=%VS_HOME%\VC\lib;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Lib

C:\test>cl test.c
用于 x86 的 Microsoft (R) C/C++ 优化编译器 18.00.31101 版版权所有(C) Microsoft Corporation。  保留所有权利。

test.c
Microsoft (R) Incremental Linker Version 12.00.31101.0
Copyright (C) Microsoft Corporation.  All rights reserved.

/out:test.exe
test.obj

C:\test>.\test
Hello World!
C:\test>
```