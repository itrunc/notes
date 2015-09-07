#如何通过linked server对远程Oracle进行数据操作

##Openquery

Openquery是使用linked server中非常推荐使用的函数。通常情况下，如果我们用四段式的名称访问远程的oracle table，比如：

```sql
Select * from linkedserver.oracledb.user.table where id=n
```

由于SQL Server没有办法获得Oracle端的统计信息，即使在ID字段上有index，以上的语句还是没有办法使用oracle端的index，默认的行为就是把所有的数据传送给SQL Server然后在SQL Server端做过滤. 

如果我们使用OpenQuery进行insert、update和delete操作，我们可以手工的决定哪个部分的语句直接传递给oracle执行。具体用法举例为：

```sql
DELETE from OPENQUERY (oracle92,'SELECT * FROM TEST WHERE ID = 1') 
INSERT OPENQUERY (ORACLE92,'SELECT * FROM TEST') VALUES (2, 'CC') 
UPDATE OPENQUERY(ORACLE92,'SELECT * FROM TEST WHERE ID = 1') SET NAME ='CCC'
```

同时，Openquery可以跳过元数据的类型校验，因此是linked server语句的访问性能提高。

有时在相互兼容性不够好的两种数据库之间，比如SQL Server 和DB2之间，直接用四段式的方式访问是没有办法通过元数据校验并且返回结果集的，但是当我们改用openquery函数的时候，就可以成功的访问远程数据了。

##如何通过linked server 调用远程oracle的存储过程。

Linked server是不支持直接调用非SQL Server的远程数据库的带参数的存储过程的。下面列出了三种方法，这里只有方法2在32位及64位的SQL Server都可用：


###方法1

可以使用msdaora调用一个没有参数的Oracle存储过程。

使用oraOLEDB.oracle，会引发错误7357，这意味着在64位oraOLEDB.oracle接口上会执行失败。(64bit上没有msdaora)

错误信息：

> Msg 7357, Level 16, State 2, Line 1
> 
> Cannot process the object "{CALL SCOTT.USP_WCARROLL_PROC({resultset 25, OUTPUT})}".
> 
> The OLE DB provider "OraOLEDB.Oracle" for linked server "ORACLE92" indicates that either the object has no columns or the current user does not have permissions on that object.

```sql
/*创建Oracle对象的SQL Plus代码*/
create or replace procedure SCOTT.USP_WCARROLL_PROC(OUTPUT OUT dbms_output.chararr)
is
begin
  OUTPUT(1):='One';
  OUTPUT(2):='Two';
  OUTPUT(3):='Three';
end;
/
```
 
```sql
select * from openquery(ORACLE92, '{CALL SCOTT.USP_WCARROLL_PROC({resultset 25, OUTPUT})}');
```

###方法2

向Oracle表中插入记录，且该操作触发一个会调用存储过程的触发器

可以在Oracle中创建一个表，并在上面放置一个由insert操作触发的触发器；在触发器中，会调用Oracle存储过程。如果你的Oracle技术比我好，你的触发器应当能够得到被插入的记录数据并把它们传递到Oracle存储过程作为参数。为了返回数据，可以利用存储过程更新Oracle表中的记录，然后重新查询记录，以此从SQL Server中得到返回参数。这种方法在msdaora和oraOLEDB.oracle上都适用。所以这个方法将适用于Oracle 64位的OLEDB接口。

```sql
/* 创建Oracle对象的SQL Plus代码 */
create table SCOTT.TBL_WCARROLL (
  id int,
  mydate varchar2(100)
);
/

create table SCOTT.TBL_WCARROLL_CALLPROC (
  id int,
  param1 int,
  param1 varchar2(100)
);
/
```
 
```sql
create or replace procedure SCOTT.USP_WCARROLL
as
begin

  insert into SCOTT.TBL_WCARROLL values (99, 'Success')

end;
/
```

```sql
create or replace trigger SCOTT.TRG_WCARROLL_CALLPROC
after insert on SCOTT.TBL_WCARROLL_CALLPROC
for each row
begin

  SCOTT.USP_WCARROLL;

end;

/
```

```sql
--然后使用OpenQuery插入一条记录

INSERT OPENQUERY (ORACLE92,'SELECT * FROM SCOTT.TBL_WCARROLL_CALLPROC') VALUES (1, 1, 'TRUE')

select * from openquery(ORACLE92, 'SELECT * FROM SCOTT.TBL_WCARROLL')

select * from openquery(ORACLE92, 'SELECT * FROM SCOTT.TBL_WCARROLL_CALLPROC')
```

###方法3

调用包含Oracle存储过程的Oracle包。

这种技术允许参数传递。创建一个接受参数的Oracle包，在Oracle包中，它调用一个Oracle存储过程。该技术对于msdaora有效，但是不适用与ora.OLEDB.oracle。所以在64位的oraOLEDB.ORACLE接口上也会运行失败。

错误信息：

> Msg 7357, Level 16, State 2, Line 1
> 
> Cannot process the object "{CALL SCOTT.PKG_WCARROLL.OracleProc('xxx','1','1.1','Oct21 1963',{resultset 25, ReturnVal})}". The OLE DB provider "OraOLEDB.Oracle" for linked server "ORACLE92" indicates that either the object has no columns or the current user does not have permissions on that object.

```sql
/*创建Oracle对象的SQL Plus代码*/
create or replace package PKG_WCARROLL
as
  TYPE SqlReturnTbl is TABLE of varchar(500) INDEX BY BINARY_INTEGER;
  
  procedure OracleProc (
    param1 IN varchar2,
    param2 IN varchar2,
    param3 IN varchar2,
    param4 IN varchar2,
    ReturnVal OUT SqlReturnTbl
  );
end PKG_WCARROLL;
/


create or replace package body PKG_WCARROLL
as

	procedure OracleProc (
	  param1 IN varchar2,
	  param2 IN varchar2,
	  param3 IN varchar2,
	  param4 IN varchar2,
	  ReturnVal OUT SqlReturnTbl
	)
	is
	begin

	  ReturnVal(1):= 'String data';
	  ReturnVal(2):= '3';
	  ReturnVal(3):= '3.14';
	  ReturnVal(4):= 'Feb 22 2008';

	End OracleProc;

End PKG_WCARROLL;
/
```
 
```sql
/* 用来调用Oracle包及带参存储过程的SQL Server存储过程*/

create proc [dbo].[CallOracleProcTest]

as

  set nocount on

  declare @createdTran tinyint
  set @createdTran = 0

  set xact_abort on

  if @@trancount = 0
  begin

    begin tran

    set @createdTran = 1

  end

  create table #test(indicator int identity(1,1), oracle_results varchar(500))

  declare @param1ForOracle varchar(100), @param2ForOracle varchar(100), @param3ForOracle varchar(100), @param4ForOracle varchar(100)
  set @param1ForOracle = 'xxx'
  set @param2ForOracle = '1'
  set @param3ForOracle = '1.1'
  set @param4ForOracle = 'Oct 21 1963'

  declare @OracleCall varchar(8000)
  set @OracleCall = 'Insert into #test(oracle_results) select * from OPENQUERY(ORACLE92, ''{CALL SCOTT.PKG_WCARROLL.OracleProc('
  set @OracleCall = @OracleCall + '''''' + @param1ForOracle + ''''''
  set @OracleCall = @OracleCall + ',' + '''''' + @param2ForOracle + ''''''
  set @OracleCall = @OracleCall + ',' + '''''' + @param3ForOracle + ''''''
  set @OracleCall = @OracleCall + ',' + '''''' + @param4ForOracle + ''''''
  set @OracleCall = @OracleCall + ',{resultset 25, ReturnVal})}'')'

  --select @OracleCall
  exec (@OracleCall)

  if @@error <> 0 goto err_handler

  select * from #test

  if @@error <> 0 goto err_handler

  if @createdTran = 1 and @@trancount > 0
  begin

    commit tran

  end

  set xact_abort off

  return 0

err_handler:

  print 'Error in proc'

  if @createdTran = 1 and @@trancount > 0
  begin

    rollback tran

  end

  set xact_abort off
```

##Reference

* [1] [如何通过linked server对远程Oracle进行数据操作](http://blogs.msdn.com/b/apgcdsd/archive/2011/06/10/how-to-linked-server-oracle.aspx)