SELECT a. tablespace_name "表空间名",
       total "表空间大小" ,
       free "表空间剩余大小" ,
       (total - free) "表空间使用大小",
       total / (1024 * 1024 * 1024) "表空间大小(G)" ,
       free / (1024 * 1024 * 1024) "表空间剩余大小(G)" ,
       (total - free) / (1024 * 1024 * 1024 ) "表空间使用大小(G)" ,
       ROUND ( (total - free) / total, 4) * 100 "使用率 %"
  FROM (  SELECT tablespace_name , SUM (bytes ) free
            FROM dba_free_space
        GROUP BY tablespace_name ) a,
       (  SELECT tablespace_name , SUM (bytes ) total
            FROM dba_data_files
        GROUP BY tablespace_name ) b
 WHERE a.tablespace_name = b .tablespace_name ;