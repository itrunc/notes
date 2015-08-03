SELECT a. tablespace_name "��ռ���",
       total "��ռ��С" ,
       free "��ռ�ʣ���С" ,
       (total - free) "��ռ�ʹ�ô�С",
       total / (1024 * 1024 * 1024) "��ռ��С(G)" ,
       free / (1024 * 1024 * 1024) "��ռ�ʣ���С(G)" ,
       (total - free) / (1024 * 1024 * 1024 ) "��ռ�ʹ�ô�С(G)" ,
       ROUND ( (total - free) / total, 4) * 100 "ʹ���� %"
  FROM (  SELECT tablespace_name , SUM (bytes ) free
            FROM dba_free_space
        GROUP BY tablespace_name ) a,
       (  SELECT tablespace_name , SUM (bytes ) total
            FROM dba_data_files
        GROUP BY tablespace_name ) b
 WHERE a.tablespace_name = b .tablespace_name ;