-- AN EVENT TO REFRESH THE MONTHLY REPORT SUMMARY TABLE
CREATE EVENT refresh_monthly_report_event
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY + INTERVAL '04:00:00' HOUR_SECOND)
DO
	CALL refresh_monthly_report();

-- AN EVENT TO REFRESH THE DAILY REPORT SUMMARY TABLE
CREATE EVENT refresh_daily_report_event
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL 1 DAY + INTERVAL '04:00:00' HOUR_SECOND)
DO
	CALL refresh_daily_report();

-- A PROCEDURE TO UPDATE THE DAILY REPORT TABLE (DAILY UPDATING) - ADDING JUST PASSED DAY
DELIMITER //
CREATE PROCEDURE refresh_daily_report()
BEGIN 
INSERT INTO daily_report(order_date, revenue) 
	SELECT order_date, SUM(total_amount) AS total_amount
	FROM `order`
	WHERE order_date = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)
	GROUP BY order_date
	ORDER BY order_date;
END //
DELIMITER ;

-- A PROCEDURE TO UPDATE THE MONTHLY REPORT (UPADING ONCE PER DAY - ADDING THE PREVIOUS DAY DATA)
DELIMITER //
CREATE PROCEDURE refresh_monthly_report()
BEGIN 
DELETE FROM monthly_report
WHERE sale_month = DATE_FORMAT(CURRENT_DATE, '%Y-%m-01');    
    
INSERT INTO monthly_report (sale_month, product_id, product_name, total_quantity)
	SELECT 
		DATE_FORMAT(o.order_date, '%Y-%m-01') AS sale_month, 
		p.id AS product_id, 
		p.name AS product_name, 
		SUM(oi.quantity) AS total_quantity
	FROM product p INNER JOIN order_item oi
	ON p.id = oi.product_id
	INNER JOIN `order` o ON o.id = oi.order_id
	WHERE o.order_date >= DATE_FORMAT(CURRENT_DATE, '%Y-%m-1') AND o.order_date < DATE_FORMAT(DATE_ADD(CURRENT_DATE, INTERVAL 1 MONTH), '%Y-%m-1')
	GROUP BY sale_month, p.id;
END //
DELIMITER ;

-- POPULATING THE MONTHLY REPORTS TABLE (INITIAL LOADING)
INSERT INTO monthly_report(sale_month, product_id, product_name, total_quantity)
	SELECT 
		STR_TO_DATE(CONCAT(sale_month, '-01'), '%Y-%m-%d') AS sale_month, 
		product_id, 
		product_name, 
		total_quantity
	FROM  (
		SELECT 
			DATE_FORMAT(o.order_date, '%Y-%m') AS sale_month, 
			p.id AS product_id, 
			p.name AS product_name, 
			SUM(oi.quantity) AS total_quantity, 
			ROW_NUMBER() OVER(PARTITION BY DATE_FORMAT(o.order_date, '%Y-%m') ORDER BY SUM(oi.quantity) DESC) AS rn
		FROM product p INNER JOIN order_item oi
		ON p.id = oi.product_id
		INNER JOIN `order` o ON o.id = oi.order_id
		GROUP BY sale_month, p.id
	) AS monthly_product_sales
	WHERE rn <= 5;
    
-- POPULATING THE DAILY REPORTS TABLE (INITIAL LOADING) 
INSERT INTO daily_report(order_date, revenue) 
	SELECT order_date, SUM(total_amount) AS total_amount
	FROM `order`
	GROUP BY order_date
	ORDER BY order_date;

-- POPULATING THE DENORMALIZED TABLE (CUSTOMER + ORDER)
INSERT INTO customer_orders 
	SELECT c.id AS customer_id, c.first_name, c.last_name, c.email, o.id AS order_id, o.order_date, total_amount
	FROM `order` o JOIN customer c
	ON o.customer_id = c.id;