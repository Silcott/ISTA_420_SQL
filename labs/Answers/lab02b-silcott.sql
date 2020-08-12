.echo on
.headers on

--Name: James Silcott
--File: lab02b--silcott.txt
--Date: July 9, 2020

--1. Who are the customers in N America?
select customerid, companyname, country from customers where country in ('USA', 'Mexico', 'Canada');

--2. What orders were placed in April 1998?
select orderid, orderdate from orders where orderdate like "1998-04-%";

--3. What sauces do we sell?
select productid, productname from products where productname like "%sauce%";

--4. You sell some kind of dried fruit that I liked very much.  What is its name?
select productid, productname from products where productname like "%dried%"; 

--5. What employees ship products to Germany in December?
select employeeid, shipcountry, shippeddate from orders where shipcountry = "Germany" AND  shippeddate like "%-12-%" order by employeeid ;

--6. We have an issue with product 19. I need to know thje total amount and the net amount of all orders for product 19 where the customer too a discount?
.select productid, SUM(UnitPrice), SUM(Quantity) from order_details  where productid = 19 AND Discount >0;

--7. I need a list of employees by title, first name, and last name, with the employee's position under their names, and a line separating each employee.
Select titleofcourtesy || " " || firstName || " " || lastname ||'
 ' || title || '
 ' || " " ||'
 'from employees;



-- 10. ‘I need a report telling me the most common pairing of customers and employees with 
-- the greatest order volume (by the number of orders placed). Exclude pairings with minimal orders.
select customerid, employeeid, count(orderid) as volumn from orders group by customerid, employeeid having count(orderid) > 3;

--11. I need a report listing the highest average selling product by product id. The average is determined by
--the total sales of each product id divided by the quantity of the product sold. Include only the highest
--20 products.
select productid, sum(unitprice * quantity) as total_price, sum(quantity) as total_quantity, (sum(unitprice * quantity) / sum(quantity)) as average from order_details group by productid limit 15;