-- (1) QUERYING THE DAILY REPORT (BEFORE IMPROVEMENT - NO SUMMARY TABLE)
SELECT order_date, SUM(total_amount) AS total_amount
FROM `order`
WHERE order_date = '2024-01-10'
GROUP BY order_date;

-- (1.1) QUERYING THE DAILY REPORT (AFTER IMPROVEMENT - USING THE SUMMARY TABLE)
SELECT order_date, revenue 
FROM daily_report 
WHERE order_date = '2024-01-10';

-- COUNT OF UNITS PER PRODUCT PER ALL ORDERS
SELECT p.id, p.name, SUM(quantity) as quantity
FROM product p INNER JOIN order_item oi
ON p.id = oi.product_id
INNER JOIN `order` o ON o.id = oi.order_id
GROUP BY p.id;

-- (2) QUERYING THE MONTHLY REPORT (Before IMPROVEMENT)
SELECT 
	DATE_FORMAT('2022-01-01', '%Y-%m-01') AS sale_month, 
    p.id AS product_id, 
    p.name AS product_name, 
    SUM(quantity) as total_quantity
FROM product p INNER JOIN order_item oi
ON p.id = oi.product_id
INNER JOIN `order` o ON o.id = oi.order_id
WHERE o.order_date >= '2022-01-01' AND o.order_date < '2022-02-01'
GROUP BY p.id
ORDER BY total_quantity DESC
LIMIT 5;

-- (2.1) QUERYING THE MONTHLY REPORT (AFTER IMPROVEMENT - USING THE SUMMARY TABLE)
SELECT * 
FROM monthly_report
WHERE sale_month = '2022-01-01'
ORDER BY total_quantity DESC;

-- (3) QUERY to retrieve a list of customers who have placed orders totaling more than $500 in the past month.
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer_name, SUM(o.total_amount) AS total_amount
FROM `order` o JOIN  customer c
ON c.id = o.customer_id
WHERE 
	o.order_date >= DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y-%m-01') AND 
    o.order_date < DATE_FORMAT(CURRENT_DATE, '%Y-%m-01')
GROUP BY c.id
HAVING total_amount > 500;

-- (3.1) QUERY to retrieve a list of customers who have placed orders totaling more than $500 in the past month. (AFTER DENORMALIZATION)
SELECT CONCAT(co.first_name, ' ', co.last_name) AS customer_name, SUM(co.total_amount) AS total_amount
FROM customer_orders co
WHERE 
	co.order_date >= DATE_FORMAT(CURRENT_DATE - INTERVAL 1 MONTH, '%Y-%m-01') AND 
    co.order_date < DATE_FORMAT(CURRENT_DATE, '%Y-%m-01')
GROUP BY co.customer_id, customer_name
HAVING total_amount > 500;