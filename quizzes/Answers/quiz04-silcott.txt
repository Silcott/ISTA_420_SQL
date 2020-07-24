-- Name: James Silcott
-- File: quiz04-silcott.sql
-- Date: 23 July 2020

USE TSQLV4;

-- 1. Write a query that returns the company name, contact name, and city of all customers who made an
-- order on the last date that orders were taken. Use nested self contained, list valued subqueries in the
-- WHERE clause. Your output should be as follows:


SELECT companyname, contactname, city
FROM Sales.Customers AS C
INNER JOIN Sales.Orders as O 
ON C.custid = O.custid 
WHERE orderdate = (SELECT MAX(O.orderdate)
FROM Sales.Orders as O)
ORDER BY C.contactname DESC; 


-- 2. Write a query that returns the company name, contact name, and city of all customers who made an
-- order in July, 2014. Use nested self contained, list valued subqueries in the WHERE clause. Your
-- output should be as follows:

SELECT distinct companyname, contactname, city
FROM Sales.Customers AS C 
INNER JOIN Sales.Orders as O 
ON C.custid = O.custid 
WHERE orderdate IN (SELECT orderdate FROM Sales.Orders as O
WHERE YEAR(orderdate) = 2014 AND MONTH(orderdate) = 7) ORDER BY C.contactname ASC;


-- 3. Write a query that returns the customer ID, order ID, order date, and the unit price of the highest
-- priced item in the order for all orders shipped to Norway. Use a self contained, scalar valued subquery
-- in the SELECT clause. Your output should be as follows:



select o.custid, od.orderid, o.orderdate, max(od.unitprice) as maxunitp from Sales.OrderDetails as od
inner join sales.Orders as o on od.orderid = o.orderid
group by o.custid, od.orderid, o.orderdate, o.shipcountry
having o.shipcountry =
(select distinct shipcountry from sales.Orders where shipcountry like 'Norway')