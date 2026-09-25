
-- =====================================================
-- ZEPTO PRODUCT & INVENTORY ANALYSIS
-- SQL Project
-- =====================================================

-- View all data
SELECT *
FROM zepto;

drop table if exists zepto;

create table zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,	
quantity INTEGER
);

-- data exploration

--count of rows
select count(*) from zepto;

--sample data
SELECT * FROM zepto
LIMIT 10;

-- null values
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

-- different product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

--products in stock vs out of stock
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

-- product names present multiple times
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING count(sku_id) > 1
ORDER BY count(sku_id) DESC;

--data cleaning

--products with price = 0
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0;

-- convert paise to rupees
UPDATE zepto
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

SELECT mrp, discountedSellingPrice FROM zepto;

-- data analysis
-- =====================================================
-- Q1. Find the top 10 best-value products based on
--     discount percentage
-- =====================================================

SELECT DISTINCT
       name,
       mrp,
       discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;


-- =====================================================
-- Q2. Find products with high MRP that are out of stock
-- =====================================================

SELECT DISTINCT
       name,
       mrp
FROM zepto
WHERE outOfStock = TRUE
  AND mrp > 301
ORDER BY mrp DESC;


-- =====================================================
-- Q3. Calculate potential revenue for each category
-- =====================================================

SELECT
       category,
       SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;


-- =====================================================
-- Q4. Find products where MRP is greater than ₹500
--     and discount is less than 10%
-- =====================================================

SELECT DISTINCT
       name,
       mrp,
       discountPercent
FROM zepto
WHERE mrp > 500
  AND discountPercent < 10
ORDER BY mrp DESC,
         discountPercent DESC;


-- =====================================================
-- Q5. Find the top 5 categories with the highest
--     average discount percentage
-- =====================================================

SELECT
       category,
       ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;


-- =====================================================
-- Q6. Find the price per gram for products above 100g
--     and sort by best value
-- =====================================================

SELECT
       name,
       discountedSellingPrice,
       weightInGms,
       ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms > 100
ORDER BY price_per_gram ASC;


-- =====================================================
-- Q7. Group products into Low, Medium and Bulk
--     based on weight
-- =====================================================

SELECT DISTINCT
       name,
       weightInGms,
       CASE
           WHEN weightInGms < 1000 THEN 'Low'
           WHEN weightInGms < 5000 THEN 'Medium'
           ELSE 'Bulk'
       END AS weight_category
FROM zepto;


-- =====================================================
-- Q8. Calculate total inventory weight per category
-- =====================================================

SELECT
       category,
       SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight DESC;


-- =====================================================
-- Q9. Find the top 10 products generating the highest
--     potential revenue
-- =====================================================

SELECT
       name,
       SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY name
ORDER BY total_revenue DESC
LIMIT 10;


-- =====================================================
-- Q10. Find categories with more than 50 products
-- =====================================================

SELECT
       category,
       COUNT(*) AS number_of_products
FROM zepto
GROUP BY category
HAVING COUNT(*) > 50
ORDER BY number_of_products DESC;


-- =====================================================
-- Q11. Find products where discount is greater than 30%
--      and MRP is above ₹500
-- =====================================================

SELECT
       name,
       mrp,
       discountPercent
FROM zepto
WHERE discountPercent > 30
  AND mrp > 500
ORDER BY discountPercent DESC;


-- =====================================================
-- Q12. Find the average MRP and average selling price
--      for each category
-- =====================================================

SELECT
       category,
       ROUND(AVG(mrp), 2) AS avg_mrp,
       ROUND(AVG(discountedSellingPrice), 2) AS avg_selling_price
FROM zepto
GROUP BY category
ORDER BY avg_mrp DESC;


-- =====================================================
-- Q13. Find categories with average discount greater
--      than 20%
-- =====================================================

SELECT
       category,
       ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
HAVING AVG(discountPercent) > 20
ORDER BY avg_discount DESC;


-- =====================================================
-- Q14. JOIN: Calculate category revenue with
--      category information
-- =====================================================
-- NOTE:
-- This query requires a separate table named
-- 'category_summary' with columns:
-- category and category_type.

SELECT
       z.category,
       cs.category_type,
       SUM(z.discountedSellingPrice * z.availableQuantity) AS total_revenue
FROM zepto AS z
JOIN category_summary AS cs
    ON z.category = cs.category
GROUP BY
       z.category,
       cs.category_type
ORDER BY total_revenue DESC;


-- =====================================================
-- Q15. Window Function: Rank products by discount
-- =====================================================

SELECT
       name,
       category,
       discountPercent,
       RANK() OVER (
           ORDER BY discountPercent DESC
       ) AS discount_rank
FROM zepto;


-- =====================================================
-- Q16. Find the top 3 discounted products in each category
-- =====================================================

WITH ranked_products AS (
    SELECT
           name,
           category,
           discountPercent,
           RANK() OVER (
               PARTITION BY category
               ORDER BY discountPercent DESC
           ) AS category_rank
    FROM zepto
)

SELECT
       name,
       category,
       discountPercent,
       category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY
       category,
       category_rank;

