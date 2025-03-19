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

cohort_count <- read_excel("data/read_cohort_count.xlsx")
cohort_count_normalized <- read_excel("data/read_cohort_count_normalized.xlsx")
cohort_revenue<- read_excel("data/read_cohort_revenue.xlsx")

# Format the numeric columns as percentages rounded to 1 decimal place
cohort_count_normalized[] <- lapply(cohort_count_normalized, function(x) {
  if (is.numeric(x)) {
    # Convert to percentage and round to 1 decimal place
    x <- round(x * 100, 1)
  }
  return(x)
})


