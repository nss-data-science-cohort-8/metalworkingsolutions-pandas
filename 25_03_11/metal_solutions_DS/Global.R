library(DBI)
library(RPostgres)
library(tidyverse)
library(shiny)
library(lubridate)
library(plotly)

get_db_connection <- function() {
  dbConnect(Postgres(),
            dbname = "metalworking solution",
            host = "localhost",
            port = 5432,
            user = "postgres",
            password = "Postgre")
}