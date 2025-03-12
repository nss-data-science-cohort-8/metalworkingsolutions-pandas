
/* # Metalworking Solutions

Metalworking Solutions is a sheet metal fabricator based in Chattanooga, Tennessee. Established in 2006, the company offers laser cutting, punching, bending, welding, finishing, and delivery services and ships over 2 million parts annually. 

You've been provided a dataset of jobs since the beginning of 2023.

A few tips for navigating the database: Each job can have multiple job operations in the job_operations_2023/job_operations_2024 table. You can connect the jobs to the job_operations. The jmp_job_id references jmo_job_id in the job_operations_2023/job_operations_2024 tables.  Jobs can be connected to sales orders through the sales_order_job_links table.  

For your project, your group will be responsible for one of the following sets of questions. Construct an R Shiny app to show your findings.

**1. Do an analysis of customers. The customer can be identified using the jmp_customer_organization_id from the jobs table or the omp_customer_organization_id from the sales_orders table. Here are some example questions to get started:  
    a. Which customers have the highest volume of jobs? Which generate the most revenue (as indicated by the omp_order_subtotal_base in the sales_order table)?  
    b. How has the volume of work changed for each customer over time? Are there any seasonal patterns? How have the number of estimated hours per customer changed over time? Estimated hours are in the jmo_estimated_production_hours columns of the job_operations_2023/job_operations_2024 tables.  
    c. How has the customer base changed over time? What percentage of jobs are for new customers compared to repeat customers?  
    d. Perform a breakdown of customers by operation (as indicated by the jmo_process short_description in the job_operations_2023 or job_operations_2024 table).** */


-- 1.a 
--------------------------------------------------------------------------------
-- Revenue and job counts generated per customer 
-- Y002-YNGTC	888	$42,982,729.77  --- highest revenue
-- M030-MORGO	3633	$17,515,449.94 --- most jobs
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
ORDER BY total_revenue_per_customer DESC;


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



SELECT
    jmo_job_id,
    jmo_created_date,
    SUM(jmo_estimated_production_hours) AS jmo_estimated_production_hours
 FROM job_operations_2023
GROUP BY jmo_job_id, jmo_created_date
ORDER BY jmo_estimated_production_hours DESC;