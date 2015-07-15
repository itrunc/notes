#FIRST 函数


##语法

![FIRST函数语法](img/first.gif)

##描述

**FIRST** 和 **LAST** 非常相似，两者都可作为聚合函数和分析函数。它们分别用于计算已排序值中的第一个和最后一个值，这些排序值来自于数据行。如果数据只有一行，用于FIRST或LAST计算的值集合中只有一个元素。

If you omit the OVER clause, then the FIRST and LAST functions are treated as aggregate functions. You can use these functions as analytic functions by specifying the OVER clause. The query_partition_clause is the only part of the OVER clause valid with these functions. If you include the OVER clause but omit the query_partition_clause, then the function is treated as an analytic function, but the window defined for analysis is the entire table.

These functions take as an argument any numeric data type or any nonnumeric data type that can be implicitly converted to a numeric data type. The function returns the same data type as the numeric data type of the argument.

When you need a value from the first or last row of a sorted group, but the needed value is not the sort key, the FIRST and LAST functions eliminate the need for self-joins or views and enable better performance.

* The aggregate_function argument is any one of the MIN, MAX, SUM, AVG, COUNT, VARIANCE, or STDDEV functions. It operates on values from the rows that rank either FIRST or LAST. If only one row ranks as FIRST or LAST, then the aggregate operates on a singleton (nonaggregate) set.

* The KEEP keyword is for semantic clarity. It qualifies aggregate_function, indicating that only the FIRST or LAST values of aggregate_function will be returned.

* DENSE_RANK FIRST or DENSE_RANK LAST indicates that Oracle Database will aggregate over only those rows with the minimum (FIRST) or the maximum (LAST) dense rank (also called olympic rank).

##示例

###聚合函数示例

以下查询返回hr.employees表中每个部门拥有最低commission的员工中最低的salary和拥有最高commission的员工中最高的salary

```sql
SELECT department_id,
       MIN(salary) KEEP (DENSE_RANK FIRST ORDER BY commission_pct) "Worst",
       MAX(salary) KEEP (DENSE_RANK LAST ORDER BY commission_pct) "Best"
  FROM employees
  GROUP BY department_id
  ORDER BY department_id;
```

>以上 **DENSE_RANK FIRST ORDER BY commission_pct** 得到commission_pct最小的员工


```
DEPARTMENT_ID      Worst       Best
------------- ---------- ----------
           10       4400       4400
           20       6000      13000
           30       2500      11000
           40       6500       6500
           50       2100       8200
           60       4200       9000
           70      10000      10000
           80       6100      14000
           90      17000      24000
          100       6900      12008
          110       8300      12008
                    7000       7000
```

###分析函数示例

以下查询返回与上一查询作相同计算，但结果集中会显示部门中拥有最高和最低salary所有的员工

```sql
SELECT last_name, department_id, salary,
       MIN(salary) KEEP (DENSE_RANK FIRST ORDER BY commission_pct)
         OVER (PARTITION BY department_id) "Worst",
       MAX(salary) KEEP (DENSE_RANK LAST ORDER BY commission_pct)
         OVER (PARTITION BY department_id) "Best"
   FROM employees
   ORDER BY department_id, salary, last_name;
```

```
LAST_NAME           DEPARTMENT_ID     SALARY      Worst       Best
------------------- ------------- ---------- ---------- ----------
Whalen                         10       4400       4400       4400
Fay                            20       6000       6000      13000
Hartstein                      20      13000       6000      13000
. . .
Gietz                         110       8300       8300      12008
Higgins                       110      12008       8300      12008
Grant                                   7000       7000       7000
```