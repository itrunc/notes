###如何将github项目push到git@osc

虽然github是最牛逼的托管代码的地方，但是在天朝的网络环境下，多数时候得用龟速访问。因此同时将项目托管到国内相关的站点上是一个不错的选择。oschina的git就做得很不错，每个帐号可建1000个项目，不限私有项目和共有项目，免费。

在oschina创建项目：https://git.oschina.net/gomac/notes.git，或者在绑定github帐号后从github导入项目。

假设本地已经存在项目，若未存在可使用如下命令从github复制到本地
```bash
git clone https://github.com/itrunc/notes.git
```

进入项目所在目录

使用如下命令为项目添加一个远程仓库
```bash
git remote add osc https://git.oschina.net/gomac/notes.git
```

如果查看.git/config文件会发现，文件内容多了以下内容：
```
[remote "osc"]
	url = https://git.oschina.net/gomac/notes.git
	fetch = +refs/heads/*:refs/remotes/osc/*
```

然后，如果需要将项目push到oschina，则使用如下命令：
```bash
git push -u osc
```
