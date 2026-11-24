CREATE DATABASE IF NOT EXISTS coffee_shop_analytics;
USE coffee_shop_analytics;

DROP TABLE IF EXISTS coffee_sales;
CREATE TABLE coffee_sales (
  transaction_id BIGINT PRIMARY KEY,
  transaction_date DATE,
  transaction_time TIME,
  store_id INT,
  store_location VARCHAR(80),
  product_id INT,
  transaction_qty INT,
  unit_price DECIMAL(10,2),
  product_category VARCHAR(80),
  product_type VARCHAR(120),
  product_detail VARCHAR(180),
  size VARCHAR(40),
  total_bill DECIMAL(12,2),
  length INT,
  month_name VARCHAR(20),
  day_name VARCHAR(20),
  Hour INT,
  day_of_week INT,
  Month INT
);

insert into coffee_sales values
(1,'2023-01-01','08:15:00',5,'Lower Manhattan',32,2,3.00,'Coffee','Gourmet brewed coffee','Ethiopia Rg','Large',6.00,6,'January','Sunday',8,1,1),
(2, '2023-01-01', '09:10:00', 5, 'Lower Manhattan', 33, 1, 2.50, 'Coffee', 'Drip coffee', 'Our Old Time Diner Blend', 'Regular', 2.50, 6, 'January', 'Sunday', 9, 1, 1),
(3, '2023-01-02', '10:20:00', 8, 'Astoria', 34, 2, 3.75, 'Tea', 'Brewed Chai tea', 'Traditional Blend Chai', 'Large', 7.50, 6, 'January', 'Monday', 10, 2, 1),
(4, '2023-01-03', '11:30:00', 3, 'Hell''s Kitchen', 35, 1, 4.00, 'Coffee', 'Barista Espresso', 'Dark Chocolate', 'Small', 4.00, 6, 'January', 'Tuesday', 11, 3, 1);

-- Example (edit absolute path for your system and enable LOCAL INFILE if required):
-- LOAD DATA LOCAL INFILE 'C:/path/coffee_shop_sales.csv'
-- INTO TABLE coffee_sales
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- 01. Overall KPIs
SELECT ROUND(SUM(total_bill),2) AS total_revenue, SUM(transaction_qty) AS units_sold,
       COUNT(DISTINCT transaction_id) AS transactions, ROUND(AVG(total_bill),2) AS avg_row_bill
FROM coffee_sales;

-- 02. Monthly revenue and month-over-month change
WITH monthly AS (
  SELECT Month AS month_num, month_name, SUM(total_bill) AS revenue
  FROM coffee_sales GROUP BY Month, month_name
)
SELECT month_num, month_name, ROUND(revenue,2) AS revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY month_num),2) AS revenue_change,
       ROUND(100*(revenue/LAG(revenue) OVER (ORDER BY month_num)-1),2) AS mom_pct
FROM monthly ORDER BY month_num;

-- 03. Revenue and units by store
SELECT store_location, ROUND(SUM(total_bill),2) AS revenue, SUM(transaction_qty) AS units_sold,
       COUNT(DISTINCT transaction_id) AS transactions
FROM coffee_sales GROUP BY store_location ORDER BY revenue DESC;

-- 04. Category performance
SELECT product_category, ROUND(SUM(total_bill),2) AS revenue, SUM(transaction_qty) AS units_sold,
       COUNT(DISTINCT transaction_id) AS transactions
FROM coffee_sales GROUP BY product_category ORDER BY revenue DESC;

-- 05. Top 10 product types by revenue
SELECT product_category, product_type, ROUND(SUM(total_bill),2) AS revenue, SUM(transaction_qty) AS units_sold
FROM coffee_sales GROUP BY product_category, product_type ORDER BY revenue DESC LIMIT 10;

-- 06. Sales by hour
SELECT Hour AS sales_hour, ROUND(SUM(total_bill),2) AS revenue, SUM(transaction_qty) AS units_sold,
       COUNT(DISTINCT transaction_id) AS transactions
FROM coffee_sales GROUP BY Hour ORDER BY revenue DESC;

-- 07. Sales by weekday
SELECT day_name, ROUND(SUM(total_bill),2) AS revenue, SUM(transaction_qty) AS units_sold
FROM coffee_sales GROUP BY day_name
ORDER BY FIELD(day_name,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

-- 08. Store x category performance matrix
SELECT store_location, product_category, ROUND(SUM(total_bill),2) AS revenue
FROM coffee_sales GROUP BY store_location, product_category
ORDER BY store_location, revenue DESC;

-- 09. Revenue share by category
SELECT product_category, ROUND(SUM(total_bill),2) AS revenue,
       ROUND(100*SUM(total_bill)/(SELECT SUM(total_bill) FROM coffee_sales),2) AS revenue_share_pct
FROM coffee_sales GROUP BY product_category ORDER BY revenue DESC;

-- 10. Average bill by hour
SELECT Hour AS sales_hour, ROUND(AVG(total_bill),2) AS avg_bill, COUNT(*) AS row_count
FROM coffee_sales GROUP BY Hour ORDER BY sales_hour;

-- 11. Lowest revenue product types (at least 100 rows)
SELECT product_category, product_type, ROUND(SUM(total_bill),2) AS revenue, SUM(transaction_qty) AS units_sold
FROM coffee_sales GROUP BY product_category, product_type HAVING COUNT(*) >= 100
ORDER BY revenue ASC LIMIT 10;

-- 12. Daily revenue trend
SELECT transaction_date, ROUND(SUM(total_bill),2) AS revenue, SUM(transaction_qty) AS units_sold
FROM coffee_sales GROUP BY transaction_date ORDER BY transaction_date;
