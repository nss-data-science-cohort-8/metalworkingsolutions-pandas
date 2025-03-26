--  How has the volume of work changed for each customer over time? Are there any seasonal patterns? How have the number of estimated hours per customer changed over time? Estimated hours are in the jmo_estimated_production_hours columns of the job_operations_2023/job_operations_2024 tables.  

-- sales_orders_preview
SELECT *
FROM sales_orders
LIMIT 10;


-- for getting top 20 customers by revenue generation
SELECT 
    omp_customer_organization_id,
    omp_sales_order_id,
    omp_customer_po,
    omp_order_date,
    uomp_promise_date,
    omp_payment_term_id,
    omp_order_total_base
FROM sales_orders;


SELECT 
    jmp_customer_organization_id,
    jmp_job_id,
    jmp_part_id,
    jmp_part_short_description,
    jmp_order_quantity,
    jmp_production_quantity,
    jmp_production_due_date

FROM jobs
LIMIT 5;


SELECT  
    omj_sales_order_id,
    COUNT(DISTINCT omj_job_id) AS counts
FROM sales_order_job_links
GROUP BY omj_sales_order_id
ORDER BY counts DESC
limit 5;


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
	   jobs.jmp_customer_organization_id AS customer_id,
       SUM(jmo_completed_production_hours) AS completed_hours, 
       SUM(jmo_estimated_production_hours) AS estimated_hours
FROM combined_jobs
LEFT JOIN jobs ON combined_jobs.jmo_job_id = jobs.jmp_job_id
GROUP BY jobs.jmp_customer_organization_id










SELECT *
FROM job_operations_2023
LIMIT 5;


SELECT 
    jmo_job_id AS job_id,
    jmo_estimated_production_hours AS hours,
    jmo_process_short_description AS job_desc,
    jmo_quantity_complete AS quantity_complete

FROM job_operations_2023
LIMIT 5;


SELECT 
    jmo_job_id AS job_id,
    jmo_estimated_production_hours AS hours,
    jmo_created_date AS date_created,
    sml_shipment_id AS ship_id,
    sml_part_id AS part_id,
    sml_sales_order_id AS order_id
FROM job_operations_2023 j
    INNER JOIN shipment_lines sl
    ON sl.sml_job_id = j.jmo_job_id
ORDER BY ship_id
LIMIT 5;

SELECT  
    smp_shipment_id AS ship_id,
    smp_ship_date AS ship_date,
    smp_customer_organization_id AS customer_id,
    smp_shipment_total AS shipment_cost

FROM shipments s
    INNER JOIN shipment_lines sl
    ON s.smp_shipment_id = sl.sml_shipment_id
LIMIT 5;




WITH jo_23_24 AS (
    SELECT 
        jmo_job_id AS job_id,
        jmo_estimated_production_hours AS hours,
        jmo_created_date AS date_created,
        sml_shipment_id AS ship_id,
        sml_part_id AS part_id,
        sml_sales_order_id AS order_id
    FROM job_operations_2023 j
        INNER JOIN shipment_lines sl
        ON sl.sml_job_id = j.jmo_job_id

    UNION 

    SELECT 
    jmo_job_id AS job_id,
    jmo_estimated_production_hours AS hours,
    jmo_created_date AS date_created,
    sml_shipment_id AS ship_id,
    sml_part_id AS part_id,
    sml_sales_order_id AS order_id
FROM job_operations_2024 j
    INNER JOIN shipment_lines sl
    ON sl.sml_job_id = j.jmo_job_id
),
ships AS (
    SELECT  
        smp_shipment_id AS ship_id,
        smp_ship_date AS ship_date,
        smp_customer_organization_id AS customer_id,
        smp_shipment_total AS shipment_cost

    FROM shipments s
        INNER JOIN shipment_lines sl
        ON s.smp_shipment_id = sl.sml_shipment_id
)

SELECT *
FROM jo_23_24 j
    INNER JOIN ships s USING(ship_id)
GROUP BY j.job_id, j.hours, j.date_created, j.ship_id, j.part_id, j.order_id, s.ship_date, s.customer_id, s.shipment_cost
LIMIT 5;