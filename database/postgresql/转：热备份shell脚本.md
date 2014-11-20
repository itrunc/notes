```sh
y=`date --date="1 days ago" +%Y`;
m=`date --date="1 days ago" +%m`;
d=`date --date="1 days ago" +%d`;
label=/'$y$m$d/'; #备份标签
/opt/pgsql/bin/psql -c "select pg_start_backup($label);"; #启动备份
cp -r /opt/pgsql/data /backup/databk;  #开始备份
/opt/pgsql/bin/psql -c "select pg_stop_backup();"; #结束备份
if [ $? ]
then
 echo "[hxf]  [`date`] hot backup database successfully!"; #备份成功
fi
```

转自[postgresql热备份shell脚本](http://blog.csdn.net/voipmaker/article/details/6059833)