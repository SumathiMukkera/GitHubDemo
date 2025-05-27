-----Alter Table --------------

ALTER Table employees
ADD column linkedin_profile varchar(100);

select * from employees;

ALTER Table employees
ALTER column linkedin_profile TYPE text;

UPDATE employees
SET linkedin_profile = employeeid || 'linkedin_profile';

ALTER Table employees
ADD CONSTRAINT linkedin_profile_const UNIQUE (linkedin_profile);

ALTER TABLE employees
ALTER COLUMN linkedin_profile SET NOT NULL;

ALTER TABLE employees 
DROP COLUMN linkedin_profile;

-----Querying (Select) ----------

select split_part(employeename,' ',1)  as firstname , 
split_part(employeename, ' ',2) as lastname ,
title
from employees;

select DISTINCT unitprice from products;

select * from customers
ORDER By companyname ASC;

select productname, unitprice as price_in_usd from products;

----  Filtering ------
 	
select * from customers
where country = 'Germany';

select * from customers
where country In('France' , 'Spain');

select * from orders

select orderid,orderdate,freight,shippeddate,date_part('year', orderdate) as order_year from orders
where DATE_PART('year',orderdate )= 1993
AND (freight > 50 OR shippeddate IS NOT NULL);
--------- using extract -----------
select orderid, orderdate,freight,shippeddate,
EXTRACT (year from orderdate) as orderYear 
from orders
where DATE_PART('year',orderdate )= 2014
AND (freight > 50 OR shippeddate IS NOT NULL);

select productid,productname,unitprice from products
where unitprice > 15 ;

select * from employees 
where country = 'USA' 
AND title = 'Sales Representative';

select * from products
where discontinued = false 
AND unitprice > 30;

----------  LIMIT/FETCH ---------------
select * from orders
LIMIT 10;

select * from orders
FETCH FIRST 10 rows only;

select * from orders
offset 10 rows 
FETCH NEXT 10 ROWS ONLY

--------- Filtering (IN, BETWEEN) -------------------
select * from customers
where contacttitle IN ('Sales Representative' , 'Owner');

select * from orders
where orderdate BETWEEN '2013-01-01' AND '2013-12-31';

select * from products
where categoryid NOT IN (1, 2, 3);

select * from customers
where companyname LIKE 'A%';

-------------INSERT into orders table: -------------------
INSERT INTO orders(OrderID, customerid, employeeid, orderdate, requireddate, shippeddate, shipperid, freight)
values(11078, 'ALFKI', 5, '2025-04-23', '2025-04-30', '2025-04-25', 2, 45.50);

select * from orders
where orderid = 11078;

UPDATE products 
set unitprice = unitprice * 1.10
where productid = 2;

select * from products
where productid = 2;






