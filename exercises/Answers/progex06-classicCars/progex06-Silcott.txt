-- Name: James Silcott
-- File: progex06-Silcott.txt
-- Date: August 2, 2020

-- SELECT name FROM sys.schemas
-- SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA


-- 1. Create an appropriate table schema.
DROP SCHEMA IF EXISTS ClassicCars
GO

DROP TABLE IF EXISTS Customers
DROP TABLE IF EXISTS Employees
DROP TABLE IF EXISTS Offices
DROP TABLE IF EXISTS OrderDetails
DROP TABLE IF EXISTS Orders
DROP TABLE IF EXISTS Payments
DROP TABLE IF EXISTS ProductLines
DROP TABLE IF EXISTS Products
GO

CREATE SCHEMA ClassicCars;
GO

-- 1. Create an appropriate table schema for all data files (the text files). Include primary and foreign keys,
-- plus any other constraints that you feel are necessary.
CREATE TABLE Customers
(
customerNumber nvarchar(500) not null
	constraint ClassicCars_Customers primary key,
customerName nvarchar(MAX), 
contactLastName nvarchar(MAX),
contactFirstName nvarchar(MAX),
phone nvarchar(MAX), 
addressLine1 nvarchar(MAX),
addressLine2 nvarchar(MAX),
city nvarchar(MAX),
stateLocation nvarchar(MAX),
--UNKNOWN varchar (MAX),
postalCode nvarchar(MAX) ,
country nvarchar(MAX),
salesRepEmployeeNumber nvarchar(MAX),
creditLimit nvarchar(MAX)
);
GO

CREATE TABLE Employees
(
employeeNumber varchar(20)not null
	constraint ClassicCars_Employees primary key,
lastName varchar (50), 
firstName varchar (50),
extension varchar (50),
email varchar(50),
officeCode varchar (50),
reportsTo varchar (50),
jobTitle varchar (50)
);
GO

CREATE TABLE Offices
(
officeCode varchar(20)not null
	constraint ClassicCars_Offices primary key,
city varchar (50), 
phone varchar (50),
addressLine1 varchar (50),
addressLine2 varchar(50),
state varchar (50),
country varchar (50),
postalCode varchar (50),
territory varchar (50)
);
GO

CREATE TABLE OrderDetails
(
orderNumber varchar(20),--not null
	--constraint ClassicCars_OrderDetails primary key,
productCode varchar (50),
quantityOrdered varchar (50),
priceEach varchar (50),
orderLineNumber varchar(50)
);
GO

CREATE TABLE Orders
(
orderNumber varchar(20)not null
	constraint ClassicCars_Orders primary key,
orderDate varchar (50),
requiredDate varchar(50),
shippedDate varchar (50),
orderStatus varchar(50),
comments varchar(250)
);
GO

CREATE TABLE Payments
(
customerNumber varchar(20), -- not null
	--constraint ClassicCars_Payments primary key,
checkNumber varchar (50) not null
	constraint ClassicCars_Payments primary key,
paymentDate varchar (50),
amount varchar (MAX)
);
GO

CREATE TABLE ProductLines
(
productLine varchar(500),--not null
	--constraint ClassicCars_ProductLines primary key,
textDescription varchar (500),
htmlDescription varchar (500),
imagePath varchar(MAX)
);
GO

CREATE TABLE Products
(
productCode varchar(500) not null
	constraint ClassicCars_Products primary key,
productName varchar(MAX),
productLine varchar(MAX),
productScale varchar(MAX),
productVendor varchar(MAX),
productDescription varchar(MAX),
quantityInStock varchar(MAX),
buyPrice varchar(MAX),
MSRP varchar(MAX)
);
GO

-- 2. Import the CSV data into the tables you just created.


BULK INSERT dbo.Customers 
FROM 'C:\Github\repo\ISTA_420_SQL\exercises\Answers\progex06-classicCars\Customers.txt'
WITH
(
	DATAFILETYPE = 'char',
	FIELDTERMINATOR = ',' ,
	ROWTERMINATOR = '\r'
);
GO

SELECT * From Customers;

BULK INSERT dbo.Employees FROM 'C:\Github\repo\ISTA_420_SQL\exercises\Answers\progex06-classicCars\Employees.csv'
WITH
(
	DATAFILETYPE = 'char',
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
);
GO

SELECT * From Employees;

BULK INSERT dbo.Offices FROM 'C:\Github\repo\ISTA_420_SQL\exercises\Answers\progex06-classicCars\Offices.csv'
WITH
(
	DATAFILETYPE = 'char',
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
);
GO

SELECT * From Offices;

BULK INSERT dbo.OrderDetails FROM 'C:\Github\repo\ISTA_420_SQL\exercises\Answers\progex06-classicCars\OrderDetails.csv'
WITH
(
	DATAFILETYPE = 'char',
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
);
GO

SELECT * From OrderDetails;


BULK INSERT dbo.Orders FROM 'C:\Github\repo\ISTA_420_SQL\exercises\Answers\progex06-classicCars\Orders.csv'
WITH
(
	DATAFILETYPE = 'char',
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'
);
GO

SELECT * From Orders;

BULK INSERT dbo.Payments FROM 'C:\Github\repo\ISTA_420_SQL\exercises\Answers\progex06-classicCars\Payments.csv'
WITH
(
	DATAFILETYPE = 'char',
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\r\n'
	--ROWTERMINATOR = '0x0a'
);
GO

SELECT * From Payments;

BULK INSERT dbo.ProductLines FROM 'C:\Github\repo\ISTA_420_SQL\exercises\Answers\progex06-classicCars\ProductLines.csv'
WITH
(
	DATAFILETYPE = 'char',
	FIELDTERMINATOR = ',',
	--ROWTERMINATOR = '\r\n'
	ROWTERMINATOR = '0x0a' 

);
GO

SELECT * From ProductLines;

BULK INSERT dbo.Products FROM 'C:\Github\repo\ISTA_420_SQL\exercises\Answers\progex06-classicCars\Products.csv'
WITH
(
	DATAFILETYPE = 'char',
	FIELDTERMINATOR = ',',
	--ROWTERMINATOR = '\r\n'
	ROWTERMINATOR = '0x0a'
);
GO

SELECT * From Products;

-- 3. Perform the following queries:
--(a) How many distinct products does ClassicModels sell?

Select DISTINCT count(p.productLine) from products p
where p.productLine = '"Classic Cars"';

-- (b) Report the name and city of customers who don't have sales representatives?

Select c.customerName, c.city, c.salesRepEmployeeNumber from Customers c
where c.salesRepEmployeeNumber = 'NULL';


-- (c) What are the names of executives with VP or Manager in their title? 
-- Use the CONCAT function to combine the employee's first name 
-- and last name into a single field for reporting.

Select CONCAT(firstName, ' ', lastName) as Name, jobTitle from Employees
where jobTitle LIKE '%VP%' OR jobTitle LIKE '%Manager%';


-- (d) Which orders have a value greater than $5,000?

Select orderNumber, CONVERT(money, priceEach) * CONVERT(int, quantityOrdered) as total from OrderDetails
where (Select CONVERT(money, priceEach) * CONVERT(int, quantityOrdered)) > 5000 
Order by (Select CONVERT(money, priceEach) * CONVERT(int, quantityOrdered)) ASC;

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- (e) Report the account representative for each customer.
Select customerName, salesRepEmployeeNumber from customers
---------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------


-- (f) Report total payments for Atelier graphique.

Select SUM((convert(money,amount))) from Payments 
JOIN Customers on Customers.customerNumber=Payments.customerNumber 
where customerName LIKE '%Atelier graphique%';



-- (g) Report the total payments by date

Select amount, 
convert(datetime, paymentDate) as dateConverted from Payments order by paymentDate ASC;

--------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
-- (h) Report the products that have not been sold.
select * from OrderDetails order by quantityOrdered ASC;
select * from products; 

select * from OrderDetails
JOIN Products on Products.productCode=OrderDetails.productCode order by quantityOrdered ASC;
----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------


-- (i) List the amount paid by each customer.
-- Orders table doesn't show customerNumber as shown in the diagram
Select orderNumber,  CONVERT(money, priceEach) * CONVERT(int, quantityOrdered) as TotalPrice from OrderDetails


-- (j) List products sold by order date.

select *, convert(datetime, orderdate) as dateConverted  from orders order by orderDate ASC;


-- (k) List the order dates in descending order for orders for the 1940 Ford Pickup Truck.
----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
select *, convert(datetime, orderdate) from Orders 
where Exists
(Select productCode from products where productName LIKE '%1940 Ford Pickup Truck%');

----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- (l) List the names of customers and their corresponding order number where a particular order from
-- that customer has a value greater than $25,000? 
Select orderNumber, CONVERT(money, priceEach) * CONVERT(int, quantityOrdered) as total from OrderDetails
where (Select CONVERT(money, priceEach) * CONVERT(int, quantityOrdered)) > 25000; 
----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

-- (m) Compute the commission for each sales representative, assuming the commission is 5% of the
-- value of an order. Sort by employee last name and first name.

Select *, CONVERT(money, priceEach) * CONVERT(int, quantityOrdered) * 1.05 - CONVERT(money, priceEach) * CONVERT(int, quantityOrdered) as Commission
from OrderDetails


-- (n) What is the difference in days between the most recent and oldest order date in the Orders file?
Select datediff(day, (MIN(convert(datetime, orderdate))), (MAX(convert(datetime, orderdate)))) from orders 


-- (o) Compute the average time between order date and ship date for each customer ordered by the
-- largest difference.

 update Orders
 set  shippedDate = replace(shippedDate, 'NULL', '2003-01-06 00:00:00.000')
select orderNumber,
(datediff
(day, 
(ISNULL(convert(datetime, orderdate), ' ')) + convert(datetime, orderdate), 
(ISNULL(convert(datetime, shippedDate), ' ')) + convert(datetime, shippedDate)) / count(orderDate))
as diffdatebetween 
from orders 
group by shippedDate, orderDate, orderNumber
order by diffdatebetween desc
