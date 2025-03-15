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


