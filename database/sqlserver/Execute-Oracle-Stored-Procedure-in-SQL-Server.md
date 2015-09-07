#Execute Oracle Stored Procedure in SQL Server

Executing an Oracle Stored Procedure is a common task using a data access technology like ADO.NET and is not so common to execute Oracle procs from SQL Server Procedures but in some cases is needed. For example, I used a scheduled stored procedure in SQL Server to process some data on daily basis and this procedure was encharged of updating some data on an Oracle Database. First we suggest pushing data to an Oracle table using the OPENQUERY statement, but the requirement was to validate some data at the Oracle Database. So we needed to execute an Oracle stored procedure in order to archieve this requirement. So for all you guys that are trying to execute an Oracle Stored Procedure from SQL Server you can try the following:

We made a sample package named SBD with the procedure named TestProcedure:

Package Header:

```sql
PROCEDURE TestProcedure
(
    I_Parameter1 IN NUMBER,
    I_Parameter2 IN NUMBER,
    O_Parameter1 OUT NUMBER,
    O_Parameter2 OUT NUMBER
);
```
 
Package Body:

```sql
PROCEDURE TestProcedure
(
    I_Parameter1 IN NUMBER,
    I_Parameter2 IN NUMBER,
    O_Parameter1 OUT NUMBER,
    O_Parameter2 OUT NUMBER
) AS
BEGIN
   O_Parameter1 := I_Parameter1 + 1;
   O_Parameter2 := I_Parameter2 + 1;
END TestProcedure;
```
 
Then we create a SQL Server Stored Procedure to Wrapp the Oracle Store Procedure Invocation, the T-SQL inside the procedure for this sample is the following: 

```sql
DECLARE @l_i_parameter1 INTEGER
DECLARE @l_i_parameter2 INTEGER 
DECLARE @l_o_parameter1 INTEGER
DECLARE @l_o_parameter2 INTEGER

SET @l_i_parameter1 = 5
SET @l_i_parameter2 = 10
SET @l_o_parameter1 = 0
SET @l_o_parameter2 = 0

EXECUTE ( 'begin SDB.TestProcedure(?,?,?,?); end;', @l_i_parameter1, @l_i_parameter2, @l_o_parameter1 OUTPUT, @l_o_parameter2 OUTPUT) AT DBLINK_NAME;

SELECT @l_o_parameter1, @l_o_parameter2
```

I Hope this sample ilustrate the concept. Also I want to mention that this sample only works with simple output parameters, if you are trying to query for resultsets I recommend to try the OPENQUERY statement insteed.

##Reference

* [1] [Execute Oracle Stored Procedure in SQL Server](http://blogs.msdn.com/b/joaquinv/archive/2008/10/23/execute-oracle-stored-procedure-in-sql-server.aspx)