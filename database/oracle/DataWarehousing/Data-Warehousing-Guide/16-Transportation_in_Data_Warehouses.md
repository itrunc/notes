#Transportation in Data Warehouses

The following topics provide information about transporting data into a data warehouse:

##Overview of Transportation in Data Warehouses

Transportation is the operation of moving data from one system to another system. In a data warehouse environment, the most common requirements for transportation are in moving data from:

* A source system to a staging database or a data warehouse database
* A staging database to a data warehouse
* A data warehouse to a data mart

Transportation is often one of the simpler portions of the ETL process, and can be integrated with other portions of the process. For example, as shown in [Chapter 15, "Extraction in Data Warehouses"](http://docs.oracle.com/database/121/DWHSG/extract.htm#g1008480), distributed query technology provides a mechanism for both extracting and transporting data.

##Introduction to Transportation Mechanisms in Data Warehouses

You have three basic choices for transporting data in warehouses:

###Transportation Using Flat Files

The most common method for transporting data is by the transfer of flat files, using mechanisms such as FTP or other remote file system access protocols. Data is unloaded or exported from the source system into flat files using techniques discussed in [Chapter 15, "Extraction in Data Warehouses"](http://docs.oracle.com/database/121/DWHSG/extract.htm#g1008480), and is then transported to the target platform using FTP or similar mechanisms.

Because source systems and data warehouses often use different operating systems and database systems, using flat files is often the simplest way to exchange data between heterogeneous systems with minimal transformations. However, even when transporting data between homogeneous systems, flat files are often the most efficient and most easy-to-manage mechanism for data transfer.

###Transportation Through Distributed Operations

Distributed queries, either with or without gateways, can be an effective mechanism for extracting data. These mechanisms also transport the data directly to the target systems, thus providing both extraction and transformation in a single step. Depending on the tolerable impact on time and system resources, these mechanisms can be well suited for both extraction and transformation.

As opposed to flat file transportation, the success or failure of the transportation is recognized immediately with the result of the distributed query or transaction.

> **See Also:**
>
> * [Chapter 15, "Extraction in Data Warehouses"](http://docs.oracle.com/database/121/DWHSG/extract.htm#g1008480) for further information

###Transportation Using Transportable Tablespaces

Oracle transportable tablespaces are the fastest way for moving large volumes of data between two Oracle databases. Previous to the introduction of transportable tablespaces, the most scalable data transportation mechanisms relied on moving flat files containing raw data. These mechanisms required that data be unloaded or exported into files from the source database, Then, after transportation, these files were loaded or imported into the target database. Transportable tablespaces entirely bypass the unload and reload steps.

Using transportable tablespaces, Oracle data files (containing table data, indexes, and almost every other Oracle database object) can be directly transported from one database to another. Furthermore, like import and export, transportable tablespaces provide a mechanism for transporting metadata in addition to transporting data.

Transportable tablespaces have some limitations: source and target systems must be running Oracle8i (or higher), must use compatible character sets, and, before Oracle Database 10g, must run on the same operating system. For details on how to transport tablespace between operating systems, see [Oracle Database Administrator's Guide](http://docs.oracle.com/database/121/ADMIN/transport.htm#ADMIN11394).

The most common applications of transportable tablespaces in data warehouses are in moving data from a staging database to a data warehouse, or in moving data from a data warehouse to a data mart.

This section contains the following topics:

####Transportable Tablespaces Example

Suppose that you have a data warehouse containing sales data, and several data marts that are refreshed monthly. Also suppose that you are going to move one month of sales data from the data warehouse to the data mart.

Use the following steps to create a transportable tablespace:

#####Place the Data to be Transported into its own Tablespace

The current month's data must be placed into a separate tablespace in order to be transported. In this example, you have a tablespace ts_temp_sales, which holds a copy of the current month's data. Using the CREATE TABLE ... AS SELECT statement, the current month's data can be efficiently copied to this tablespace:

```sql
CREATE TABLE temp_jan_sales NOLOGGING TABLESPACE ts_temp_sales
AS SELECT * FROM sales 
WHERE time_id BETWEEN '31-DEC-1999' AND '01-FEB-2000';
```

Following this operation, the tablespace ts_temp_sales is set to read-only:

```sql
ALTER TABLESPACE ts_temp_sales READ ONLY;
```

A tablespace cannot be transported unless there are no active transactions modifying the tablespace. Setting the tablespace to read-only enforces this.

The tablespace ts_temp_sales may be a tablespace that has been especially created to temporarily store data for use by the transportable tablespace features. Following ["Copy the Datafiles and Export File to the Target System"](http://docs.oracle.com/database/121/DWHSG/transport.htm#CIHGCGGD), this tablespace can be set to read/write, and, if desired, the table temp_jan_sales can be dropped, or the tablespace can be re-used for other transportations or for other purposes.

In a given transportable tablespace operation, all of the objects in a given tablespace are transported. Although only one table is being transported in this example, the tablespace ts_temp_sales could contain multiple tables. For example, perhaps the data mart is refreshed not only with the new month's worth of sales transactions, but also with a new copy of the customer table. Both of these tables could be transported in the same tablespace. Moreover, this tablespace could also contain other database objects such as indexes, which would also be transported.

Additionally, in a given transportable-tablespace operation, multiple tablespaces can be transported at the same time. This makes it easier to move very large volumes of data between databases. Note, however, that the transportable tablespace feature can only transport a set of tablespaces which contain a complete set of database objects without dependencies on other tablespaces. For example, an index cannot be transported without its table, nor can a partition be transported without the rest of the table. You can use the DBMS_TTS package to check that a tablespace is transportable.

> **See Also:**
>
> [Oracle Database PL/SQL Packages and Types Reference](http://docs.oracle.com/database/121/ARPLS/d_tts.htm#ARPLS063) for detailed information about the DBMS_TTS package

In this step, you have copied the January sales data into a separate tablespace; however, in some cases, it may be possible to leverage the transportable tablespace feature without even moving data to a separate tablespace. If the sales table has been partitioned by month in the data warehouse and if each partition is in its own tablespace, then it may be possible to directly transport the tablespace containing the January data. Suppose the January partition, sales_jan2000, is located in the tablespace ts_sales_jan2000. Then the tablespace ts_sales_jan2000 could potentially be transported, rather than creating a temporary copy of the January sales data in the ts_temp_sales.

However, the same conditions must be satisfied in order to transport the tablespace ts_sales_jan2000 as are required for the specially created tablespace. First, this tablespace must be set to READ ONLY. Second, because a single partition of a partitioned table cannot be transported without the remainder of the partitioned table also being transported, it is necessary to exchange the January partition into a separate table (using the ALTER TABLE statement) to transport the January data. The EXCHANGE operation is very quick, but the January data will no longer be a part of the underlying sales table, and thus may be unavailable to users until this data is exchanged back into the sales table after the export of the metadata. The January data can be exchanged back into the sales table after you complete the step ["Copy the Datafiles and Export File to the Target System"](http://docs.oracle.com/database/121/DWHSG/transport.htm#CIHGCGGD).

#####Export the Metadata

The Export utility is used to export the metadata describing the objects contained in the transported tablespace. For our example scenario, the Export command could be:

```
EXP TRANSPORT_TABLESPACE=y TABLESPACES=ts_temp_sales FILE=jan_sales.dmp
```

This operation generates an export file, jan_sales.dmp. The export file is small, because it contains only metadata. In this case, the export file contains information describing the table temp_jan_sales, such as the column names, column data type, and all other information that the target Oracle database needs in order to access the objects in ts_temp_sales.

#####Copy the Datafiles and Export File to the Target System

Copy the data files that make up ts_temp_sales, as well as the export file jan_sales.dmp to the data mart platform, using any transportation mechanism for flat files. Once the datafiles have been copied, the tablespace ts_temp_sales can be set to READ WRITE mode if desired.

#####Import the Metadata

Once the files have been copied to the data mart, the metadata should be imported into the data mart:

```
IMP TRANSPORT_TABLESPACE=y DATAFILES='/db/tempjan.f' 
    TABLESPACES=ts_temp_sales FILE=jan_sales.dmp
```

At this point, the tablespace ts_temp_sales and the table temp_sales_jan are accessible in the data mart. You can incorporate this new data into the data mart's tables.

You can insert the data from the temp_sales_jan table into the data mart's sales table in one of two ways:

```sql
INSERT /*+ APPEND */ INTO sales SELECT * FROM temp_sales_jan;
```

Following this operation, you can delete the temp_sales_jan table (and even the entire ts_temp_sales tablespace).

Alternatively, if the data mart's sales table is partitioned by month, then the new transported tablespace and the temp_sales_jan table can become a permanent part of the data mart. The temp_sales_jan table can become a partition of the data mart's sales table:

```sql
ALTER TABLE sales ADD PARTITION sales_00jan VALUES
  LESS THAN (TO_DATE('01-feb-2000','dd-mon-yyyy'));
ALTER TABLE sales EXCHANGE PARTITION sales_00jan 
  WITH TABLE temp_sales_jan INCLUDING INDEXES WITH VALIDATION;
```

####Other Uses of Transportable Tablespaces

The previous example illustrates a typical scenario for transporting data in a data warehouse. However, transportable tablespaces can be used for many other purposes. In a data warehousing environment, transportable tablespaces should be viewed as a utility (much like Import/Export or SQL*Loader), whose purpose is to move large volumes of data between Oracle databases. When used in conjunction with parallel data movement operations such as the CREATE TABLE ... AS SELECT and INSERT ... AS SELECT statements, transportable tablespaces provide an important mechanism for quickly transporting data for many purposes.

##Reference 

* [1] [16 Transportation in Data Warehouses](http://docs.oracle.com/database/121/DWHSG/transport.htm)

