-- Name: James Silcott
-- File: lab11b-silcott
-- Date: 5 Oct 2020


---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 11 - Programmable Objects
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

SET NOCOUNT ON;
USE TSQLV4;

---------------------------------------------------------------------
-- Dynamic SQL
---------------------------------------------------------------------

-- The EXEC Command

-- Simple example of EXEC
DECLARE @sql AS VARCHAR(100);
SET @sql = 'PRINT ''This message was printed by a dynamic SQL batch.'';';
EXEC(@sql);
GO

-- The sp_executesql Stored Procedure

-- Simple example using sp_executesql
DECLARE @sql AS NVARCHAR(100);

SET @sql = N'SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderid = @orderid;';

EXEC sys.sp_executesql
  @stmt = @sql,
  @params = N'@orderid AS INT',
  @orderid = 10248;
GO

---------------------------------------------------------------------
-- Using PIVOT with Dynamic SQL (Advanced, Optional)
---------------------------------------------------------------------

-- Static PIVOT
SELECT *
FROM (SELECT shipperid, YEAR(orderdate) AS orderyear, freight
      FROM Sales.Orders) AS D
  PIVOT(SUM(freight) FOR orderyear IN([2014],[2015],[2016])) AS P;

-- Dynamic PIVOT
DECLARE
  @sql       AS NVARCHAR(1000),
  @orderyear AS INT,
  @first     AS INT;

DECLARE C CURSOR FAST_FORWARD FOR
  SELECT DISTINCT(YEAR(orderdate)) AS orderyear
  FROM Sales.Orders
  ORDER BY orderyear;

SET @first = 1;

SET @sql = N'SELECT *
FROM (SELECT shipperid, YEAR(orderdate) AS orderyear, freight
      FROM Sales.Orders) AS D
  PIVOT(SUM(freight) FOR orderyear IN(';

OPEN C;

FETCH NEXT FROM C INTO @orderyear;

WHILE @@fetch_status = 0
BEGIN
  IF @first = 0
    SET @sql += N','
  ELSE
    SET @first = 0;

  SET @sql += QUOTENAME(@orderyear);

  FETCH NEXT FROM C INTO @orderyear;
END;

CLOSE C;

DEALLOCATE C;

SET @sql += N')) AS P;';

EXEC sys.sp_executesql @stmt = @sql;
GO

---------------------------------------------------------------------
-- Routines
---------------------------------------------------------------------

---------------------------------------------------------------------
-- User Defined Functions
---------------------------------------------------------------------

DROP FUNCTION IF EXISTS dbo.GetAge;
GO

CREATE FUNCTION dbo.GetAge
(
  @birthdate AS DATE,
  @eventdate AS DATE
)
RETURNS INT
AS
BEGIN
  RETURN
    DATEDIFF(year, @birthdate, @eventdate)
    - CASE WHEN 100 * MONTH(@eventdate) + DAY(@eventdate)
              < 100 * MONTH(@birthdate) + DAY(@birthdate)
           THEN 1 ELSE 0
      END;
END;
GO

-- Test function
SELECT
  empid, firstname, lastname, birthdate,
  dbo.GetAge(birthdate, '20160212') AS age
FROM HR.Employees;

select 'James''s age', dbo.GetAge('19780419', getdate());
select 'James''s age', dbo.GetAge('19780419', '20201005');
---------------------------------------------------------------------
-- Stored Procedures
---------------------------------------------------------------------

-- Using a Stored Procedure
DROP PROC IF EXISTS Sales.GetCustomerOrders;
GO

CREATE PROC Sales.GetCustomerOrders
  @custid   AS INT,
  @fromdate AS DATETIME = '19000101',
  @todate   AS DATETIME = '99991231',
  @numrows  AS INT OUTPUT
AS
SET NOCOUNT ON;

SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE custid = @custid
  AND orderdate >= @fromdate
  AND orderdate < @todate;

SET @numrows = @@rowcount;
GO

DECLARE @rc AS INT;

EXEC Sales.GetCustomerOrders
  @custid   = 1, -- Also try with 100
  @fromdate = '20150101',
  @todate   = '20160101',
  @numrows  = @rc OUTPUT;

SELECT @rc AS numrows;
GO

---------------------------------------------------------------------
-- Triggers
---------------------------------------------------------------------

-- Example for a DML audit trigger
DROP TABLE IF EXISTS dbo.T1_Audit, dbo.T1;

CREATE TABLE dbo.T1
(
  keycol  INT         NOT NULL PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
);

CREATE TABLE dbo.T1_Audit
(
  audit_lsn  INT          NOT NULL IDENTITY PRIMARY KEY,
  dt         DATETIME2(3) NOT NULL DEFAULT(SYSDATETIME()),
  login_name sysname      NOT NULL DEFAULT(ORIGINAL_LOGIN()),
  keycol     INT          NOT NULL,
  datacol    VARCHAR(10)  NOT NULL
);
GO

CREATE TRIGGER trg_T1_insert_audit ON dbo.T1 AFTER INSERT
AS
SET NOCOUNT ON;

INSERT INTO dbo.T1_Audit(keycol, datacol)
  SELECT keycol, datacol FROM inserted;
GO

INSERT INTO dbo.T1(keycol, datacol) VALUES(10, 'a');
INSERT INTO dbo.T1(keycol, datacol) VALUES(30, 'x');
INSERT INTO dbo.T1(keycol, datacol) VALUES(20, 'g');

SELECT audit_lsn, dt, login_name, keycol, datacol
FROM dbo.T1_Audit;
GO

-- cleanup
DROP TABLE IF EXISTS dbo.T1_Audit, dbo.T1;

-- Example for a DDL audit trigger

-- Creation Script for AuditDDLEvents Table and trg_audit_ddl_events Trigger
DROP TABLE IF EXISTS dbo.AuditDDLEvents;

CREATE TABLE dbo.AuditDDLEvents
(
  audit_lsn        INT          NOT NULL IDENTITY,
  posttime         DATETIME2(3) NOT NULL,
  eventtype        sysname      NOT NULL,
  loginname        sysname      NOT NULL,
  schemaname       sysname      NOT NULL,
  objectname       sysname      NOT NULL,
  targetobjectname sysname      NULL,
  eventdata        XML          NOT NULL,
  CONSTRAINT PK_AuditDDLEvents PRIMARY KEY(audit_lsn)
);
GO

CREATE TRIGGER trg_audit_ddl_events
  ON DATABASE FOR DDL_DATABASE_LEVEL_EVENTS
AS
SET NOCOUNT ON;

DECLARE @eventdata AS XML = EVENTDATA();

INSERT INTO dbo.AuditDDLEvents(
  posttime, eventtype, loginname, schemaname, 
  objectname, targetobjectname, eventdata)
  VALUES(
    @eventdata.value('(/EVENT_INSTANCE/PostTime)[1]',         'VARCHAR(23)'),
    @eventdata.value('(/EVENT_INSTANCE/EventType)[1]',        'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/LoginName)[1]',        'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/SchemaName)[1]',       'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/ObjectName)[1]',       'sysname'),
    @eventdata.value('(/EVENT_INSTANCE/TargetObjectName)[1]', 'sysname'),
    @eventdata);
GO

-- Test trigger trg_audit_ddl_events
CREATE TABLE dbo.T1(col1 INT NOT NULL PRIMARY KEY);
ALTER TABLE dbo.T1 ADD col2 INT NULL;
ALTER TABLE dbo.T1 ALTER COLUMN col2 INT NOT NULL;
CREATE NONCLUSTERED INDEX idx1 ON dbo.T1(col2);
GO

SELECT * FROM dbo.AuditDDLEvents;
GO

-- Cleanup
DROP TRIGGER IF EXISTS trg_audit_ddl_events ON DATABASE;
DROP TABLE IF EXISTS dbo.AuditDDLEvents;
GO

---------------------------------------------------------------------
-- Error Handling
---------------------------------------------------------------------

-- Simple example
BEGIN TRY
  PRINT 10/2;
  PRINT 'No error';
END TRY
BEGIN CATCH
  PRINT 'Error';
END CATCH;
GO

BEGIN TRY
  PRINT 10/0;
  PRINT 'No error';
END TRY
BEGIN CATCH
  PRINT 'Error';
END CATCH;
print 'exception did not terminate program, this is (almost) the same as FINALLY';
GO

-- Script to create Employees table in the current database
DROP TABLE IF EXISTS dbo.Employees;

CREATE TABLE dbo.Employees
(
  empid   INT         NOT NULL,
  empname VARCHAR(25) NOT NULL,
  mgrid   INT         NULL,
  CONSTRAINT PK_Employees PRIMARY KEY(empid),
  CONSTRAINT CHK_Employees_empid CHECK(empid > 0),
  CONSTRAINT FK_Employees_Employees
    FOREIGN KEY(mgrid) REFERENCES dbo.Employees(empid)
);
GO

-- Detailed Example
BEGIN TRY

  INSERT INTO dbo.Employees(empid, empname, mgrid)
    VALUES(1, 'Emp1', NULL);
  -- Also try with empid = 0, 'A', NULL

END TRY
BEGIN CATCH

  IF ERROR_NUMBER() = 2627
  BEGIN
    PRINT 'Handling PK violation...';
  END;
  ELSE IF ERROR_NUMBER() = 547
  BEGIN
    PRINT 'Handling CHECK/FK constraint violation...';
  END;
  ELSE IF ERROR_NUMBER() = 515
  BEGIN
    PRINT 'Handling NULL violation...';
  END;
  ELSE IF ERROR_NUMBER() = 245
  BEGIN
    PRINT 'Handling conversion error...';
  END;
  ELSE
  BEGIN
    PRINT 'Re-throwing error...';
    THROW;
  END;

  PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
  PRINT 'Error Message : ' + ERROR_MESSAGE();
  PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
  PRINT 'Error State   : ' + CAST(ERROR_STATE() AS VARCHAR(10));
  PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS VARCHAR(10));
  PRINT 'Error Proc    : ' + COALESCE(ERROR_PROCEDURE(), 'Not within proc');
 
END CATCH;
GO

-- Encapsulating Reusable Code
DROP PROC IF EXISTS dbo.ErrInsertHandler;
GO

CREATE PROC dbo.ErrInsertHandler
AS
SET NOCOUNT ON;

IF ERROR_NUMBER() = 2627
BEGIN
  PRINT 'Handling PK violation...';
END;
ELSE IF ERROR_NUMBER() = 547
BEGIN
  PRINT 'Handling CHECK/FK constraint violation...';
END;
ELSE IF ERROR_NUMBER() = 515
BEGIN
  PRINT 'Handling NULL violation...';
END;
ELSE IF ERROR_NUMBER() = 245
BEGIN
  PRINT 'Handling conversion error...';
END;

PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
PRINT 'Error Message : ' + ERROR_MESSAGE();
PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
PRINT 'Error State   : ' + CAST(ERROR_STATE() AS VARCHAR(10));
PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS VARCHAR(10));
PRINT 'Error Proc    : ' + COALESCE(ERROR_PROCEDURE(), 'Not within proc');
GO

-- Calling Proc in CATCH Block
BEGIN TRY

  INSERT INTO dbo.Employees(empid, empname, mgrid)
    VALUES(1, 'Emp1', NULL);

END TRY
BEGIN CATCH

  IF ERROR_NUMBER() IN (2627, 547, 515, 245)
    EXEC dbo.ErrInsertHandler;
  ELSE
    THROW;
  
END CATCH;
