.echo on
.header on

-- Name: James Silcott
-- QUIZ: TSQL 02
-- Date: July 9, 2020


--1. How many seafood products do we have?
select count(productid) from products where categoryid = 8;


--2. What are the names and IDs of our seafood products?
select productid, productname, categoryid, unitsinstock from products where categoryid = 8;


--3. What is the average price of our seafood products?
select avg(unitprice) from products where categoryid = 8;


--4. What is our highest priced seafood product, and how much does it cost?
select productname || + " " || MAX(unitprice) from products where categoryid = 8;


--5. What is our lowest priced seafood product, and how much does it cost?
select productname || + " " || MIN(unitprice) from products where categoryid = 8;


--6. How many customers do we have in Denmark?
select count(*) from customers where country = "Denmark";


--7. What are the customer names and IDs of our Danish customers?
select customerid, contactname, country from customers where country = "Denmark";


--8. Which customers do NOT have a fax number? This one is very tricky!
select customerid, contactname, fax from customers where rtrim(fax, '') LIKE '';
