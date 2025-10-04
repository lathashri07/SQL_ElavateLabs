-- ---------------------------------------------------------------------
-- PostgreSQL demo: CREATE VIEW with complex SELECT + using views for abstraction & security
-- Run as a superuser or a user with CREATE/GRANT privileges.
-- ---------------------------------------------------------------------

BEGIN;

-- 1) CLEAN UP (if re-running)
DROP SCHEMA IF EXISTS demo CASCADE;
CREATE SCHEMA demo;
SET search_path = demo;

-- 2) Create sample tables
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    ssn TEXT,               -- sensitive data we want to hide in public views
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL, -- copy of price at time of order
    order_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 3) Insert sample data
INSERT INTO customers (full_name, email, phone, ssn, created_at) VALUES
('Ananya Rao','ananya@example.com','+91-9000000001','SSN-1111','2024-08-01'),
('Vikram Singh','vikram@example.com','+91-9000000002','SSN-2222','2024-09-10'),
('Priya Patel','priya@example.com','+91-9000000003','SSN-3333','2025-02-15');

INSERT INTO products (name, category, unit_price) VALUES
('Runner 500','Shoes',2499.00),
('CourtAce','Shoes',3499.00),
('TrailMaster','Shoes',4299.00),
('SportBottle','Accessories',299.00),
('GymBag','Accessories',1299.00);

INSERT INTO orders (customer_id, product_id, quantity, unit_price, order_date) VALUES
(1, 1, 1, 2499.00, '2025-06-01'),
(1, 4, 2, 299.00, '2025-06-02'),
(2, 2, 1, 3499.00, '2025-06-10'),
(2, 5, 1, 1299.00, '2025-06-12'),
(2, 3, 2, 4299.00, '2025-07-01'),
(3, 1, 1, 2499.00, '2025-07-05'),
(3, 4, 5, 299.00, '2025-07-07');

-- 4) Example complex SELECT used for an aggregated view:
--    - Join customers, orders, products
--    - Aggregate total_spent, total_orders
--    - Use window function to get rank by spending
--    - Compute favorite category via subquery
-- We'll put this inside a view next.

-- 5) Secure & abstracted view: public_customer_view
--    Hides email, phone, ssn, exposes only non-sensitive fields for external consumers.
CREATE OR REPLACE VIEW public_customer_view AS
SELECT
    customer_id,
    full_name,
    -- intentionally excluding email/ssn
    date(created_at) AS joined_on
FROM customers;

COMMENT ON VIEW public_customer_view IS 'Safe customer info for external consumption (no sensitive columns).';

-- 6) Aggregated, complex sales summary view per customer
CREATE OR REPLACE VIEW customer_sales_summary AS
SELECT
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.quantity * o.unit_price)::NUMERIC(12,2) AS total_spent,
    MAX(o.order_date) AS last_order_date,
    -- favorite_category: category with highest spend per customer (subquery)
    (SELECT p2.category
     FROM orders o2
     JOIN products p2 ON o2.product_id = p2.product_id
     WHERE o2.customer_id = c.customer_id
     GROUP BY p2.category
     ORDER BY SUM(o2.quantity * o2.unit_price) DESC
     LIMIT 1
    ) AS favorite_category,
    -- a simple segmentation label using CASE
    CASE
        WHEN SUM(o.quantity * o.unit_price) >= 5000 THEN 'Premium'
        WHEN SUM(o.quantity * o.unit_price) >= 2000 THEN 'Regular'
        ELSE 'Occasional'
    END AS customer_segment,
    -- window function to compute rank of customer by total_spent across all customers
    RANK() OVER (ORDER BY SUM(o.quantity * o.unit_price) DESC) AS spend_rank
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;

COMMENT ON VIEW customer_sales_summary IS 'Aggregated sales metrics per customer with favorite category and segmentation.';

-- 7) Create a role (analyst) and demonstrate granting access ONLY to the views
--    Note: Creating roles requires superuser privileges in many setups.
--    If you already have an "analyst" role, skip creation (commented).
-- CREATE ROLE analyst NOINHERIT;
-- SET ROLE postgres; -- ensure running as a superuser if required

-- Revoke default access on base tables for public (demonstrates security)
REVOKE ALL ON customers FROM PUBLIC;
REVOKE ALL ON orders FROM PUBLIC;
REVOKE ALL ON products FROM PUBLIC;

-- Grant SELECT on views to PUBLIC or a limited role as needed.
GRANT SELECT ON public_customer_view TO PUBLIC;
GRANT SELECT ON customer_sales_summary TO PUBLIC;

-- If you prefer to grant to only a specific role (uncomment if you create analyst role):
-- GRANT SELECT ON public_customer_view TO analyst;
-- GRANT SELECT ON customer_sales_summary TO analyst;

-- IMPORTANT: Ensure application/analyst cannot directly read sensitive table columns
-- (we revoked PUBLIC access above); only allowed to query the safe views.

-- 8) Example queries a recruiter/dev/analyst might run on the views:

-- Example A: Get top 5 customers by spend (using the view)
-- (This is fast and abstracts away joins/aggregation details.)
-- SELECT * FROM customer_sales_summary ORDER BY total_spent DESC LIMIT 5;

-- Example B: Public customer directory (safe)
-- -- SELECT * FROM public_customer_view ORDER BY joined_on DESC;

-- Example C: Find customers classified as 'Premium'
-- -- SELECT customer_id, full_name, total_spent FROM customer_sales_summary WHERE customer_segment = 'Premium';

-- 9) Test: run queries now ( uncomment to execute as part of the script ):

-- Show all public customers (safe view)
SELECT * FROM public_customer_view;

-- Show sales summary
SELECT customer_id, full_name, total_orders, total_spent, favorite_category, customer_segment, spend_rank
FROM customer_sales_summary
ORDER BY total_spent DESC;

COMMIT;
