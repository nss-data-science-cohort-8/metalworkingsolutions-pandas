
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