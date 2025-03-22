# shiny web app -- metalworking solutions customer analysis

shh <- suppressMessages
library(shiny)
library(tidyverse)
library(DT)
library(glue)
library(bslib)
library(plotly)
library(shinyjs)
library(ggrepel)
library(shinythemes)
library(htmltools)
library(markdown)
library(rmarkdown)
library(DBI)
library(RPostgres)

# set up connection to postgres
connection <- dbConnect(
  Postgres(),
  dbname = "metalworkingsolutions",
  host = "localhost",
  port = 5432,
  user = "postgres",
  # password = Sys.getenv("DB_PASSWORD")
  password = rstudioapi::askForPassword("Database Password")
)

# create query for top 20 customers for seasonal evaluation
query <- "
SELECT
    omp_customer_organization_id,
    omp_sales_order_id,
    omp_customer_po,
    omp_order_date,
    uomp_promise_date,
    omp_payment_term_id,
    omp_order_total_base
FROM sales_orders;
"
result_set <- dbSendQuery(connection, query)
# create tibble for customers
customers <- dbFetch(result_set)
dbClearResult(result_set)

# get top 20 customers by generated revenue
# for 2023, 2024, and both years combined
top20_customers_2023 <- customers |>
  select(
    omp_order_date,
    omp_customer_organization_id,
    omp_order_total_base
  ) |>
  group_by(omp_customer_organization_id) |>
  mutate(omp_order_date = year(omp_order_date)) |>
  filter(omp_order_date %in% 2023) |>
  summarise(generated_revenue_2023 = sum(omp_order_total_base)) |>
  rename(customer_id = omp_customer_organization_id) |>
  arrange(desc(generated_revenue_2023)) |>
  select(customer_id) |>
  head(20)

# 2024
top20_customers_2024 <- customers |>
  select(
    omp_order_date,
    omp_customer_organization_id,
    omp_order_total_base
  ) |>
  group_by(omp_customer_organization_id) |>
  mutate(omp_order_date = year(omp_order_date)) |>
  filter(omp_order_date %in% 2024) |>
  summarise(generated_revenue_2023 = sum(omp_order_total_base)) |>
  rename(customer_id = omp_customer_organization_id) |>
  arrange(desc(generated_revenue_2023)) |>
  select(customer_id) |>
  head(20)

# 2023 & 2024
#| code-fold: true
top20_customers_total <- customers |>
  select(
    omp_order_date,
    omp_customer_organization_id,
    omp_order_total_base
  ) |>
  group_by(omp_customer_organization_id) |>
  mutate(omp_order_date = year(omp_order_date)) |>
  summarise(generated_revenue_2023 = sum(omp_order_total_base)) |>
  rename(customer_id = omp_customer_organization_id) |>
  arrange(desc(generated_revenue_2023)) |>
  select(customer_id) |>
  head(20)



# New query to select jobs
query <- "
SELECT
    jmp_customer_organization_id AS customer_id,
    jmp_job_id AS job_id,
    jmp_part_id AS part_id,
    jmp_part_short_description AS part_description,
    jmp_order_quantity AS order_quantity,
    jmp_production_quantity AS production_quantity,
    jmp_production_due_date AS production_due_date

FROM jobs;
"
result_set <- dbSendQuery(connection, query)
jobs <- dbFetch(result_set)
dbClearResult(result_set)
