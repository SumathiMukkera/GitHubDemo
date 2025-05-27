SELECT a.order_id, a.quantity, b.order_date, c.product_name,  d.company_name AS customer
FROM order_details a
INNER JOIN orders b ON a.order_id = b.order_id
INNER JOIN products c ON c.product_id = a.product_id
INNER JOIN customers d ON d.customer_id = b.customer_id ;

SELECT o.order_id, p.product_name, s.company_name, c.contact_name,
concat(e.first_name,' ', e.last_name) as employee_name, d.quantity FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN employees e ON o.employee_id = e.employee_id
LEFT JOIN shippers  s on o.ship_via = s.shipper_id
LEFT JOIN order_details d ON o.order_id = d.order_id
LEFT JOIN products p ON p.product_id = d.product_id ;

SELECT d.order_id, p.product_id, d.quantity, p.product_name
FROM order_details d
RIGHT JOIN products p ON d.product_id = p.product_id; 

SELECT  p.category_id, p.product_name, c.category_name FROM products p
FULL OUTER JOIN categories c ON p.category_id = c.category_id;

SELECT p.product_name, c.category_name FROM products p
CROSS JOIN categories c;

SELECT (e1.first_name || ' ' || e1.last_name) as employee_name,
(e2.first_name || ' ' ||e2.last_name) as manager_name FROM employees e1
INNER JOIN employees e2 ON e2.employee_id = e1.reports_to
WHERE e1.employee_id != e2.employee_id;

SELECT o.order_id, c.contact_name, c.customer_id,o.order_date FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.ship_via IS NULL;