SELECT COUNT (DISTINCT omp_customer_organization_id) AS NoOfCompany
FROM sales_orders;

SELECT COUNT(DISTINCT jmp_customer_organization_id) AS NoOfCompany
FROM jobs;

SELECT *
FROM sales_orders
LIMIT 2;

SELECT *
FROM jobs
LIMIT 2;
--customername with the highest volume order
SELECT jmp_customer_organization_id, SUM(jmp_quantity_shipped) AS job_volume
FROM jobs
GROUP BY jmp_customer_organization_id
ORDER BY job_volume DESC
LIMIT 5;
--customer name with the most revenue
SELECT omp_customer_organization_id, SUM(omp_order_subtotal_base) AS total_revenue
FROM sales_orders
GROUP BY omp_customer_organization_id
ORDER BY total_revenue DESC
LIMIT 5;
--volume of job per cusomer over time
SELECT
    jmp_customer_organization_id AS customer_id,
    DATE_TRUNC('month', jmp_job_date) AS job_month,
    SUM(jmp_order_quantity) AS job_count
FROM jobs
GROUP BY customer_id, job_month
ORDER BY customer_id, job_month;
--How have the number of estimated hours per customer changed over time?
WITH job_op AS (
    SELECT 
        jmo_job_id,
        jmo_estimated_production_hours,
        '2023' AS operation_year
    FROM job_operations_2023

    UNION ALL

    SELECT 
        jmo_job_id,
        jmo_estimated_production_hours,
        '2024' AS operation_year
    FROM job_operations_2024
)

SELECT 
    j.jmp_customer_organization_id AS customer_id,
    DATE_TRUNC('month', j.jmp_job_date) AS job_month,
    SUM(job_op.jmo_estimated_production_hours) AS total_production_hours
FROM jobs AS j
INNER JOIN job_op 
    ON j.jmp_job_id = job_op.jmo_job_id
GROUP BY customer_id, job_month
ORDER BY customer_id, job_month;

-- Average production hours per unique customer per month
WITH job_op AS (
    SELECT 
        jmo_job_id,
        jmo_estimated_production_hours,
        '2023' AS operation_year
    FROM job_operations_2023

    UNION ALL

    SELECT 
        jmo_job_id,
        jmo_estimated_production_hours,
        '2024' AS operation_year
    FROM job_operations_2024
)

SELECT 
    DATE_TRUNC('month', j.jmp_job_date) AS job_month,
    SUM(job_op.jmo_estimated_production_hours) / COUNT(DISTINCT j.jmp_customer_organization_id) AS avg_production_hours_per_customer
FROM jobs AS j
INNER JOIN job_op
    ON j.jmp_job_id = job_op.jmo_job_id
GROUP BY job_month
ORDER BY job_month;