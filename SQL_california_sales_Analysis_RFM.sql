--creating tables
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10),
    age INT,
    payment_method VARCHAR(20),
    age_group TEXT,
    price NUMERIC(10,2)
);

SELECT * FROM customers;

CREATE TABLE shopping_mall (
    shopping_mall VARCHAR(100) PRIMARY KEY,
    construction_year INT,
    area_sqm INT,
    location VARCHAR(50),
    store_count INT
);
SELECT * FROM shopping_mall;


CREATE TABLE sales (
    invoice_no VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    category VARCHAR(50),
    quantity INT,
    invoice_date DATE,
    price NUMERIC(10,2),
    shopping_mall VARCHAR(100),
    month_name VARCHAR(15),
    year INT,
    location VARCHAR(50),
    revenue NUMERIC(12,2)
   
);
SELECT * FROM sales;

--Select specific columns

SELECT customer_id, gender, age
FROM customers;

--DISTINCT values 
SELECT DISTINCT category
FROM sales;

--WHERE Clause (filtering)
--Customers older than 40
SELECT *FROM customers
WHERE age > 40;

--Sales from Clothing category
SELECT *FROM sales
WHERE category = 'Clothing';

--Filter High-Value Transactions
SELECT invoice_no, customer_id, revenue
FROM sales
WHERE revenue > 10000;

--Highest priced products first
SELECT category, price
FROM sales
ORDER BY price DESC;

--LIMIT / TOP
SELECT category, price
FROM sales
ORDER BY price DESC
LIMIT 10;

--Sales from multiple categories
SELECT *FROM sales
WHERE category IN ('Clothing', 'Technology');

--TASK: Customers from Specific Regions
SELECT DISTINCT s.customer_id, m.location
FROM sales s
JOIN shopping_mall m
ON s.shopping_mall = m.shopping_mall
WHERE m.location IN ('Los Angeles', 'Irvine');

--Total revenue
SELECT SUM(revenue) AS total_revenue
FROM sales;

--Total orders
SELECT COUNT(invoice_no) AS total_orders
FROM sales;

--Average order value
SELECT AVG(revenue) AS avg_order_value
FROM sales;

--Revenue by Category
SELECT category,
       SUM(revenue) AS category_revenue
FROM sales
GROUP BY category;

--Revenue by shopping mall
SELECT shopping_mall,
       SUM(revenue) AS mall_revenue
FROM sales
GROUP BY shopping_mall;

--Categories with revenue > 10M
SELECT category,
       SUM(revenue) AS total_revenue
FROM sales
GROUP BY category
HAVING SUM(revenue) > 10000000;

--TASK: Average Order Value per Category
SELECT category,
       AVG(revenue) AS avg_order_value
FROM sales
GROUP BY category;

--TASK: Monthly Sales Summary
SELECT
    EXTRACT(YEAR FROM invoice_date) AS year,
    EXTRACT(MONTH FROM invoice_date) AS month,
    SUM(revenue) AS monthly_revenue
FROM sales
GROUP BY
    EXTRACT(YEAR FROM invoice_date),
    EXTRACT(MONTH FROM invoice_date)
ORDER BY year, month;

--Which category has highest average sales price?
SELECT category,
       AVG(price) AS avg_price
FROM sales
GROUP BY category
ORDER BY avg_price DESC
LIMIT 1;

--Total Orders & Total Revenue
SELECT
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(revenue) AS total_revenue
FROM sales;

--Top Categories by Revenue
SELECT
    category,
    SUM(revenue) AS category_revenue
FROM sales
GROUP BY category
ORDER BY category_revenue DESC;

--Average Order Value (AOV)
SELECT
    ROUND(SUM(revenue) / COUNT(DISTINCT invoice_no), 2) AS avg_order_value
FROM sales;

--RFM Analysis
--Choosing a Reference Date
SELECT MAX(invoice_date) FROM sales;

--Calculate R, F, M per customer
SELECT
    customer_id,

    -- Recency (days since last purchase)
    DATE '2023-12-31' - MAX(invoice_date) AS recency,

    -- Frequency (number of purchases)
    COUNT(DISTINCT invoice_no) AS frequency,

    -- Monetary (total revenue)
    SUM(revenue) AS monetary

FROM sales
GROUP BY customer_id;

--RFM Scoring using NTILE
WITH rfm_base AS (
    SELECT
        customer_id,
        DATE '2023-12-31' - MAX(invoice_date) AS recency,
        COUNT(DISTINCT invoice_no) AS frequency,
        SUM(revenue) AS monetary
    FROM sales
    GROUP BY customer_id
)

SELECT
    customer_id,
    recency,
    frequency,
    monetary,

    NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary DESC) AS m_score

FROM rfm_base;

--Customer Segmentation by champions, loyal, potential loyalist, At risj, Lost customers, Need Attention
WITH rfm_scores AS (
    SELECT
        customer_id,
        NTILE(5) OVER (ORDER BY DATE '2023-12-31' - MAX(invoice_date)) AS r,
        NTILE(5) OVER (ORDER BY COUNT(DISTINCT invoice_no) DESC) AS f,
        NTILE(5) OVER (ORDER BY SUM(revenue) DESC) AS m
    FROM sales
    GROUP BY customer_id
)

SELECT
    customer_id,
    r, f, m,

    CASE
        WHEN r >= 4 AND f >= 4 AND m >= 4 THEN 'Champions'
        WHEN r >= 3 AND f >= 3 THEN 'Loyal Customers'
        WHEN r >= 4 AND f <= 2 THEN 'Potential Loyalist'
        WHEN r <= 2 AND f >= 3 THEN 'At Risk'
        WHEN r = 1 AND f = 1 THEN 'Lost Customers'
        ELSE 'Need Attention'
    END AS customer_segment

FROM rfm_scores;




