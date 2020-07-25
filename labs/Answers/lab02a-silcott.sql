.echo on
.headers on

--Name: James Silcott
--File: lab02a--silcott.sql
--Date: July 8, 2020

--1. What are the regions?
select * from region;

--2. What are the cities?
select TerritoryDescription from territories;

--3. What are the cities in the Southern region?
select territorydescription from territories where RegionID = 4;
--or
select * from territories where regionid = 4;

--4. How do you run this query with the fully qualified column name?
select territories.territorydescription from territories where RegionID = 4;
--or
select territories.territoryid, territories.TerritoryDescription, territories.RegionID from territories where regionid = 4;

--5. How do you run this query with table alias?
select t.territoryid, t.TerritoryDescription, t.RegionID from territories t where regionid = 4;
--or but don't use
select t.territoryid, t.TerritoryDescription, t.RegionID from territories as t where regionid = 4;

--6. What is the contact name, telephone number, and city for each customer?
select c.customerid, c.companyname, c.contactname, c.city, c.phone from customers c;

--7. What are the ten products currently out of stock?
select p.productid, p.productname, p.unitsinstock from products p where p.unitsinstock = 0;

--8. What are the ten products currently in stock with the least amount on hand?
select p.productid, p.productname, p.unitsinstock from products p where p.unitsinstock > 0 order by p.unitsinstock limit 10;

--9. What are the five most expensive products in stock?
select p.productid, p.productname, p.unitprice from products p where p.unitsinstock > 0 order by p.unitprice desc limit 5;

--10. How many products does Northwind have? How many customers? How many suppliers?
select count(*) from customers;
select count(*) from products;
select count(*) from suppliers;


--STEPS:
-- Identify what is needed
--  .tables
--  select * from region;
--  .schema territories