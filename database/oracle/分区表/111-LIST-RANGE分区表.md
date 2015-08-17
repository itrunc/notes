#LIST-RANGE分区表

##创建分区表

以下语句创建分区表 leadership，先以 market 作为 key 进行 LIST 分区，再以 campaign 进行 RANGE 划分子分区。每个子分区存储于独立的表空间。

```sql
--创建表空间
CREATE TABLESPACE tp_ldr_aus_201401 DATAFILE 'ldr_aus_201401.dbf' SIZE 100M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED;
CREATE TABLESPACE tp_ldr_aus_201402 DATAFILE 'ldr_aus_201402.dbf' SIZE 100M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED;

CREATE TABLESPACE tp_ldr_nzd_201401 DATAFILE 'ldr_nzd_201401.dbf' SIZE 100M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED;
CREATE TABLESPACE tp_ldr_nzd_201402 DATAFILE 'ldr_nzd_201402.dbf' SIZE 100M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED;

--创建分区表
CREATE TABLE leadership(
  market     VARCHAR2(3),
  campaign   NUMBER(6),
  memberid   VARCHAR2(20),
  leaderid   VARCHAR2(20),
  roleid     VARCHAR2(10),
  sales      NUMBER(10,2)
)
PARTITION BY LIST(market)
SUBPARTITION BY RANGE(campaign)
(
  PARTITION ldr_aus VALUES ('AUS')
  (
    SUBPARTITION ldr_aus_201401 VALUES LESS THAN (201402) TABLESPACE tp_ldr_aus_201401
   ,SUBPARTITION ldr_aus_201402 VALUES LESS THAN (201403) TABLESPACE tp_ldr_aus_201402
  )
 ,PARTITION ldr_nzd VALUES ('NZD')
  (
    SUBPARTITION ldr_nzd_201401 VALUES LESS THAN (201402) TABLESPACE tp_ldr_nzd_201401
   ,SUBPARTITION ldr_nzd_201402 VALUES LESS THAN (201403) TABLESPACE tp_ldr_nzd_201402
  )
);
```

##查看分区表的定义

表、表分区、表子分区都有对应的 Object。

```
SQL> SELECT object_name,subobject_name,object_id,object_type,status
  2  FROM user_objects WHERE object_name='LEADERSHIP'
  3  ORDER BY object_id;

OBJECT_NAME    SUBOBJECT_NAME    OBJECT_ID OBJECT_TYPE         STATUS
-------------- ---------------- ---------- ------------------- -------
LEADERSHIP                           80192 TABLE               VALID
LEADERSHIP     LDR_AUS               80193 TABLE PARTITION     VALID
LEADERSHIP     LDR_NZD               80194 TABLE PARTITION     VALID
LEADERSHIP     LDR_AUS_201401        80195 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_AUS_201402        80196 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_NZD_201401        80197 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_NZD_201402        80198 TABLE SUBPARTITION  VALID

7 rows selected.
```

表定义

```
SQL> SELECT table_name,partitioning_type, subpartitioning_type,partition_count,def_tablespace_name
  2  FROM user_part_tables
  3  WHERE table_name='LEADERSHIP';

TABLE_NAME     PARTITION SUBPARTIT PARTITION_COUNT DEF_TABLESPACE_NAME
-------------- --------- --------- --------------- ------------------------------
LEADERSHIP     LIST      RANGE                   2 USERS
```

LIST表分区定义

```
SQL> SELECT table_name,partition_name,subpartition_count,high_value,tablespace_name
  2  FROM user_tab_partitions
  3  WHERE table_name='LEADERSHIP'
  4  ORDER BY partition_position;

TABLE_NAME     PARTITION_NAME   SUBPARTITION_COUNT HIGH_VALUE TABLESPACE_NAME
-------------- ---------------- ------------------ ---------- ----------------
LEADERSHIP     LDR_AUS                           2 'AUS'      USERS
LEADERSHIP     LDR_NZD                           2 'NZD'      USERS
```

```
SQL> SELECT *
  2  FROM user_part_key_columns
  3  WHERE name='LEADERSHIP'
  4  ORDER BY column_position;

NAME                           OBJEC COLUMN_NAME                    COLUMN_POSITION
------------------------------ ----- ------------------------------ ---------------
LEADERSHIP                     TABLE MARKET                                       1
```

RANGE表子分区定义

```
SQL> SELECT table_name,partition_name,subpartition_name,high_value,tablespace_name
  2  FROM user_tab_subpartitions
  3  WHERE table_name='LEADERSHIP'
  4  ORDER BY partition_name, subpartition_position;

TABLE_NAME     PARTITION_NAME   SUBPARTITION_NAME              HIGH_VALUE TABLESPACE_NAME
-------------- ---------------- ------------------------------ ---------- -------------------------
LEADERSHIP     LDR_AUS          LDR_AUS_201401                 201402     TP_LDR_AUS_201401
LEADERSHIP     LDR_AUS          LDR_AUS_201402                 201403     TP_LDR_AUS_201402
LEADERSHIP     LDR_NZD          LDR_NZD_201401                 201402     TP_LDR_NZD_201401
LEADERSHIP     LDR_NZD          LDR_NZD_201402                 201403     TP_LDR_NZD_201402
```

```
SQL> SELECT *
  2  FROM user_subpart_key_columns
  3  WHERE name='LEADERSHIP'
  4  ORDER BY column_position;

NAME                           OBJEC COLUMN_NAME                    COLUMN_POSITION
------------------------------ ----- ------------------------------ ---------------
LEADERSHIP                     TABLE CAMPAIGN                                     1
```

##添加表分区

在添加表分区时，如果未定义表子分区，则 Oracle 会根据 SUBPARITION TEMPLATES 自动创建子分区。如果 SUBPARTITION TEMPLATES 也未定义，则 Oracle 将自动创建只有一个子分区的表分区。

如本例，如果未定义 SUBPARTITION，则自动创建 VALUES LESS THAN (MAXVALUE) 的子分区。

```sql
--创建表空间
CREATE TABLESPACE tp_ldr_sap_201401 DATAFILE 'ldr_sap_201401.dbf' SIZE 100M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED;

--添加表分区
ALTER TABLE leadership
  ADD PARTITION ldr_sap VALUES ('SAP')
  (
    SUBPARTITION ldr_sap_201401 VALUES LESS THAN (201402) TABLESPACE tp_ldr_sap_201401
  );
```

查看对象：

```
SQL> SELECT object_name,subobject_name,object_id,object_type,status
  2  FROM user_objects WHERE object_name='LEADERSHIP'
  3  ORDER BY object_id;

OBJECT_NAME    SUBOBJECT_NAME    OBJECT_ID OBJECT_TYPE         STATUS
-------------- ---------------- ---------- ------------------- -------
LEADERSHIP                           80192 TABLE               VALID
LEADERSHIP     LDR_AUS               80193 TABLE PARTITION     VALID
LEADERSHIP     LDR_NZD               80194 TABLE PARTITION     VALID
LEADERSHIP     LDR_AUS_201401        80195 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_AUS_201402        80196 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_NZD_201401        80197 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_NZD_201402        80198 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_SAP               80209 TABLE PARTITION     VALID
LEADERSHIP     LDR_SAP_201401        80210 TABLE SUBPARTITION  VALID

9 rows selected.
```

##添加表子分区

```sql
--创建表空间
CREATE TABLESPACE tp_ldr_sap_201402 DATAFILE 'ldr_sap_201402.dbf' SIZE 100M AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED;

--添加表子分区
ALTER TABLE leadership
  MODIFY PARTITION ldr_sap
    ADD SUBPARTITION ldr_sap_201402 VALUES LESS THAN (201403) TABLESPACE tp_ldr_sap_201402;
```

查看对象：

```
SQL> SELECT object_name,subobject_name,object_id,object_type,status
  2  FROM user_objects WHERE object_name='LEADERSHIP'
  3  ORDER BY object_id;

OBJECT_NAME    SUBOBJECT_NAME    OBJECT_ID OBJECT_TYPE         STATUS
-------------- ---------------- ---------- ------------------- -------
LEADERSHIP                           80192 TABLE               VALID
LEADERSHIP     LDR_AUS               80193 TABLE PARTITION     VALID
LEADERSHIP     LDR_NZD               80194 TABLE PARTITION     VALID
LEADERSHIP     LDR_AUS_201401        80195 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_AUS_201402        80196 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_NZD_201401        80197 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_NZD_201402        80198 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_SAP               80209 TABLE PARTITION     VALID
LEADERSHIP     LDR_SAP_201401        80210 TABLE SUBPARTITION  VALID
LEADERSHIP     LDR_SAP_201402        80211 TABLE SUBPARTITION  VALID

10 rows selected.
```

##创建LOCAL索引

```
CREATE UNIQUE INDEX pk_idx_ldr ON leadership(market, campaign, memberid) LOCAL;
```

查看索引：

```
SQL> SELECT object_name,subobject_name,object_id,object_type,status
  2  FROM user_objects WHERE object_name='PK_IDX_LDR'
  3  ORDER BY object_id;

OBJECT_NAME    SUBOBJECT_NAME    OBJECT_ID OBJECT_TYPE         STATUS
-------------- ---------------- ---------- ------------------- -------
PK_IDX_LDR                           80267 INDEX               VALID
PK_IDX_LDR     LDR_AUS               80268 INDEX PARTITION     VALID
PK_IDX_LDR     LDR_NZD               80269 INDEX PARTITION     VALID
PK_IDX_LDR     LDR_SAP               80270 INDEX PARTITION     VALID
PK_IDX_LDR     LDR_AUS_201401        80271 INDEX SUBPARTITION  VALID
PK_IDX_LDR     LDR_AUS_201402        80272 INDEX SUBPARTITION  VALID
PK_IDX_LDR     LDR_NZD_201401        80273 INDEX SUBPARTITION  VALID
PK_IDX_LDR     LDR_NZD_201402        80274 INDEX SUBPARTITION  VALID
PK_IDX_LDR     LDR_SAP_201401        80275 INDEX SUBPARTITION  VALID
PK_IDX_LDR     LDR_SAP_201402        80276 INDEX SUBPARTITION  VALID

10 rows selected.

```

```
SQL> SELECT index_name,partition_name,subpartition_name,high_value,tablespace_name
  2  FROM user_ind_subpartitions
  3  WHERE index_name='PK_IDX_LDR'
  4  ORDER BY partition_name,subpartition_position;

INDEX_NAME     PARTITION_NAME   SUBPARTITION_NAME              HIGH_VALUE TABLESPACE_NAME
-------------- ---------------- ------------------------------ ---------- ---------------------
PK_IDX_LDR     LDR_AUS          LDR_AUS_201401                 201402     TP_LDR_AUS_201401
PK_IDX_LDR     LDR_AUS          LDR_AUS_201402                 201403     TP_LDR_AUS_201402
PK_IDX_LDR     LDR_NZD          LDR_NZD_201401                 201402     TP_LDR_NZD_201401
PK_IDX_LDR     LDR_NZD          LDR_NZD_201402                 201403     TP_LDR_NZD_201402
PK_IDX_LDR     LDR_SAP          LDR_SAP_201401                 201402     TP_LDR_SAP_201401
PK_IDX_LDR     LDR_SAP          LDR_SAP_201402                 201403     TP_LDR_SAP_201402

6 rows selected.
```

可见，默认情况下，索引使用与分区数据相同的表空间。可在建索引的时候为每个分区指定独立的表空间，此处略。

##插入数据

```sql
INSERT INTO leadership VALUES('AUS', 201401, '001', '0', 'REP', 100);
INSERT INTO leadership VALUES('AUS', 201402, '001', '0', 'REP', 100);
INSERT INTO leadership VALUES('AUS', 201402, '002', '0', 'REP', 100);
INSERT INTO leadership VALUES('NZD', 201401, '002', '0', 'REP', 100);
INSERT INTO leadership VALUES('NZD', 201402, '002', '0', 'REP', 100);
INSERT INTO leadership VALUES('NZD', 201402, '003', '0', 'REP', 100);
INSERT INTO leadership VALUES('SAP', 201402, '004', '0', 'REP', 100);
COMMIT;
```

查询全表数据

```
SQL> SELECT * FROM leadership;

MAR   CAMPAIGN MEMBERID             LEADERID             ROLEID          SALES
--- ---------- -------------------- -------------------- ---------- ----------
AUS     201401 001                  0                    REP               100
AUS     201402 001                  0                    REP               100
AUS     201402 002                  0                    REP               100
NZD     201401 002                  0                    REP               100
NZD     201402 002                  0                    REP               100
NZD     201402 003                  0                    REP               100
SAP     201402 004                  0                    REP               100

7 rows selected.
```

查询表分区数据

```
SQL> SELECT * FROM leadership PARTITION(ldr_aus);

MAR   CAMPAIGN MEMBERID             LEADERID             ROLEID          SALES
--- ---------- -------------------- -------------------- ---------- ----------
AUS     201401 001                  0                    REP               100
AUS     201402 001                  0                    REP               100
AUS     201402 002                  0                    REP               100
```

查询表子分区数据

```
SQL> SELECT * FROM leadership SUBPARTITION(ldr_aus_201402);

MAR   CAMPAIGN MEMBERID             LEADERID             ROLEID          SALES
--- ---------- -------------------- -------------------- ---------- ----------
AUS     201402 001                  0                    REP               100
AUS     201402 002                  0                    REP               100
```

##删除表子分区

```sql
ALTER TABLE leadership
  DROP SUBPARTITION ldr_sap_201402;
```

##删除表空间

```sql
DROP TABLESPACE tp_ldr_sap_201402 INCLUDING CONTENTS AND DATAFILES;
```

##删除表分区

```sql
ALTER TABLE leadership
  DROP PARTITION ldr_sap;
```