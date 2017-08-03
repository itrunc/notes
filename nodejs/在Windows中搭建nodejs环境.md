# 在Windows中搭建nodejs环境

Download Window Binary (.zip) from nodejs.org, and then extract to the path C:\node-v6.11.2-win-x64

## Set environment variable

```
SETX NODE_HOME "C:\node-v6.11.2-win-x64"
SETX NODE_PATH "%NODE_HOME%\node_modules"
SETX PATH "%PATH%:%NODE_HOME%"
```

## How to install global modules offline

Download the package *.tar.gz, and then run below command

```
npm install path/to/*.tar.gz -g
```
