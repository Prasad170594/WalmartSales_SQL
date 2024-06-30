-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;
USE walmartSales;

-- Create the table
CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price FLOAT NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT NOT NULL,
    total FLOAT NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs FLOAT NOT NULL,
    gross_margin_pct FLOAT NOT NULL,
    gross_income FLOAT NOT NULL,
    rating FLOAT NOT NULL
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/WalmartSalesData.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(invoice_id, branch, city, customer_type, gender, product_line, unit_price, quantity, tax_pct, total, date, time, 
payment, cogs, gross_margin_pct, gross_income, rating);


-- Total number of records
SELECT COUNT(*) AS no_of_records FROM sales;


-- 1st 10 records
SELECT * FROM sales LIMIT 10;


-- add required columns
ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(255),
ADD COLUMN day_name VARCHAR(255),
ADD COLUMN month_name VARCHAR(255);



SET SQL_SAFE_UPDATES = 0;
UPDATE sales
SET time_of_day = CASE
    WHEN TIME(time) BETWEEN '06:00:00' AND '12:00:00' THEN 'Morning'
    WHEN TIME(time) BETWEEN '12:00:01' AND '18:00:00' THEN 'Afternoon'
    WHEN TIME(time) BETWEEN '18:00:01' AND '24:00:00' THEN 'Evening'
    ELSE 'Night'
END;


UPDATE sales
SET day_name = DAYNAME(date);


UPDATE sales
SET month_name = MONTHNAME(date);
SET SQL_SAFE_UPDATES = 1;


-- Generic questions
-- Number of unique cities 
SELECT COUNT(DISTINCT(city)) as no_of_cities
from sales;


-- City in which each branch is located
SELECT branch, city
FROM sales
GROUP BY branch, city;


-- 1. PRODUCT ANALYSIS
-- No. of unique product lines 
SELECT COUNT(DISTINCT(product_line)) AS No_of_prod_lines 
FROM sales;


-- most common payment method
SELECT payment, COUNT(payment) AS transactions
FROM sales
GROUP BY payment
ORDER BY transactions DESC
LIMIT 1;


-- most selling product line
SELECT product_line, SUM(quantity) AS qty_sold
FROM sales
GROUP BY product_line
ORDER BY qty_sold DESC
LIMIT 1;


-- total revenue by month
SELECT month_name, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;


-- month with the largest COGS
SELECT month_name, SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;


-- product line with the largest revenue
SELECT product_line, SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;


-- city with the largest revenue
SELECT city, SUM(total) as total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;


-- product line with the largest VAT
SELECT product_line, MAX(tax_pct) AS max_tax
FROM sales 
GROUP BY product_line 
ORDER BY max_tax
LIMIT 1;


-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT product_line,
	CASE
		WHEN SUM(quantity) > (SELECT AVG(quantity) from sales) THEN 'Good'
		ELSE 'Bad'
	END as performance
FROM sales
GROUP BY product_line;


-- branch sold more products than average product sold
SELECT branch, SUM(quantity) as qty_sold
FROM sales
GROUP BY branch
HAVING qty_sold > (SELECT AVG(quantity) from sales);


-- the most common product line by gender
SELECT product_line, gender, count(*) as counts
FROM sales
GROUP BY gender, product_line
ORDER BY counts DESC


-- the average rating of each product line
SELECT product_line, AVG(rating) as avg_rating
from sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- 2. Sales Analysis
-- Number of sales made in each time of the day per weekday
SELECT day_name, time_of_day, count(*) AS sales_made
from sales
GROUP BY day_name, time_of_day
ORDER BY day_name;


-- Which of the customer types brings the most revenue
SELECT customer_type, SUM(total) as total_sales
from sales
GROUP BY customer_type
ORDER BY total_sales DESC
LIMIT 1;


-- city that has the largest tax percent/ VAT (**Value Added Tax**)
SELECT city, MAX(tax_pct) as max_tax_pct
FROM sales
GROUP BY city
order by max_tax_pct DESC
limit 1;


-- customer type pays the most in VAT
SELECT customer_type, SUM(tax_pct * total) as tax_paid
from sales
GROUP BY customer_type
ORDER BY tax_paid DESC
LIMIT 1;


-- 3. Customer Analysis
-- unique customer in data
SELECT COUNT(DISTINCT(customer_type)) as no_of_cust_type
FROM sales;


-- unique payment methods
SELECT COUNT(DISTINCT(payment)) AS no_paymt_mthd
FROM sales;

-- most common customer type
SELECT customer_type, count(*) as no_of_cust
from sales
GROUP BY customer_type
ORDER BY no_of_cust DESC
LIMIT 1;


-- customer type buys the most
SELECT customer_type, SUM(total) as total_amt
FROM sales
GROUP BY customer_type
ORDER BY total_amt DESC
LIMIT 1;


-- gender of most of the customers
SELECT gender, COUNT(*) as count
from sales
GROUP BY gender
ORDER BY count DESC
LIMIT 1;


-- gender distribution per branch
SELECT branch, gender, count(*) as count
FROM sales
GROUP BY branch, gender
ORDER BY branch;


-- Which time of the day do customers give most ratings
SELECT time_of_day, avg(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC
LIMIT 1;


-- Which time of the day do customers give most ratings per branch
SELECT branch, time_of_day, avg(rating) AS avg_rating
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, avg_rating DESC


-- Which day fo the week has the best avg ratings
SELECT day_name, avg(rating) as avg_rating
from sales
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 1;


-- Which day of the week has the best average ratings per branch
SELECT branch, day_name, avg(rating) AS avg_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC;

/*
Conclusion-
From Walmart's sales data across Yangon, Mandalay, and Naypyitaw branches, we found that electronic accessories are the 
top-selling items, bringing in the most money. Food and beverages are also popular and generate the highest revenue overall. 
Most customers are members, who contribute the most to total sales and taxes. Mondays are generally rated highest by customers, 
indicating they're most satisfied at the start of the week. Each branch has its own customer satisfaction trends throughout the week, 
suggesting different approaches might be needed to boost sales and keep customers happy. These findings could help Walmart 
make better decisions to improve service and sales.
/*