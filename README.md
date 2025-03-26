# Metalworking Solutions

Metalworking Solutions is a sheet metal fabricator based in Chattanooga, Tennessee. Established in 2006, the company offers laser cutting, punching, bending, welding, finishing, and delivery services and ships over 2 million parts annually. 

You've been provided a dataset of jobs since the beginning of 2023.

A few tips for navigating the database: Each job can have multiple job operations in the job_operations_2023/job_operations_2024 table. You can connect the jobs to the job_operations. The jmp_job_id references jmo_job_id in the job_operations_2023/job_operations_2024 tables.  Jobs can be connected to sales orders through the sales_order_job_links table.  

For your project, your group will be responsible for one of the following sets of questions. Construct an R Shiny app to show your findings.

**1. Do an analysis of customers. The customer can be identified using the jmp_customer_organization_id from the jobs table or the omp_customer_organization_id from the sales_orders table. Here are some example questions to get started:  
    a. Which customers have the highest volume of jobs? Which generate the most revenue (as indicated by the omp_order_subtotal_base in the sales_order table)?  
    b. How has the volume of work changed for each customer over time? Are there any seasonal patterns? How have the number of estimated hours per customer changed over time? Estimated hours are in the jmo_estimated_production_hours columns of the job_operations_2023/job_operations_2024 tables.  
    c. How has the customer base changed over time? What percentage of jobs are for new customers compared to repeat customers?  
    d. Perform a breakdown of customers by operation (as indicated by the jmo_process short_description in the job_operations_2023 or job_operations_2024 table).**
2. Analyze parts. The part can be identified by the jmp_part_id from the jobs table or the jmp_part_id from the job_operations_2023/job_operations_2024 tables. Here are some questions to get started:    
    a. Break down parts by volume of jobs. Which parts are making up the largest volume of jobs? Which ones are taking the largest amount of production hours (based on the jmo_actual_production_hours in the job_operations tables)?  
    b. How have the parts produced changed over time? Are there any trends? Are there parts that were prominent in 2023 but are no longer being produced or are being produced at much lower volumes in 2024? Have any new parts become more commonly produced over time?  
    c. Are there parts that frequently exceed their planned production hours (determined by comparing the jmo_estimated_production_hours to the jmo_actual_production_hours in the job_operations tables)?  
    d. Are the most high-volume parts also ones that are generating the most revenue per production hour?  
3. Inspect the type of operation for each job, as indicated by the jmo_process_short_description in the job_operations_2023 or job_operations_2024 table.  
    a. Are there certain operations, such as welding, which generate more revenue per production hour?  
    b. Are certain operations consistently generating more revenue per production hour than others or has it changed over time?  
    c. Which operations are most frequently associated with the company's top customers? Are they also the ones that are generating the most revenue per production hour?  
4. How has the volume of jobs changed over time? Look at the number of bookings or number of shipments by week and month. How does on-time delivery vary by week, month, or over time? Does on-time delivery vary by part? To find on-time delivery, you can compare the smp_ship_date to the jmp_production_due_date column from the jobs table. 
