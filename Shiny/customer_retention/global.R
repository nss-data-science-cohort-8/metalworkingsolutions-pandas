library(shiny)
library(DBI)
library(formattable)
library(RPostgres)
library(tidyverse)
library(lubridate)
library(dplyr)
library(dbplyr)
library(ggplot2)
library(zoo)
library(readxl)
library(reactable)
library(DT)
library(scales)

#cohort_count <- read_excel("data/read_cohort_count.xlsx")
#cohort_count_normalized <- read_excel("data/read_cohort_count_normalized.xlsx")

# Database
con <- dbConnect(Postgres(),                
                 dbname = 'metalworking',
                 host = 'localhost',    
                 port = 5432, 
                 user = 'postgres',
                 password = rstudioapi::askForPassword("Database password"))


# Access Sales Orders
so_query <-"
SELECT 
	omp_sales_order_id AS sales_order_number,
	omp_customer_organization_id AS customer_id,
	omp_order_date order_date,
	omp_shipping_method_id AS shipping_method,
	omp_payment_term_id AS terms,
	omp_created_from_web AS web_order,
	omp_full_order_subtotal_base AS subtotal,
	omp_order_total_base AS total,
	omp_total_order_weight AS order_weight
FROM sales_orders;
"
# Create the Cohort_Count Table

so_query_result <- dbGetQuery(con, so_query)

so_query_result$order_date <- as.Date(so_query_result$order_date, format = "%Y-%m")

#CUSTOMER COHORT - CUSTOMER COUNT
customer_cohort <- so_query_result |> 
  group_by(customer_id) |> 
  summarise(first_order_month = floor_date(min(order_date), "month")) |> 
  ungroup()


sales_orders <- so_query_result |> 
  left_join(customer_cohort, by = "customer_id") |> 
  mutate(
    months_since_first_order = floor(interval(first_order_month, order_date) / months(1))
  )

cohort_count <- sales_orders |>
  group_by(first_order_month, months_since_first_order) |>
  summarise(customers_in_cohort = n_distinct(customer_id)) |>
  spread(key = months_since_first_order, value = customers_in_cohort) |>
  arrange(first_order_month)

cohort_count$first_order_month <- format(cohort_count$first_order_month, "%Y-%b")

#spot check
print(cohort_count)

#CUSTOMER COHORT - NORMALIZED

cohort_count_normalized <- cohort_count |>
  mutate(across(as.character(1:22), ~ round((.x / `0`) * 100, 1), .names = "{.col}"))

# spot check
print(cohort_count_normalized)


cohort_revenue<- read_excel("data/read_cohort_revenue.xlsx")




