--find no of disticnt customer id in both and total of job order and total of cell order
SELECT 
    COUNT(DISTINCT o.omp_customer_organization_id) AS NoOfCompany_insales, 
    COUNT(DISTINCT o.omp_sales_order_id) AS Order_no, 
    COUNT(DISTINCT j.jmp_customer_organization_id) AS NoOfCompany_injobs, 
    COUNT(DISTINCT j.jmp_job_id) AS job_no
	--COUNT(DISTINCT s.smp_customer_organization_id) AS NoOfCompany_inshipment
FROM sales_orders AS o   
LEFT JOIN jobs AS j 
    ON j.jmp_customer_organization_id = o.omp_customer_organization_id;
--LEFT JOIN shipments AS s
	--ON j.jmp_customer_organization_id = s.smp_customer_organization_id;
--compare customer id in each table
SELECT 
    COUNT(DISTINCT o.omp_customer_organization_id) AS NoOfCompany_insales, 
    COUNT(DISTINCT o.omp_sales_order_id) AS Order_no, 
    COUNT(DISTINCT j.jmp_customer_organization_id) AS NoOfCompany_injobs, 
    COUNT(DISTINCT j.jmp_job_id) AS job_no,
	COUNT(DISTINCT s.smp_customer_organization_id) AS NoOfCompany_inshipment
FROM sales_orders AS o   
LEFT JOIN jobs AS j 
    ON j.jmp_customer_organization_id = o.omp_customer_organization_id
LEFT JOIN shipments AS s
	ON j.jmp_customer_organization_id = s.smp_customer_organization_id;
-- omp_customer is not in both tables= H034-HTMX
SELECT DISTINCT s.omp_customer_organization_id
FROM sales_orders s
LEFT JOIN shipments j
    ON s.omp_customer_organization_id = j.smp_customer_organization_id
WHERE j.smp_customer_organization_id IS NULL;


SELECT *
FROM sales_orders
LIMIT 2;

SELECT *
FROM jobs
LIMIT 2; 

SELECT *
FROM shipments
LIMIT 2; 

SELECT 	EXTRACT(YEAR FROM o.omp_order_date) AS year)
		SUM(omp_order_total_base) AS num_order
		SUM(smp_shipment_total) AS sum_shipment,
		SUM(omp_order_total_base) - SUM(smp_shipment_total) AS difference
	
FROM sales_orders AS o
INNER JOIN shipments AS s ON o.omp_customer_organization_id = s.smp_customer_organization_id
GROUP BY o.omp_customer_organization_id
ORDER BY 4

---compare smp_shipment_total in shipment and omp_order_total_base in sales_orders
SELECT DISTINCT o.omp_customer_organization_id AS company_id, 
		SUM(omp_order_total_base) AS sum_sales_orders,
		SUM(smp_shipment_total) AS sum_shipment,
		SUM(omp_order_total_base) - SUM(smp_shipment_total) AS difference
		
FROM sales_orders AS o
INNER JOIN shipments AS s ON o.omp_customer_organization_id = s.smp_customer_organization_id
GROUP BY o.omp_customer_organization_id
ORDER BY 4

--customername with the highest volume order
SELECT omp_customer_organization_id, SUM(omp_order_total_base) AS order_volume
FROM sales_orders
GROUP BY omp_customer_organization_id
ORDER BY order_volume DESC
LIMIT 5;
--customer name with the most revenue
SELECT omp_customer_organization_id, SUM(omp_order_subtotal_base) AS total_revenue
FROM sales_orders
GROUP BY omp_customer_organization_id
ORDER BY total_revenue DESC
LIMIT 5;
--no of new customer and existing customer over time
WITH first_transaction AS (
    SELECT 
        omp_customer_organization_id,
        MIN(omp_order_date) AS first_purchase_date
    FROM sales_orders
    GROUP BY omp_customer_organization_id
)

SELECT 
    EXTRACT(YEAR FROM o.omp_order_date) AS year,
    EXTRACT(MONTH FROM o.omp_order_date) AS month,
    COUNT(DISTINCT CASE 
        WHEN f.first_purchase_date = o.omp_order_date THEN o.omp_customer_organization_id
    END) AS new_customers,
    COUNT(DISTINCT CASE 
        WHEN f.first_purchase_date < o.omp_order_date THEN o.omp_customer_organization_id
    END) AS existing_customers
	
FROM sales_orders AS o
JOIN first_transaction AS f 
    ON o.omp_customer_organization_id = f.omp_customer_organization_id
GROUP BY year, month
ORDER BY year, month;

--customer base data_no of new vs existing customers over time
WITH first_transaction AS (
    SELECT 
        omp_customer_organization_id,
        MIN(omp_order_date) AS first_purchase_date
    FROM sales_orders
    GROUP BY omp_customer_organization_id
)

SELECT 
    EXTRACT(YEAR FROM o.omp_order_date) AS year,
    EXTRACT(MONTH FROM o.omp_order_date) AS month,
    COUNT(DISTINCT CASE 
        WHEN DATE_TRUNC('month', f.first_purchase_date) = DATE_TRUNC('month', o.omp_order_date) 
        THEN o.omp_customer_organization_id
    END) AS new_customers,
    COUNT(DISTINCT CASE 
        WHEN DATE_TRUNC('month', f.first_purchase_date) < DATE_TRUNC('month', o.omp_order_date) 
        THEN o.omp_customer_organization_id
    END) AS existing_customers,
	COUNT(DISTINCT o.omp_customer_organization_id) AS total_no
FROM sales_orders AS o
JOIN first_transaction AS f 
    ON o.omp_customer_organization_id = f.omp_customer_organization_id
GROUP BY year, month
ORDER BY year, month;
--customer base data_% of job from existing vs new customers over time
WITH first_transaction AS (
    SELECT 
        omp_customer_organization_id,
        MIN(omp_order_date) AS first_purchase_date
    FROM sales_orders
    GROUP BY omp_customer_organization_id
)

SELECT 
    EXTRACT(YEAR FROM o.omp_order_date) AS year,
    EXTRACT(MONTH FROM o.omp_order_date) AS month,

    -- Count distinct new customers per month
    COUNT(DISTINCT CASE 
        WHEN DATE_TRUNC('month', f.first_purchase_date) = DATE_TRUNC('month', o.omp_order_date) 
        THEN o.omp_customer_organization_id
    END) AS new_customers,

    -- Count distinct existing customers per month
    COUNT(DISTINCT CASE 
        WHEN DATE_TRUNC('month', f.first_purchase_date) < DATE_TRUNC('month', o.omp_order_date) 
        THEN o.omp_customer_organization_id
    END) AS existing_customers,

    -- Total distinct customers per month
    COUNT(DISTINCT o.omp_customer_organization_id) AS total_customers,

    -- Count total revenue from new customers
    SUM(CASE 
        WHEN DATE_TRUNC('month', f.first_purchase_date) = DATE_TRUNC('month', o.omp_order_date) 
        THEN o.omp_order_total_base
    END) AS total_order_new,

    -- Count total revenue from existing customers
    SUM(CASE 
        WHEN DATE_TRUNC('month', f.first_purchase_date) < DATE_TRUNC('month', o.omp_order_date) 
        THEN o.omp_order_total_base
    END) AS Total_orders_existing,

    -- Total revenue of orders per month
    SUM(o.omp_order_total_base) AS total_orders

FROM sales_orders AS o
INNER JOIN first_transaction AS f 
    ON o.omp_customer_organization_id = f.omp_customer_organization_id

GROUP BY year, month
ORDER BY year, month;

