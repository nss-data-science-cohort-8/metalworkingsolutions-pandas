
/* # Metalworking Solutions

Metalworking Solutions is a sheet metal fabricator based in Chattanooga, Tennessee. Established in 2006, the company offers laser cutting, punching, bending, welding, finishing, and delivery services and ships over 2 million parts annually. 

You've been provided a dataset of jobs since the beginning of 2023.

A few tips for navigating the database: Each job can have multiple job operations in the job_operations_2023/job_operations_2024 table. You can connect the jobs to the job_operations. The jmp_job_id references jmo_job_id in the job_operations_2023/job_operations_2024 tables.  Jobs can be connected to sales orders through the sales_order_job_links table.  

For your project, your group will be responsible for one of the following sets of questions. Construct an R Shiny app to show your findings.

**1. Do an analysis of customers. The customer can be identified using the jmp_customer_organization_id from the jobs table or the omp_customer_organization_id from the sales_orders table. Here are some example questions to get started:  
    a. Which customers have the highest volume of jobs? Which generate the most revenue (as indicated by the omp_order_subtotal_base (Ian recommended we use the total in the shipments table for revenue calculations) in the sales_order table)?  
    b. How has the volume of work changed for each customer over time? Are there any seasonal patterns? How have the number of estimated hours per customer changed over time? Estimated hours are in the jmo_estimated_production_hours columns of the job_operations_2023/job_operations_2024 tables.  
    c. How has the customer base changed over time? What percentage of jobs are for new customers compared to repeat customers?  
    d. Perform a breakdown of customers by operation (as indicated by the jmo_process short_description in the job_operations_2023 or job_operations_2024 table).** */


-- 1.a 
--------------------------------------------------------------------------------
-- REVENUE --
-- 2023
-- 	2023	M030-MORGO	$7,720,776.64
SELECT EXTRACT(YEAR FROM smp_ship_date) AS year, smp_customer_organization_id, SUM(smp_shipment_total)::NUMERIC::MONEY AS total_revenue
FROM shipments 
GROUP BY smp_customer_organization_id, EXTRACT(YEAR FROM smp_ship_date)
HAVING EXTRACT(YEAR FROM smp_ship_date) = 2023
ORDER BY total_revenue DESC;

-- 2024
-- 2024	Y002-YNGTC	$4,390,725.46
SELECT EXTRACT(YEAR FROM smp_ship_date) AS year, smp_customer_organization_id, SUM(smp_shipment_total)::NUMERIC::MONEY AS total_revenue
FROM shipments 
GROUP BY smp_customer_organization_id, EXTRACT(YEAR FROM smp_ship_date)
HAVING EXTRACT(YEAR FROM smp_ship_date) = 2024
ORDER BY total_revenue DESC;

-- CUSTOMER BOTH YEARS -- 
-- M030-MORGO	$8,844,478.79
SELECT smp_customer_organization_id, SUM(smp_shipment_total)::NUMERIC::MONEY AS total_revenue
FROM shipments 
GROUP BY smp_customer_organization_id
ORDER BY total_revenue DESC;

-- TOTAL COMPANY REVENUE 2023 --
-- $23,092,060.67
WITH revenue_2023 AS (
    SELECT 
        EXTRACT(YEAR FROM smp_ship_date) AS year,
        smp_customer_organization_id, 
        SUM(smp_shipment_total)::NUMERIC::MONEY AS total_revenue
    FROM shipments 
    GROUP BY smp_customer_organization_id, EXTRACT(YEAR FROM smp_ship_date)
    HAVING EXTRACT(YEAR FROM smp_ship_date) = 2023
    ORDER BY total_revenue DESC
)
SELECT SUM(total_revenue) AS total_revenue
FROM revenue_2023;

-- TOTAL COMPANY REVENUE 2024 --
-- $15,190,447.63
WITH revenue_2024 AS (
    SELECT 
        EXTRACT(YEAR FROM smp_ship_date) AS year,
        smp_customer_organization_id, 
        SUM(smp_shipment_total)::NUMERIC::MONEY AS total_revenue
    FROM shipments 
    GROUP BY smp_customer_organization_id, EXTRACT(YEAR FROM smp_ship_date)
    HAVING EXTRACT(YEAR FROM smp_ship_date) = 2024
    ORDER BY total_revenue DESC
)
SELECT SUM(total_revenue) AS total_revenue
FROM revenue_2024;


-- USING sales_orders TABLE --
-- 2023 COMPANY REVENUE --
-- $22,567,497.02
WITH revenue AS (
    SELECT 
        DISTINCT omp_sales_order_id,
        EXTRACT(YEAR FROM omp_order_date) AS year,
        SUM(omp_order_total_base::NUMERIC::MONEY) AS total_order_value
    FROM sales_orders
    GROUP BY omp_sales_order_id, omp_order_date
    HAVING EXTRACT(YEAR FROM omp_order_date) = 2023
    ORDER BY total_order_value DESC
)
SELECT SUM(total_order_value) AS total_revenue
FROM revenue; 

-- 2024 COMPANY REVENUE --
-- $16,225,617.39
WITH revenue AS (
    SELECT 
        DISTINCT omp_sales_order_id,
        EXTRACT(YEAR FROM omp_order_date) AS year,
        SUM(omp_order_total_base::NUMERIC::MONEY) AS total_order_value
    FROM sales_orders
    GROUP BY omp_sales_order_id, omp_order_date
    HAVING EXTRACT(YEAR FROM omp_order_date) = 2024
    ORDER BY total_order_value DESC
)
SELECT SUM(total_order_value) AS total_revenue
FROM revenue; 


-- 2023 CUSTOMER REVENUE -- 
-- M030-MORGO	$7,264,747.93
SELECT 
    EXTRACT(YEAR FROM omp_order_date) AS year, 
    omp_customer_organization_id, 
    SUM(omp_order_subtotal_base)::NUMERIC::MONEY AS total_revenue
FROM sales_orders
GROUP BY omp_customer_organization_id, EXTRACT(YEAR FROM omp_order_date)
HAVING EXTRACT(YEAR FROM omp_order_date) = 2023
ORDER BY total_revenue DESC;


-- 2024 CUSTOMER REVENUE -- 
-- Y002-YNGTC	$4,831,083.83
SELECT 
    EXTRACT(YEAR FROM omp_order_date) AS year, 
    omp_customer_organization_id, 
    SUM(omp_order_subtotal_base)::NUMERIC::MONEY AS total_revenue
FROM sales_orders
GROUP BY omp_customer_organization_id, EXTRACT(YEAR FROM omp_order_date)
HAVING EXTRACT(YEAR FROM omp_order_date) = 2024
ORDER BY total_revenue DESC;


-- CUSTOMER BOTH YEARS -- 
-- M030-MORGO	$8,458,041.04
SELECT 
    omp_customer_organization_id, 
    SUM(omp_order_subtotal_base)::NUMERIC::MONEY AS total_revenue
FROM sales_orders
GROUP BY omp_customer_organization_id
ORDER BY total_revenue DESC;



-- 1.b 
--------------------------------------------------------------------------------





-- 1.c
--------------------------------------------------------------------------------






-- 1.d
--------------------------------------------------------------------------------







--------------------------------------------------------------------------------






-- scratch work --
--------------------------------------------------------------------------------
-- quick look at the jobs table
SELECT * 
FROM jobs
LIMIT 5;

-- 122 distinct customers in the jobs table
SELECT 
    COUNT(DISTINCT jmp_customer_organization_id) AS n_distinct_customers,
    COUNT(jmp_customer_organization_id) AS n_total_customer_orders,
    COUNT(DISTINCT jmp_job_id) AS n_distinct_jobs
FROM jobs;


-- as this is, it does not take into account repeats. They should be clearing somewhere around 20_25 mil in revenue
WITH revenue AS (
    SELECT 
        DISTINCT jmp_customer_organization_id AS customer_id,
        COUNT(*) OVER(PARTITION BY jmp_customer_organization_id) AS n_jobs_per_customer,
        SUM(omp_order_subtotal_base::NUMERIC::MONEY) OVER(PARTITION BY jmp_customer_organization_id) AS total_revenue_per_customer
    FROM jobs j
        INNER JOIN sales_order_job_links s
        ON j.jmp_job_id = s.omj_job_id
        INNER JOIN sales_orders so
        ON s.omj_sales_order_id = so.omp_sales_order_id
    WHERE jmp_customer_organization_id IS NOT NULL
    ORDER BY total_revenue_per_customer DESC
)
SELECT 
    SUM(total_revenue_per_customer) AS total_revenue
FROM revenue;




WITH revenue AS (
    SELECT 
        DISTINCT jmp_customer_organization_id AS customer_id,
        COUNT(*) OVER(PARTITION BY jmp_customer_organization_id) AS n_jobs_per_customer,
        SUM(omp_order_subtotal_base::NUMERIC::MONEY) OVER(PARTITION BY jmp_customer_organization_id) AS total_revenue_per_customer
    FROM jobs j
        INNER JOIN sales_order_job_links s
        ON j.jmp_job_id = s.omj_job_id
        INNER JOIN sales_orders so
        ON s.omj_sales_order_id = so.omp_sales_order_id
    WHERE jmp_customer_organization_id IS NOT NULL
    ORDER BY total_revenue_per_customer DESC
)
SELECT 
    SUM(total_revenue_per_customer) AS total_revenue
FROM revenue;

SELECT *
FROM sales_orders
LIMIT 5;

-- this is closer : not divided by year
WITH revenue AS (
    SELECT 
        DISTINCT omp_sales_order_id,
        EXTRACT(YEAR FROM omp_order_date) AS year,
        SUM(omp_order_total_base::NUMERIC::MONEY) AS total_order_value
    FROM sales_orders
    GROUP BY omp_sales_order_id, omp_order_date
    HAVING EXTRACT(YEAR FROM omp_order_date) = 2023
    ORDER BY total_order_value DESC
)
SELECT SUM(total_order_value) AS total_revenue
FROM revenue; 

SELECT *
FROM shipments;

-- 2023
-- 	2023	M030-MORGO	$7,720,776.64
SELECT EXTRACT(YEAR FROM smp_ship_date) AS year, smp_customer_organization_id, SUM(smp_shipment_total)::NUMERIC::MONEY AS total_revenue
FROM shipments 
GROUP BY smp_customer_organization_id, EXTRACT(YEAR FROM smp_ship_date)
HAVING EXTRACT(YEAR FROM smp_ship_date) = 2023
ORDER BY total_revenue DESC;

-- 2024
-- 2024	Y002-YNGTC	$4,390,725.46
SELECT EXTRACT(YEAR FROM smp_ship_date) AS year, smp_customer_organization_id, SUM(smp_shipment_total)::NUMERIC::MONEY AS total_revenue
FROM shipments 
GROUP BY smp_customer_organization_id, EXTRACT(YEAR FROM smp_ship_date)
HAVING EXTRACT(YEAR FROM smp_ship_date) = 2024
ORDER BY total_revenue DESC;

-- there are 7 null customer ids in the jmp_customer_organization_id column
SELECT 
    jmp_job_id AS job_id,
    jmp_customer_organization_id AS customer_id
FROM jobs
ORDER BY jmp_customer_organization_id DESC NULLS FIRST; 


-- null rows not that interesting
SELECT *
FROM jobs
WHERE jmp_customer_organization_id IS NULL;


-- jobs table with no null customer ids
SELECT * 
FROM jobs 
WHERE jmp_customer_organization_id IS NOT NULL
ORDER BY jmp_job_date DESC;

-- all sales order job links 
SELECT * 
FROM sales_order_job_links;

SELECT *
FROM sales_orders
LIMIT 5;

-- no null job ids in sales_order_job_links
SELECT *
FROM sales_order_job_links
WHERE omj_job_id IS NULL;




-- b. How has the volume of work changed for each customer over time? Are there any seasonal patterns? How have the number of estimated hours per customer changed over time? Estimated hours are in the jmo_estimated_production_hours columns of the job_operations_2023/job_operations_2024 tables. actual hours are in the jmo_actual_production_hours columns of the job_operations_2023/job_operations_2024 tables. 
-- what about jmp_completed_production_hours? 

SELECT *
FROM job_operations_2023
LIMIT 5;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'job_operations_2023'
    AND column_name LIKE '%hours';

SELECT
    jmo_job_id,
    jmo_created_date,
    SUM(jmo_setup_hours),
    SUM(jmo_actual_setup_hours),
    SUM(jmo_actual_production_hours),
    SUM(jmo_estimated_production_hours),
    SUM(jmo_completed_setup_hours),
    SUM(jmo_completed_production_hours)
FROM job_operations_2023
GROUP BY jmo_job_id, jmo_created_date;


-- jobs_volume_hours
SELECT
    date_trunc('week', jmo_created_date) AS week,
    SUM(jmo_estimated_production_hours) AS jmo_estimated_production_hours
 FROM job_operations_2023
GROUP BY date_trunc('week', jmo_created_date)
ORDER BY week;



-- job_ops_23_slimmed
SELECT
    jmo_job_id,
    date_trunc('week', jmo_created_date) AS week,
    SUM(jmo_estimated_production_hours) AS total_estimated_hours
FROM job_operations_2023
GROUP BY jmo_job_id, date_trunc('week', jmo_created_date)
ORDER BY week;






-- c. How has the customer base changed over time? What percentage of jobs are for new customers compared to repeat customers?  
SELECT *
FROM shipments
LIMIT 20;

SELECT * 
FROM shipment_lines
LIMIT 20;

SELECT * 
FROM sales_orders
LIMIT 20;

SELECT *
FROM sales_order_job_links
LIMIT 20;

SELECT *
FROM jobs
LIMIT 20;


-- new customers 
SELECT 
    COUNT(DISTINCT jmp_customer_organization_id) AS n_distinct_customers,
    COUNT(DISTINCT jmp_customer_organization_id)::NUMERIC / COUNT( jmp_customer_organization_id)::NUMERIC AS pct_new,
    COUNT(jmp_customer_organization_id) AS n_jobs
FROM jobs 


-- returning customers 
SELECT
    COUNT(DISTINCT jmp_customer_organization_id) AS n_returning_customers
FROM jobs
-- HAVING COUNT(jmp_customer_organization_id) > 1;
WHERE jmp_customer_organization_id IN (
    SELECT DISTINCT jmp_customer_organization_id
    FROM jobs
    GROUP BY jmp_customer_organization_id
    HAVING COUNT(jmp_customer_organization_id) > 1
);





-- d. Perform a breakdown of customers by operation (as indicated by the jmo_process short_description in the job_operations_2023 or job_operations_2024 table).** */