/*1.      GROUP BY with WHERE - Orders by Year and Quarter
Display, order year, quarter, order count, avg freight cost only for those orders where 
freight cost > 100  */
SELECT 
 EXTRACT(YEAR FROM order_date) as year,
 EXTRACT(QUARTER FROM order_date) as quarter,
 count(*) as order_count, AVG(freight) as frieght_cost
FROM orders
WHERE freight > 100
GROUP BY EXTRACT(YEAR FROM order_date),
EXTRACT(QUARTER FROM order_date);

/* 2.GROUP BY with HAVING - High Volume Ship Regions
Display, ship region, no of orders in each region, min and max freight cost
 Filter regions where no of orders >= 5 */
SELECT 
ship_region, count(ship_region) as no_of_orders,
MIN(freight) as min_freight,
MAX(freight) as max_freight
FROM orders
GROUP BY ship_region 
HAVING count(ship_region) >= 5;

---3. Get all title designations across employees and customers ( Try UNION & UNION ALL)
SELECT title
FROM employees 

UNION 

SELECT contact_title
FROM customers;

-----4.Find categories that have both discontinued and in-stock products
---(Display category_id, instock means units_in_stock > 0, Intersect)

SELECT category_id 
FROM categories

INTERSECT

SELECT category_id
FROM products
WHERE units_in_stock > 0 
AND discontinued = 1;

---5) Find orders that have no discounted items (Display the  order_id, EXCEPT)
SELECT order_id 
FROM orders

EXCEPT 

SELECT order_id 
FROM order_details
WHERE discount = 0;

select * from products;