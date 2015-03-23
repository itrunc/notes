# ROW_NUMBER 函数
该函数提供某行在数据行窗口中的行号

## 语法

![ROW_NUMBER函数](../../../public/imgs/row_number.gif)


##描述
ROW_NUMBER是一个分析函数，它使用一个唯一的数字来标识某行在order_by_clause子句确定的序列中的位置（从1开始数起）。

##示例

以下示例找出每个部门中SALARY最高的3位员工

```sql
SELECT department_id, first_name, last_name, salary
FROM
(
  SELECT
    department_id, first_name, last_name, salary,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary desc) rn
  FROM employees
)
WHERE rn <= 3
ORDER BY department_id, salary DESC, last_name;
```

以下示例找出1999年销售额最高的5种产品在2000年的销售总额，以及该产品2000年销售额与1999年销售额的比较

```sql
SELECT sales_2000.channel_desc, sales_2000.prod_name,
       sales_2000.amt amt_2000,  top_5_prods_1999_year.amt amt_1999,
       sales_2000.amt  - top_5_prods_1999_year.amt amt_diff
FROM
/* The first subquery finds the 5 top-selling products per channel in year 1999. */
  (SELECT channel_desc, prod_name, amt
   FROM
   (
     SELECT channel_desc, prod_name, sum(amount_sold) amt,
       ROW_NUMBER () OVER (PARTITION BY channel_desc
                           ORDER BY SUM(amount_sold) DESC) rn
     FROM sales, times, channels, products
     WHERE sales.time_id = times.time_id
       AND times.calendar_year = 1999
       AND channels.channel_id = sales.channel_id
       AND products.prod_id = sales.prod_id
     GROUP BY channel_desc, prod_name
   )
   WHERE rn <= 5
  ) top_5_prods_1999_year,
/* The next subquery finds sales per product and per channel in 2000. */
  (SELECT channel_desc, prod_name, sum(amount_sold) amt
     FROM sales, times, channels, products
     WHERE sales.time_id = times.time_id
       AND times.calendar_year = 2000
       AND channels.channel_id = sales.channel_id
       AND products.prod_id = sales.prod_id
     GROUP BY channel_desc, prod_name
  ) sales_2000
WHERE sales_2000.channel_desc = top_5_prods_1999_year.channel_desc
  AND sales_2000.prod_name = top_5_prods_1999_year.prod_name
ORDER BY sales_2000.channel_desc, sales_2000.prod_name
;
```

结果：

|CHANNEL_DESC   |PROD_NAME                                       |  AMT_2000|  AMT_1999|  AMT_DIFF|
|---------------|------------------------------------------------|----------|----------|----------|
|Direct Sales   | 17" LCD w/built-in HDTV Tuner                  |  628855.7|1163645.78|-534790.08|
|Direct Sales   | Envoy 256MB - 40GB                             | 502938.54| 843377.88|-340439.34|
|Direct Sales   | Envoy Ambassador                               |2259566.96|1770349.25| 489217.71|
|Direct Sales   | Home Theatre Package with DVD-Audio/Video Play |1235674.15|1260791.44| -25117.29|
|Direct Sales   | Mini DV Camcorder with 3.5" Swivel LCD         | 775851.87|1326302.51|-550450.64|
|Internet       | 17" LCD w/built-in HDTV Tuner                  |  31707.48|  160974.7|-129267.22|
|Internet       | 8.3 Minitower Speaker                          | 404090.32| 155235.25| 248855.07|
|Internet       | Envoy 256MB - 40GB                             |  28293.87| 154072.02|-125778.15|
|Internet       | Home Theatre Package with DVD-Audio/Video Play | 155405.54| 153175.04|    2230.5|
|Internet       | Mini DV Camcorder with 3.5" Swivel LCD         |  39726.23| 189921.97|-150195.74|
|Partners       | 17" LCD w/built-in HDTV Tuner                  | 269973.97| 325504.75| -55530.78|
|Partners       | Envoy Ambassador                               |1213063.59| 614857.93| 598205.66|
|Partners       | Home Theatre Package with DVD-Audio/Video Play | 700266.58| 520166.26| 180100.32|
|Partners       | Mini DV Camcorder with 3.5" Swivel LCD         | 404265.85| 520544.11|-116278.26|
|Partners       | Unix/Windows 1-user pack                       | 374002.51| 340123.02|  33879.49|
