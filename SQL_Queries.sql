-- E-commerce Sales Data Analysis SQL Queries
-- Author: Sanveed Adnan Qureshi
-- Date: 2024-12-23
-- Description: Comprehensive SQL queries for analyzing e-commerce sales data, including regular and advanced queries.

-- Regular SQL Queries --

-- Query 1: List All Customers
SELECT * FROM Customers LIMIT 10;

-- Query 2: List All Orders
SELECT * FROM Orders LIMIT 10;

-- Query 3: Total Number of Orders
SELECT COUNT(*) AS Total_Orders FROM Orders;

-- Query 4: Total Revenue from Order Items
SELECT SUM(price) AS Total_Revenue FROM Order_Items;

-- Query 5: Number of Products in Each Category
SELECT 
    product_category_name, 
    COUNT(*) AS Product_Count 
FROM Products
GROUP BY product_category_name
ORDER BY Product_Count DESC;

-- Query 6: Number of Sellers by State
SELECT 
    seller_state, 
    COUNT(*) AS Seller_Count 
FROM Sellers
GROUP BY seller_state
ORDER BY Seller_Count DESC;

-- Query 7: Average Freight Value
SELECT AVG(freight_value) AS Avg_Freight_Value FROM Order_Items;

-- Advanced SQL Queries --

-- Query 1: Top 5 Products by Revenue
WITH RankedProducts AS (
    SELECT 
        p.product_category_name,
        SUM(oi.price) AS Total_Revenue,
        RANK() OVER (ORDER BY SUM(oi.price) DESC) AS Rank
    FROM Order_Items oi
    JOIN Products p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
)
SELECT 
    product_category_name,
    Total_Revenue,
    Rank
FROM RankedProducts
WHERE Rank <= 5;

-- Query 2: Monthly Revenue Trends
SELECT 
    strftime('%Y-%m', o.order_purchase_timestamp) AS Month,
    SUM(oi.price) AS Revenue
FROM Orders o
JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY Month
ORDER BY Month;

-- Query 3: Top Customers by Spending
SELECT 
    c.customer_unique_id,
    SUM(oi.price) AS Total_Spending,
    COUNT(o.order_id) AS Total_Orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY Total_Spending DESC
LIMIT 10;

-- Query 4: Popular Payment Methods
SELECT 
    p.payment_type,
    COUNT(*) AS Transaction_Count,
    SUM(p.payment_value) AS Total_Paid
FROM Payments p
GROUP BY p.payment_type
ORDER BY Total_Paid DESC;

-- Query 5: Average Delivery Time
SELECT 
    AVG(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)) AS Avg_Delivery_Time
FROM Orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Query 6: Customer Lifetime Value (CLTV) Analysis
SELECT 
    c.customer_unique_id,
    COUNT(o.order_id) AS Total_Orders,
    SUM(oi.price) AS Total_Spending,
    AVG(oi.price) AS Avg_Order_Value
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY Total_Spending DESC
LIMIT 10;

-- Query 7: Revenue by Seller
SELECT 
    s.seller_id,
    s.seller_city,
    COUNT(oi.order_id) AS Total_Orders,
    SUM(oi.price) AS Total_Revenue,
    AVG(oi.freight_value) AS Avg_Freight_Charges
FROM Sellers s
JOIN Order_Items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_city
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Query 8: Identify Delayed Orders
SELECT 
    o.order_id,
    o.order_purchase_timestamp,
    o.order_estimated_delivery_date,
    o.order_delivered_customer_date,
    julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date) AS Delay_Days
FROM Orders o
WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
ORDER BY Delay_Days DESC
LIMIT 10;

-- Query 9: Revenue and Profit Analysis by Category
SELECT 
    p.product_category_name,
    SUM(oi.price) AS Total_Revenue,
    SUM(oi.price - oi.freight_value) AS Estimated_Profit
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY Total_Revenue DESC;
