-- ================================================
-- RETAIL SALES & INVENTORY INTELLIGENCE SYSTEM
-- ================================================

-- PRODUCTION DOMAIN
-- ================================================
-- SECTION 1: TABLE CREATION (Run only once)
-- ================================================

CREATE TABLE brands (
    brand_id   INT PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL
);

CREATE TABLE categories (
    category_id   INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);

CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    brand_id     INT REFERENCES brands(brand_id),
    category_id  INT REFERENCES categories(category_id),
    model_year   SMALLINT,
    list_price   NUMERIC(10,2)
);

-- SALES DOMAIN
CREATE TABLE stores (
    store_id   INT PRIMARY KEY,
    store_name VARCHAR(255),
    phone      VARCHAR(25),
    email      VARCHAR(255),
    street     VARCHAR(255),
    city       VARCHAR(255),
    state      VARCHAR(10),
    zip_code   VARCHAR(10)
);

CREATE TABLE staffs (
    staff_id   INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    email      VARCHAR(255),
    phone      VARCHAR(25),
    active     SMALLINT,
    store_id   INT REFERENCES stores(store_id),
    manager_id INT REFERENCES staffs(staff_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    phone       VARCHAR(25),
    email       VARCHAR(255),
    street      VARCHAR(255),
    city        VARCHAR(255),
    state       VARCHAR(10),
    zip_code    VARCHAR(10)
);

CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT REFERENCES customers(customer_id),
    order_status  SMALLINT,
    order_date    DATE,
    required_date DATE,
    shipped_date  DATE,
    store_id      INT REFERENCES stores(store_id),
    staff_id      INT REFERENCES staffs(staff_id)
);

CREATE TABLE order_items (
    order_id   INT REFERENCES orders(order_id),
    item_id    INT,
    product_id INT REFERENCES products(product_id),
    quantity   INT,
    list_price NUMERIC(10,2),
    discount   NUMERIC(4,2),
    PRIMARY KEY (order_id, item_id)
);

CREATE TABLE stocks (
    store_id   INT REFERENCES stores(store_id),
    product_id INT REFERENCES products(product_id),
    quantity   INT,
    PRIMARY KEY (store_id, product_id)
);

-- ================================================
-- SECTION 2: DATA IMPORT (Run only once)
-- ================================================

COPY brands FROM 'C:\Retail Sales Data\brands.csv' DELIMITER ',' CSV HEADER;

COPY categories FROM 'C:\Retail Sales Data\categories.csv' DELIMITER ',' CSV HEADER;

COPY customers FROM 'C:\Retail Sales Data\customers.csv' DELIMITER ',' CSV HEADER;

COPY stores FROM 'C:\Retail Sales Data\stores.csv' DELIMITER ',' CSV HEADER;

COPY staffs FROM 'C:\Retail Sales Data\staffs.csv' 
DELIMITER ',' CSV HEADER
NULL 'NULL';

ALTER TABLE products ALTER COLUMN product_name TYPE VARCHAR(500);
COPY products FROM 'C:\Retail Sales Data\products.csv' DELIMITER ',' CSV HEADER;

COPY orders FROM 'C:\Retail Sales Data\orders.csv' DELIMITER ',' CSV HEADER NULL '';

COPY order_items FROM 'C:\Retail Sales Data\order_items.csv' DELIMITER ',' CSV HEADER;

COPY stocks FROM 'C:\Retail Sales Data\stocks.csv' DELIMITER ',' CSV HEADER;

-- ================================================
-- SECTION 3: DATA VERIFICATION
-- ================================================

SELECT 'brands' AS table_name, COUNT(*) FROM brands UNION ALL
SELECT 'categories', COUNT(*) FROM categories UNION ALL
SELECT 'customers', COUNT(*) FROM customers UNION ALL
SELECT 'stores', COUNT(*) FROM stores UNION ALL
SELECT 'staffs', COUNT(*) FROM staffs UNION ALL
SELECT 'products', COUNT(*) FROM products UNION ALL
SELECT 'orders', COUNT(*) FROM orders UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items UNION ALL
SELECT 'stocks', COUNT(*) FROM stocks;

-- ================================================
-- SECTION 4: ANALYSIS QUERIES
-- ================================================

-- Query 1: Total Revenue by Store

SELECT
st.store_name,
ROUND(SUM(oi.quantity*oi.list_price*(1-oi.discount)),2) AS total_revenue
FROM order_items oi
INNER JOIN orders o
ON oi.order_id = o.order_id
INNER JOIN stores st
ON o.store_id = st.store_id
GROUP BY st.store_name
ORDER BY total_revenue DESC;

-- Query 2: Top Selling Brands by Revenue

SELECT
b.brand_name,
ROUND(SUM(oi.quantity*oi.list_price*(1-oi.discount)),2) AS total_revenue,
SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
JOIN brands b
ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY total_revenue;

-- Query 3: Staff Performance by Total Sales

SELECT
s.first_name || ' ' || s.last_name AS staff_name,
st.store_name,
COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(SUM(oi.quantity*oi.list_price*(1-oi.discount)),2) AS total_revenue
FROM staffs s
JOIN orders o
ON s.staff_id = o.staff_id
JOIN stores st
ON s.store_id = st.store_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY s.staff_id, s.first_name, s.last_name, st.store_name
ORDER BY total_revenue DESC;

-- Query 4: Revenue by Product Category

SELECT
c.category_name,
COUNT(DISTINCT p.product_id) AS total_products,
SUM(oi.quantity) AS total_units_sold,
ROUND(SUM(oi.quantity*oi.list_price*(1-oi.discount)),2) AS total_revenue
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
JOIN categories c 
ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

-- Query 5: Stock Levels by Store

SELECT 
    st.store_name,
    p.product_name,
    c.category_name,
    s.quantity AS stock_quantity
FROM stocks s
JOIN stores st ON s.store_id = st.store_id
JOIN products p ON s.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
ORDER BY st.store_name, s.quantity ASC;

-- Query 6: Low Stock Alert (Out of Stock Products)

SELECT 
    st.store_name,
    c.category_name,
    COUNT(p.product_id) AS out_of_stock_count
FROM stocks s
JOIN stores st ON s.store_id = st.store_id
JOIN products p ON s.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE s.quantity = 0
GROUP BY st.store_name, c.category_name
ORDER BY st.store_name, out_of_stock_count DESC;

-- Query 7: Order Trends by Year and Month

SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY year, month
ORDER BY year, month;

-- Query 8: Delayed Shipments

SELECT 
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_date,
    o.required_date,
    o.shipped_date,
    CASE 
        WHEN o.shipped_date IS NULL THEN 'Not Shipped'
        WHEN o.shipped_date > o.required_date THEN 'Delayed'
        ELSE 'On Time'
    END AS delivery_status,
    st.store_name,
    s.first_name || ' ' || s.last_name AS staff_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN stores st ON o.store_id = st.store_id
JOIN staffs s ON o.staff_id = s.staff_id
WHERE o.shipped_date > o.required_date 
   OR o.shipped_date IS NULL
ORDER BY delivery_status, o.order_date;

-- Query 9: Customer Order and Fulfillment Status

SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    c.state,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_status = 4 THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN o.order_status = 3 THEN 1 ELSE 0 END) AS rejected_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.city, c.state
ORDER BY total_spent DESC
LIMIT 20;

-- Query 10: Customer Concentration by State

SELECT 
    c.state,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.state
ORDER BY total_revenue DESC;

-- VIEW 1: Store Revenue Summary

CREATE VIEW vw_store_revenue AS
SELECT 
st.store_name,
COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_revenue
FROM orders o
JOIN stores st ON o.store_id = st.store_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY st.store_name;

-- VIEW 2: Staff Performance Summary

CREATE VIEW vw_staff_performance AS
SELECT 
s.first_name || ' ' || s.last_name AS staff_name,
st.store_name,
COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_revenue
FROM staffs s
JOIN orders o ON s.staff_id = o.staff_id
JOIN stores st ON s.store_id = st.store_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY s.staff_id, s.first_name, s.last_name, st.store_name;

-- VIEW 3: Product Sales Summary

CREATE VIEW vw_product_sales AS
SELECT 
p.product_name,
b.brand_name,
c.category_name,
SUM(oi.quantity) AS total_units_sold,
ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.product_id, p.product_name, b.brand_name, c.category_name;

-- VIEW 4: Order Details Full View

CREATE VIEW vw_order_details AS
SELECT 
o.order_id,
c.first_name || ' ' || c.last_name AS customer_name,
c.city,
c.state,
o.order_date,
o.required_date,
o.shipped_date,
CASE 
   WHEN o.order_status = 1 THEN 'Pending'
   WHEN o.order_status = 2 THEN 'Processing'
   WHEN o.order_status = 3 THEN 'Rejected'
   WHEN o.order_status = 4 THEN 'Completed'
   END AS order_status,
CASE 
    WHEN o.shipped_date IS NULL THEN 'Not Shipped'
    WHEN o.shipped_date > o.required_date THEN 'Delayed'
    ELSE 'On Time'
    END AS delivery_status,
    st.store_name,
    s.first_name || ' ' || s.last_name AS staff_name,
ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS order_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN stores st ON o.store_id = st.store_id
JOIN staffs s ON o.staff_id = s.staff_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.first_name, c.last_name, c.city, c.state,
         o.order_date, o.required_date, o.shipped_date, o.order_status,
         st.store_name, s.first_name, s.last_name;




-- ================================================
-- SECTION 5: VIEW UPDATES
-- ================================================

-- Updated vw_order_details to include customer_id
DROP VIEW vw_order_details;

CREATE VIEW vw_order_details AS
SELECT 
    o.order_id,
    o.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    c.state,
    o.order_date,
    o.required_date,
    o.shipped_date,
    CASE 
        WHEN o.order_status = 1 THEN 'Pending'
        WHEN o.order_status = 2 THEN 'Processing'
        WHEN o.order_status = 3 THEN 'Rejected'
        WHEN o.order_status = 4 THEN 'Completed'
    END AS order_status,
    CASE 
        WHEN o.shipped_date IS NULL THEN 'Not Shipped'
        WHEN o.shipped_date > o.required_date THEN 'Delayed'
        ELSE 'On Time'
    END AS delivery_status,
    st.store_name,
    s.first_name || ' ' || s.last_name AS staff_name,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))::numeric, 2) AS order_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN stores st ON o.store_id = st.store_id
JOIN staffs s ON o.staff_id = s.staff_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.customer_id, c.first_name, c.last_name, c.city, c.state,
         o.order_date, o.required_date, o.shipped_date, o.order_status,
         st.store_name, s.first_name, s.last_name;