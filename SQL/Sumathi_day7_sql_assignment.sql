/*1. Create view vw_updatable_products (use same query whatever I used in the training)
Try updating view with below query and see if the product table also gets updated.
Update query:
UPDATE updatable_products SET unit_price = unit_price * 1.1 WHERE units_in_stock < 10;*/

CREATE VIEW vw_updatable_products AS 
SELECT product_id,
product_name, unit_price,
units_in_stock, discontinued
FROM products 
WHERE discontinued = 0
WITH CHECK OPTION;

UPDATE  vw_updatable_products
SET unit_price = unit_price * 1.1 
WHERE units_in_stock < 10 ;

SELECT * FROM categories

UPDATE Categories
SET category_id = 1
WHERE category_id = 1001;

/* 2. Transaction:
Update the product price for products by 10% in category id=1
Try COMMIT and ROLLBACK and observe what happens.*/


BEGIN; 

UPDATE  products
SET unit_price = unit_price * 1.1 
WHERE category_id = 1 ;

/* DO $$ 
BEGIN 
IF EXISTS (
SELECT 1
FROM products 
WHERE category_id = 1 AND unit_price > 50 
)THEN 
RAISE EXCEPTION 'Some price exceed  $50';
ELSE 
RAISE NOTICE 'price update successful.';
END IF ;
END $$;*/

COMMIT;

ROLLBACK;

SELECT * FROM products where category_id =1;

/* 3. Create a regular view which will have below details (Need to do joins):
Employee_id,
Employee_full_name,
Title,
Territory_id,
territory_description,
region_description */

CREATE VIEW Regular_view AS
SELECT e.employee_id,
e.first_name || ' ' || e.last_name as employee_full_name,
e.title,
t.territory_id, 
t.territory_description,
r.region_description
FROM employees e
JOIN employee_territories et ON e.employee_id = et.employee_id
JOIN territories t ON et.territory_id = t.territory_id
JOIN region r ON t.region_id = r.region_id

SELECT * FROM regular_view ;

 
/* 4. Create a recursive CTE based on Employee Hierarchy */
 
WITH RECURSIVE cte_Employee_hierarchy AS (
    SELECT 
        employee_id,
        first_name,
        last_name,
        reports_to,
        0 AS level
    FROM employees
    WHERE reports_to IS NULL

    UNION ALL

    SELECT 
        e.employee_id,         
        e.first_name,
        e.last_name,
        e.reports_to,
        eh.level + 1          
    FROM employees e
    JOIN cte_Employee_hierarchy eh 
        ON e.reports_to = eh.employee_id
) 

SELECT
	EMPLOYEE_ID,
	FIRST_NAME || ' ' || LAST_NAME AS EMPLOYEE_NAME,
	REPORTS_TO,
	LEVEl
FROM
	CTE_EMPLOYEE_HIERARCHY
	order by level;