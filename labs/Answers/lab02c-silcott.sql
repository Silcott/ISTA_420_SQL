.echo on
.headers on

-- Name: James Silcott
-- ISTA420
-- File: lab02c
-- Date: July 15, 2020

-- 1. List the employee IDs with the number of sales by each employee from most 
-- sales to least. I want to recognize the employees with the most sales.

-- Identify the problem--
-- .table
-- .schema orders
-- 'has employee id and order id
-- select employeeid, count(orderid) from orders group by employeeid;
-- select employeeid, count(orderid) from orders group by employeeid order by count(orderid) desc;

select employeeid, count (orderid) as number_of_orders_count from orders group by employeeid 
order by number_of_orders_count desc;

sqlite database < file

-- 2. I want to look at the average discounts taken by all customers for products 
-- that cost more than $50.00. Specically, I want to know the average discount of
-- all orders for each product from the highest price to the lowest price.
select productid, unitprice, avg(discount) as averagediscount from orderdetails where
unitprice > 50 group by product id, unitprice order by unitprice desc ;




-- 3. I am doing an analysis of which shippers ship to each country, and I need a report 
-- showing the number of orders each shipper delivered to each country and the nuber of 
-- orders. I don't need the data where the number of orders is ten or less, but I need the 
-- report listed by country and the number of orders shipped to that country.
select shipperid, shipcountry, count (orderid) as ordercount from orders group by shipperid,
shipcountry having count (orderid ) > 10 order by shipcountry, ordercount desc;




-- 4. For each order, what was the time lag between the order date and the ship date?
select shipperid, orderdate as ordered, shippeddate as shipped, julianday(shippeddate) -
julianday(orderdate) as daysdifference from orders limit 10;




-- 5. Continuing with the previous query, I need the average time lag for each shipper.
select shipperid, orderdate as ordered, shippeddate as shipped, avg(julianday(shippeddate) -
julianday(orderdate)) as daysaverage from orders group by shipperid order by
daysaverage;




-- 6. I am doing inventory, and I need to know the total price of each product on hand, 
-- that is, the price of each product line, sorted alphabetically by product name.
select productid, productname, sum(unitsinstock * unitprice) as totalperproduct from
products group by productid;




-- 7. What is the dollar total we have tied up in inventory?
select productid, productname, sum(unitsinstock * unitprice) 
as totalperproduct from products group by productid order by productname;


-- 8. We have discovered that some customers favor certain employees. I need to know this 
-- information. I need a report of the most common employee/customer pairs, the nuber of 
-- times the employee took orders from the customer, and the number of orders. Alphabetize 
-- this by customer id. Omit customer/employee pairs whre the number of orders is less than five.
select sum(unitprice * unitsinstock) from products;



-- 9. How many days were in the service (if you are a veteran), or how many days will you 
-- serve (assuming you know your ETS date)?
select employeeid, customerid, count(orderid) from orders group by employeeid, 
customerid having count (orderid) > 4 order by customerid;



-- 10. Answer these questions using the built in time and date function.
-- What is today's date?
select date('now');


-- What was the rst day of the month?
select date('now', 'start of month');


-- What will be the rst day of the next month?
select date('now', 'start of month', '+1 month');


-- What is the last day of this month?
select date('now', 'start of month', '+1 month', '-1 day');
