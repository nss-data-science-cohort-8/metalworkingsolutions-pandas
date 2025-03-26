--a. Which customers have the highest volume of jobs? Which generate the most revenue (as indicated by the omp_order_subtotal_base in the sales_order table)?
SELECT * 
FROM jobs


SELECT * 
FROM job_operations_2024


SELECT 
    omp_customer_organization_id AS customer_id,
    COUNT(omp_sales_order_id) AS order_count,
    ROUND(SUM(omp_full_order_subtotal_base)::numeric, 2) AS subtotal
FROM sales_orders
GROUP BY omp_customer_organization_id
ORDER BY subtotal DESC;

--b. How has the volume of work changed for each customer over time? 
--Are there any seasonal patterns? How have the number of estimated hours per customer changed over time? 
--Estimated hours are in the jmo_estimated_production_hours columns of the job_operations_2023/job_operations_2024 tables.


SELECT 
	omp_customer_organization_id AS customer_id,
    COUNT(omp_sales_order_id) AS order_count,
	omp_order_date
FROM sales_orders
LIMIT 25;


SELECT 
    omp_customer_organization_id AS customer_id,
    COUNT(omp_sales_order_id) FILTER (WHERE EXTRACT(YEAR FROM omp_order_date) = 2021) AS "2021",
    COUNT(omp_sales_order_id) FILTER (WHERE EXTRACT(YEAR FROM omp_order_date) = 2022) AS "2022",
    COUNT(omp_sales_order_id) FILTER (WHERE EXTRACT(YEAR FROM omp_order_date) = 2023) AS "2023",
    COUNT(omp_sales_order_id) FILTER (WHERE EXTRACT(YEAR FROM omp_order_date) = 2024) AS "2024"
FROM sales_orders
GROUP BY omp_customer_organization_id
ORDER BY "2024" DESC;

--c. How has the customer base changed over time? 
--What percentage of jobs are for new customers compared to repeat customers?

WITH combined_jobs AS (
    SELECT * 
    FROM job_operations_2023
    UNION ALL
    SELECT * 
    FROM job_operations_2024
)
SELECT jmo_job_id, 
       SUM(jmo_completed_production_hours) AS completed_hours, 
       SUM(jmo_estimated_production_hours) AS estimated_hours
FROM combined_jobs
GROUP BY jmo_job_id
LIMIT 5;

WITH combined_jobs AS (
    SELECT 
        jmo_job_id,
        CAST(jmo_completed_production_hours AS double precision) AS jmo_completed_production_hours,
        CAST(jmo_estimated_production_hours AS double precision) AS jmo_estimated_production_hours
    FROM job_operations_2023
    UNION ALL
    SELECT 
        jmo_job_id,
        CAST(jmo_completed_production_hours AS double precision) AS jmo_completed_production_hours,
        CAST(jmo_estimated_production_hours AS double precision) AS jmo_estimated_production_hours
    FROM job_operations_2024
)
SELECT 
	   jmo_job_id,
	   jobs.jmp_customer_organization_id AS customer_id,
       SUM(jmo_completed_production_hours) AS completed_hours, 
       SUM(jmo_estimated_production_hours) AS estimated_hours
FROM combined_jobs
LEFT JOIN jobs ON combined_jobs.jmo_job_id = jobs.jmp_job_id
GROUP BY jmo_job_id, jobs.jmp_customer_organization_id
LIMIT 5;



--d. Perform a breakdown of customers by operation (as indicated by the jmo_process short_description in the job_operations_2023 or job_operations_2024 table).