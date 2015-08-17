#区间分区表（Range Partitioned Table）

区间分区表使用 key(s) 和 VALUES LESS THAN指定分区的范围。VALUES LESS THAN的计算方式为**严格小于**

```sql
--创建表空间
CREATE TABLESPACE tp_ldr201401 DATAFILE 'ldr201401.dbf' size 100M autoextend on next 20M maxsize unlimited;
CREATE TABLESPACE tp_ldr201402 DATAFILE 'ldr201402.dbf' size 100M autoextend on next 20M maxsize unlimited;

--创建分区表
CREATE TABLE leadership(
  market     VARCHAR2(3),
  campaign   NUMBER(6),
  memberid   VARCHAR2(20),
  leaderid   VARCHAR2(20),
  roleid     VARCHAR2(10),
  sales      NUMBER(10,2)
)
PARTITION BY RANGE(campaign)
(
  PARTITION ldr201401 VALUES LESS THAN(201402) TABLESPACE tp_ldr201401
 ,PARTITION ldr201402 VALUES LESS THAN(201403) TABLESPACE tp_ldr201402
);

--插入数据
INSERT INTO leadership(market,campaign,memberid,leaderid,roleid,sales)
 VALUES('DAT',201401,'001','0','R-REP',100);

INSERT INTO leadership(market,campaign,memberid,leaderid,roleid,sales)
 VALUES('DAT',201402,'001','0','R-REP',100);
INSERT INTO leadership(market,campaign,memberid,leaderid,roleid,sales)
 VALUES('DAT',201402,'002','0','R-REP',100);

COMMIT;
```

试着插入超出范围的记录：

```
SQL> INSERT INTO leadership(market,campaign,memberid,leaderid,roleid,sales)
  2  VALUES('DAT',201403,'001','0','R-REP',100);
INSERT INTO leadership(market,campaign,memberid,leaderid,roleid,sales)
            *
ERROR at line 1:
ORA-14400: inserted partition key does not map to any partition
```

##查询

```
SQL> SELECT * FROM leadership;

MAR   CAMPAIGN MEMBERID             LEADERID             ROLEID          SALES
--- ---------- -------------------- -------------------- ---------- ----------
DAT     201401 001                  0                    R-REP             100
DAT     201402 001                  0                    R-REP             100
DAT     201402 002                  0                    R-REP             100

SQL> SELECT * FROM leadership PARTITION (ldr201402);

MAR   CAMPAIGN MEMBERID             LEADERID             ROLEID          SALES
--- ---------- -------------------- -------------------- ---------- ----------
DAT     201402 001                  0                    R-REP             100
DAT     201402 002                  0                    R-REP             100
```

##添加分区

```sql
--创建表空间
CREATE TABLESPACE tp_ldr201403 DATAFILE 'ldr201403.dbf' size 100M autoextend on next 20M maxsize unlimited;

--添加分区
ALTER TABLE leadership 
  ADD PARTITION ldr201403 VALUES LESS THAN(201404) 
  TABLESPACE tp_ldr201403 
  STORAGE(INITIAL 20K NEXT 10K) LOGGING;
```

查看对象：

```
SQL> select object_name,subobject_name,object_id,object_type,status
  2  from user_objects where object_name='LEADERSHIP'
  3  order by object_id;

OBJECT_NAME    SUBOBJECT_NAME    OBJECT_ID OBJECT_TYPE         STATUS
-------------- ---------------- ---------- ------------------- -------
LEADERSHIP                           80181 TABLE               VALID
LEADERSHIP     LDR201401             80182 TABLE PARTITION     VALID
LEADERSHIP     LDR201402             80183 TABLE PARTITION     VALID
LEADERSHIP     LDR201403             80184 TABLE PARTITION     VALID
```

可见，表分区是以对象的形式存在的，它可以指定表空间以及其它的存储信息。

```
SQL> select table_name,composite,partition_name,subpartition_count,high_value
  2        ,tablespace_name,initial_extent,next_extent
  3  from user_tab_partitions
  4  where table_name='LEADERSHIP'
  5  order by partition_position;

TABLE_NAME     COMPOSITE  PARTITION_NAME   SUBPARTITION_COUNT HIGH_VALUE TABLESPACE_NAME  INITIAL_EXTENT NEXT_EXTENT
-------------- ---------- ---------------- ------------------ ---------- ---------------- -------------- -----------
LEADERSHIP     NO         LDR201401                         0 201402     TP_LDR201401              65536     1048576
LEADERSHIP     NO         LDR201402                         0 201403     TP_LDR201402              65536     1048576
LEADERSHIP     NO         LDR201403                         0 201404     TP_LDR201403              24576       16384
```

