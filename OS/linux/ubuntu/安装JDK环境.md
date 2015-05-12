#安装JDK环境

解压

```
tar -zxvf jdk-8u5-linux-x64.tar.gz
```

将解压包移动到/usr/lib/jvm/java

```
sudo mkdir /usr/lib/jvm
sudo mv jdk1.8.0_05 /usr/lib/jvm/java
sudo chown -R root:root java
```

配置环境变量

```
sudo vim ~/.bashrc
```

在中间中添加以下内容：

```
export JAVA_HOME=/usr/lib/jvm/java 
export JRE_HOME=${JAVA_HOME}/jre  
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib  
export PATH=${JAVA_HOME}/bin:$PATH
```

```
source ~/.bashrc
```