/*1.     Rank employees by their total sales
(Total sales = Total no of orders handled, JOIN employees and orders table)*/
SELECT
	E.EMPLOYEE_ID,
	CONCAT(E.FIRST_NAME, ' ', E.LAST_NAME) AS EMPLOYEE_NAME,
	COUNT(O.ORDER_ID) as Total_orders,
	RANK() OVER (
		ORDER BY COUNT(o.order_id) 
	) AS order_rank
FROM
	EMPLOYEES E
	RIGHT JOIN ORDERS O ON E.EMPLOYEE_ID = O.EMPLOYEE_ID
	GROUP BY E.EMPLOYEE_ID, EMPLOYEE_NAME
	order by order_rank


/*2.      Compare current order's freight with previous and next order for each customer.
(Display order_id,  customer_id,  order_date,  freight,
Use lead(freight) and lag(freight).*/

SELECT
	ORDER_ID,
	CUSTOMER_ID,
	ORDER_DATE,
	FREIGHT,
	LAG(FREIGHT) OVER (
		ORDER BY
			ORDER_ID
	) AS PREVIOUS_ORDERFREIGHT,
	FREIGHT - LAG(FREIGHT) OVER (
		ORDER BY
			ORDER_ID
	) AS FREIGHT_DIFFERENCES,
	Lead(FREIGHT) OVER (
		ORDER BY
			ORDER_ID
	) AS Next_orderFreight
FROM
	ORDERS;

 
/*3.     Show products and their price categories, product count in each category, avg price:
        	(HINT:
·  	Create a CTE which should have price_category definition:
        	WHEN unit_price < 20 THEN 'Low Price'
            WHEN unit_price < 50 THEN 'Medium Price'
            ELSE 'High Price'
·  	In the main query display: price_category,  product_count in each price_category,  ROUND(AVG(unit_price)::numeric, 2) as avg_price)*/
SELECT
	CASE
		WHEN UNIT_PRICE < 20 THEN 'Low Price'
		WHEN UNIT_PRICE < 50 THEN 'Medium Price'
		ELSE 'HIGH price'
	END AS PRICE_CATEGORY,
	COUNT(CATEGORY_ID) AS PRODUCT_COUNT,
	ROUND(AVG(UNIT_PRICE)::NUMERIC, 2) AS AVG_PRICE
FROM
	PRODUCTS
GROUP BY
	PRICE_CATEGORY;

