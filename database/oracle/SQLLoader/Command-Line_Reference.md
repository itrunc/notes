#SQL*Loader Command-Line Reference

You use command-line parameters to start SQL*Loader, as described in the following topics:

##Invoking SQL*Loader

This section describes how to start SQL*Loader and specify parameters. It contains the following sections:

###Specifying Parameters on the Command Line

When you start SQL*Loader, you specify parameters to establish various characteristics of the load operation. You can separate the parameters by commas.

```
> sqlldr CONTROL=ulcase1.ctl
Username: scott
Password: password
```
 
Specifying by position means that you enter a value, but not the parameter name. In the following example, the username scott is provided and then the name of the control file, ulcase1.ctl. You are prompted for the password:

```
> sqlldr scott ulcase1.ctl
Password: password
```
 
Once a parameter name is used, parameter names must be supplied for all subsequent specifications. No further positional specification is allowed. For example, in the following command, the CONTROL parameter is used to specify the control file name, but then the log file name is supplied without the LOG parameter. This would result in an error even though the position of ulcase1.log is correct:

```
> sqlldr scott CONTROL=ulcase1.ctl ulcase1.log
```

Instead, you would need to enter the following:

```
> sqlldr scott CONTROL=ulcase1.ctl LOG=ulcase1.log
```

> **See Also:**
> 
> "[Command-Line Parameters for SQL*Loader](http://docs.oracle.com/database/121/SUTIL/GUID-D7A661F1-5EE3-43DF-B3A5-050B2CF66844.htm)" for descriptions of all the command-line parameters

###Alternative Ways to Specify SQL*Loader Parameters

If the length of the command line exceeds the maximum line size for your system, then you can put certain command-line parameters in the control file by using the OPTIONS clause.

You can also group parameters together in a parameter file. You specify the name of this file on the command line using the PARFILE parameter when you start SQL*Loader.

These alternative ways of specifying parameters are useful when you often use the same parameters with the same values.

Parameter values specified on the command line override parameter values specified in either a parameter file or in the OPTIONS clause.

> **See Also:**
> 
> * "[OPTIONS Clause](http://docs.oracle.com/database/121/SUTIL/GUID-34A050B6-3FD7-4B77-97D2-04C03D359D16.htm#GUID-2BB41EA6-C94D-41C1-94DE-966B291943E6)"
> * "[PARFILE](http://docs.oracle.com/database/121/SUTIL/GUID-958AD711-DAAA-4185-9055-FD7535CF413D.htm)"

###Using SQL*Loader to Load Data Across a Network

To use SQL*Loader to load data across a network connection, you can specify a connect identifier in the connect string when you start the SQL*Loader utility. This identifier can specify a database instance that is different from the current instance identified by the setting of the ORACLE_SID environment variable for the current user. The connect identifier can be an Oracle Net connect descriptor or a net service name (usually defined in the tnsnames.ora file) that maps to a connect descriptor. Use of a connect identifier requires that you have Oracle Net Listener running (to start the default listener, enter lsnrctl start). The following example starts SQL*Loader for user scott using the connect identifier inst1:

```
> sqlldr CONTROL=ulcase1.ctl
Username: scott@inst1
Password: password
```

The local SQL*Loader client connects to the database instance defined by the connect identifier inst1 (a net service name), and loads the data, as specified in the ulcase1.ctl control file.

> **Note:**
> 
> To load data into a pluggable database (PDB), simply specify its connect identifier on the connect string when you start SQL*Loader.

> **See Also:**
> 
> * [Oracle Database Net Services Administrator's Guide](http://docs.oracle.com/database/121/NETAG/concepts.htm#NETAG363) for more information about connect identifiers and Oracle Net Listener
> * [Oracle Database Concepts](http://docs.oracle.com/database/121/CNCPT/cdbovrvw.htm#CNCPT89234) for more information about PDBs

To display a help screen that lists all SQL*Loader parameters, along with a brief description and the default value of each one, enter sqlldr at the prompt and press Enter.

##Command-Line Parameters for SQL*Loader

This section describes each SQL*Loader command-line parameter. The defaults and maximum values listed for these parameters are for UNIX-based systems. They may be different on your operating system. Refer to your Oracle operating system-specific documentation for more information.

##Exit Codes for Inspection and Display

Oracle SQL*Loader provides the results of a SQL*Loader run immediately upon completion. In addition to recording the results in a log file, SQL*Loader may also report the outcome in a process exit code. This Oracle SQL*Loader functionality allows for checking the outcome of a SQL*Loader invocation from the command line or a script. Table 8-1 shows the exit codes for various results.

**Table 8-1 Exit Codes for SQL*Loader**

Result | Exit Code
-------|----------
All rows loaded successfully | EX_SUCC
All or some rows rejected | EX_WARN
All or some rows discarded | EX_WARN
Discontinued load | EX_WARN
Command-line or syntax errors | EX_FAIL
Oracle errors nonrecoverable for SQL*Loader | EX_FAIL
Operating system errors (such as file open/close and malloc) | EX_FTL

For Linux and UNIX operating systems, the exit codes are as follows:

```
EX_SUCC 0
EX_FAIL 1
EX_WARN 2
EX_FTL  3
```

For Windows operating systems, the exit codes are as follows:

```
EX_SUCC 0
EX_FAIL 1
EX_WARN 2
EX_FTL  4
```

If SQL*Loader returns any exit code other than zero, then you should consult your system log files and SQL*Loader log files for more detailed diagnostic information.

In UNIX, you can check the exit code from the shell to determine the outcome of a load.

> **Note:**
> 
> Regular SQL*Loader and SQL*Loader express mode share some of the same parameters, but the behavior may be different. The parameter descriptions in this chapter are for regular SQL*Loader. The parameters for SQL*Loader express mode are described in [SQL*Loader Express](http://docs.oracle.com/database/121/SUTIL/GUID-8C235861-2A8B-4196-9705-E6FFED0C0C99.htm) .

##Reference

* [1] [SQL*Loader Command-Line Reference](http://docs.oracle.com/database/121/SUTIL/GUID-CD662CD8-DAA7-4A30-BC84-546E4C40DB31.htm)