# shiny web app -- metalworking solutions customer analysis

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
library(formattable)
library(lubridate)
library(dbplyr)
library(zoo)
library(readxl)
library(reactable)
library(scales)


# set up connection to postgres
connection <- dbConnect(
  Postgres(),
  dbname = "metalworkingsolutions",
  host = "localhost",
  port = 5432,
  user = "postgres",
  password = Sys.getenv("DB_PASSWORD") # with an .Rprofile and .Renviron i set
  # environment variable
  # password = rstudioapi::askForPassword("Database Password")
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


top_20_jobs <- jobs |>
  filter(customer_id %in% top20_customers_total$customer_id) |>
  group_by(customer_id) |>
  summarise(n_jobs = n_distinct(job_id)) |>
  arrange(desc(n_jobs))


big_spenders <- top20_customers_total$customer_id


complex_orders <- jobs |>
  filter(customer_id %in% big_spenders) |>
  mutate(order_id = str_sub(job_id, 1, 5)) |>
  group_by(customer_id, order_id) |>
  summarise(jobs_per_order = n_distinct(job_id), .groups = "drop") |>
  arrange(desc(jobs_per_order), customer_id)


top_20_total_jobs <- jobs |>
  mutate(order_id = str_sub(job_id, 1, 5)) |>
  group_by(order_id, customer_id) |>
  summarise(n_jobs = n_distinct(job_id), .groups = "drop") |>
  arrange(desc(n_jobs))


query <- "
SELECT
  EXTRACT(YEAR FROM smp_ship_date) AS year,
  smp_customer_organization_id AS customer_id,
  SUM(smp_shipment_total)::NUMERIC AS total_revenue
FROM shipments
GROUP BY smp_customer_organization_id, EXTRACT(YEAR FROM smp_ship_date)
HAVING EXTRACT(YEAR FROM smp_ship_date) = 2023
ORDER BY total_revenue DESC;
"
result_set <- dbSendQuery(connection, query)
customer_revenue_23 <- dbFetch(result_set)
dbClearResult(result_set)


query <- "
SELECT
  EXTRACT(YEAR FROM smp_ship_date) AS year,
  smp_customer_organization_id AS customer_id,
  SUM(smp_shipment_total)::NUMERIC AS total_revenue
FROM shipments
GROUP BY smp_customer_organization_id, EXTRACT(YEAR FROM smp_ship_date)
HAVING EXTRACT(YEAR FROM smp_ship_date) = 2024
ORDER BY total_revenue DESC;
"
result_set <- dbSendQuery(connection, query)
customer_revenue_24 <- dbFetch(result_set)
dbClearResult(result_set)


query <- "
SELECT
  smp_customer_organization_id AS customer_id,
  SUM(smp_shipment_total)::NUMERIC AS total_revenue
FROM shipments
GROUP BY smp_customer_organization_id
ORDER BY total_revenue DESC;
"
result_set <- dbSendQuery(connection, query)
customer_revenue_total <- dbFetch(result_set)
dbClearResult(result_set)


complex_orders_avg <- jobs |>
  filter(customer_id %in% top20_customers_total$customer_id) |>
  mutate(order_id = str_sub(job_id, 1, 5)) |>
  group_by(customer_id, order_id) |>
  summarise(jobs_per_order = n_distinct(job_id), .groups = "drop") |>
  group_by(customer_id) |>
  summarise(avg_jobs_per_order = mean(jobs_per_order), .groups = "drop") |>
  arrange(desc(avg_jobs_per_order), customer_id)

# JEFF ----------------------------------------------

# Access Sales Orders
so_query <- "
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
so_query_result <- dbGetQuery(connection, so_query)

so_query_result$order_date <- as.Date(
  so_query_result$order_date,
  format = "%Y-%m"
)

# FILL NA FUNCTION

replace_na_by_month <- function(df) {
  # find numeric columns
  num_cols <- names(df)[names(df) != "first_order_month"]

  # loop through
  for (col in num_cols) {
    month_index <- as.numeric(col) - 1

    df[[col]] <- mapply(function(value, first_order_month) {
      # Skip if first_order_month is NA
      if (is.na(first_order_month)) {
        return(value)
      }

      # parse date with column format
      first_order_date <- as.Date(
        paste0(
          first_order_month,
          "-01"
        ),
        format = "%Y-%b-%d"
      )

      # Calculate the target date
      target_date <- first_order_date + months(month_index)

      # replace NA with 0 if td is before or equal to November 2024
      if (target_date <= as.Date("2024-11-01")) {
        return(replace_na(value, 0))
      } else {
        return(value)
      }
    }, df[[col]], df$first_order_month)
  }

  return(df)
}

# CUSTOMER COHORT - CUSTOMER COUNT
customer_cohort <- so_query_result |>
  group_by(customer_id) |>
  summarise(first_order_month = floor_date(min(order_date), "month")) |>
  ungroup()

print(customer_cohort)

sales_orders <- so_query_result |>
  left_join(customer_cohort, by = "customer_id") |>
  mutate(
    months_since_first_order = floor(
      interval(
        first_order_month,
        order_date
      ) / months(1)
    )
  )

cohort_count <- sales_orders |>
  group_by(first_order_month, months_since_first_order) |>
  summarise(customers_in_cohort = n_distinct(customer_id)) |>
  spread(key = months_since_first_order, value = customers_in_cohort) |>
  arrange(first_order_month)

cohort_count$first_order_month <- format(
  cohort_count$first_order_month,
  "%Y-%b"
)

# apply fill function
cohort_count <- cohort_count |>
  ungroup() |>
  replace_na_by_month()

# spot check
print(cohort_count)

# CUSTOMER COHORT - NORMALIZED

cohort_count_pct <- cohort_count |>
  mutate(
    across(
      as.character(1:22),
      ~ round((.x / `0`) * 100, 1),
      .names = "{.col}"
    )
  )


# spot check
print(cohort_count_pct)



# COHORT CUMULATIVE

# identify all unique cohort start months
all_cohorts <- sales_orders |>
  distinct(first_order_month) |>
  arrange(first_order_month) |>
  pull(first_order_month)

# create empty tibble
cohort_cumulative <- data.frame(first_order_month = all_cohorts)

# loop through each cohort
for (cohort_date in all_cohorts) {
  # Filter data for this cohort

  cohort_data <- sales_orders |>
    filter(first_order_month == cohort_date)

  # loop through each month (0-22)
  for (i in 0:22) {
    count_customers <- cohort_data |>
      filter(months_since_first_order >= i) |>
      summarise(customer_count = n_distinct(customer_id)) |>
      pull(customer_count)

    # add to data frame
    value_to_add <- if (count_customers == 0) NA else count_customers
    cohort_cumulative[
      cohort_cumulative$first_order_month == cohort_date,
      as.character(i)
    ] <- value_to_add
  }
}


cohort_cumulative$first_order_month <- format(
  cohort_cumulative$first_order_month,
  "%Y-%b"
)

# apply fill function
cohort_cumulative <- cohort_cumulative |>
  ungroup() |>
  replace_na_by_month()

# spot check
print(cohort_cumulative)

# COHORT CUMULATIVE NORMALIZED

# create empty tibble
cohort_cumulative_pct <- data.frame(first_order_month = all_cohorts)

# loop through each cohort
for (cohort_date in all_cohorts) {
  # filter data for this cohort
  cohort_data <- sales_orders |>
    filter(first_order_month == cohort_date)

  # get grand total (month 0)
  initial_count <- cohort_data |>
    filter(months_since_first_order == 0) |>
    summarise(customer_count = n_distinct(customer_id)) |>
    pull(customer_count)

  # store grand total in "0"
  cohort_cumulative_pct[
    cohort_cumulative_pct$first_order_month == cohort_date,
    "0"
  ] <- initial_count

  # percentages for months 1-22
  for (i in 1:22) {
    # Get count of customers still active after i months
    count_customers <- cohort_data |>
      filter(months_since_first_order >= i) |>
      summarise(customer_count = n_distinct(customer_id)) |>
      pull(customer_count)

    # and total
    if (initial_count > 0) {
      percentage <- round((count_customers / initial_count) * 100, 1)
      # add to table, replacing 0 with NA

      value_to_add <- if (percentage == 0) NA else percentage
    } else {
      value_to_add <- NA
    }

    cohort_cumulative_pct[
      cohort_cumulative_pct$first_order_month == cohort_date,
      as.character(i)
    ] <- value_to_add
  }
}

cohort_cumulative_pct$first_order_month <- format(
  cohort_cumulative_pct$first_order_month,
  "%Y-%b"
)

# apply fill function
cohort_cumulative_pct <- cohort_cumulative_pct |>
  ungroup() |>
  replace_na_by_month()

# spot check
print(cohort_cumulative_pct)

# UNIQUE CUSTOMERS

customers_month <- so_query_result |>
  mutate(order_month = floor_date(order_date, "month"))

customers_month_2024 <- customers_month |>
  filter(year(order_month) == 2024)

unique_customers <- customers_month_2024 |>
  group_by(order_month) |>
  summarise(new_customers = n_distinct(customer_id)) |>
  mutate(
    simple_average = sum(new_customers) / n()
  )

# spot check
print(unique_customers)


# NEW CUSTOMERS

new_customers_df <- customers_month |>
  group_by(customer_id) |>
  mutate(first_purchase = min(order_date)) |>
  ungroup()

new_customers_df <- new_customers_df |>
  filter(year(first_purchase) == 2024)

# first p month
new_customers_df <- new_customers_df |>
  mutate(first_purchase_month = format(first_purchase, "%Y-%m"))

# first p month group by
new_groupby <- new_customers_df |>
  group_by(first_purchase_month) |>
  summarise(customer_count = n_distinct(customer_id)) |>
  arrange(first_purchase_month)

new_groupby_filtered <- new_groupby %>%
  filter(first_purchase_month != "2023-01")

# 6m rolling
new_groupby_filtered <- new_groupby_filtered |>
  mutate(
    rolling_avg = rollapply(
      customer_count,
      width = 6,
      FUN = mean,
      align = "right",
      fill = NA
    )
  )

# simple avg
new_groupby_filtered <- new_groupby_filtered |>
  mutate(simple_avg = mean(customer_count))

# spot check
print(new_groupby_filtered)

# GRACIE ----------------------------------------------

mws_color_pallete <- colorRampPalette(c("#445162", "#A1A7B0", "#C61126"))(20)


