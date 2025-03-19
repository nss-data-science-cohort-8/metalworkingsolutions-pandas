function(input, output, session) {
  con <- get_db_connection()  
  data_cache <- reactiveValues()  # Store chart data
  
  observe({
    selected_chart <- input$chart_type
    
    # 1️⃣ Percentage of New vs. Existing Customers
    if (selected_chart == "Percentage of New and Existing Customers per Month") {
      query <- "
      WITH first_transaction AS (
          SELECT omp_customer_organization_id,
                 MIN(omp_order_date) AS first_purchase_date
          FROM sales_orders
          GROUP BY omp_customer_organization_id
      )
      SELECT 
          EXTRACT(YEAR FROM o.omp_order_date) AS year,
          EXTRACT(MONTH FROM o.omp_order_date) AS month,
          COUNT(DISTINCT CASE 
              WHEN DATE_TRUNC('month', f.first_purchase_date) = DATE_TRUNC('month', o.omp_order_date) 
              THEN o.omp_customer_organization_id
          END) AS new_customers,
          COUNT(DISTINCT CASE 
              WHEN DATE_TRUNC('month', f.first_purchase_date) < DATE_TRUNC('month', o.omp_order_date) 
              THEN o.omp_customer_organization_id
          END) AS existing_customers,
          COUNT(DISTINCT o.omp_customer_organization_id) AS total_no
      FROM sales_orders AS o
      JOIN first_transaction AS f 
          ON o.omp_customer_organization_id = f.omp_customer_organization_id
      GROUP BY year, month
      ORDER BY year, month;
      "
      
      customer_data <- dbGetQuery(con, query) %>%
        mutate(date = as.Date(paste(year, month, "01", sep = "-")))
      
      customer_data_percent <- customer_data %>%
        mutate(new_customers_pct = (new_customers / total_no) * 100,
               existing_customers_pct = (existing_customers / total_no) * 100) %>%
        select(date, new_customers_pct, existing_customers_pct)
      
      data_cache$data <- customer_data_percent %>%
        pivot_longer(cols = c(new_customers_pct, existing_customers_pct),
                     names_to = "customer_type",
                     values_to = "percentage")
      
      # 2️⃣ Top 10 Ordered Parts by Existing Customers (2023-2024)
    } else if (selected_chart == "Top 10 Ordered Parts by Existing Customers (2023-2024)") {
      query <- "
      WITH first_transaction AS (
          SELECT omp_customer_organization_id,
                 MIN(omp_order_date) AS first_purchase_date
          FROM sales_orders
          GROUP BY omp_customer_organization_id
      )
      SELECT 
          j.jmp_part_short_description AS part_type,
          COUNT(j.jmp_part_short_description) AS no_ordered_part
      FROM sales_orders AS o
      JOIN first_transaction AS f
          ON o.omp_customer_organization_id = f.omp_customer_organization_id
      JOIN jobs AS j
          ON j.jmp_customer_organization_id = o.omp_customer_organization_id
      WHERE EXTRACT(YEAR FROM o.omp_order_date) IN (2023, 2024)
        AND f.first_purchase_date < o.omp_order_date
      GROUP BY j.jmp_part_short_description
      ORDER BY no_ordered_part DESC
      LIMIT 10;
      "
      data_cache$data <- dbGetQuery(con, query)
      
      # 3️⃣ Top 10 Ordered Parts by New Customers (2023-2024)
    } else if (selected_chart == "Top 10 Ordered Parts by New Customers (2023-2024)") {
      query <- "
      WITH first_transaction AS (
          SELECT omp_customer_organization_id,
                 MIN(omp_order_date) AS first_purchase_date
          FROM sales_orders
          GROUP BY omp_customer_organization_id
      )
      SELECT 
          j.jmp_part_short_description AS part_type,
          COUNT(j.jmp_part_short_description) AS no_ordered_part
      FROM sales_orders AS o
      JOIN first_transaction AS f
          ON o.omp_customer_organization_id = f.omp_customer_organization_id
      JOIN jobs AS j
          ON j.jmp_customer_organization_id = o.omp_customer_organization_id
      WHERE EXTRACT(YEAR FROM o.omp_order_date) IN (2023, 2024)
        AND f.first_purchase_date = o.omp_order_date
      GROUP BY j.jmp_part_short_description
      ORDER BY no_ordered_part DESC
      LIMIT 10;
      "
      data_cache$data <- dbGetQuery(con, query)
      
      # 4️⃣ Customer-Level Cohort Analysis (Plotly)
    } else if (selected_chart == "Customer-Level Analysis") {
      query <- "
      SELECT  
          EXTRACT(YEAR FROM omp_order_date) AS year,
          EXTRACT(MONTH FROM omp_order_date) AS month, 
          omp_customer_organization_id, 
          COUNT(omp_sales_order_id) AS order_no
      FROM sales_orders
      GROUP BY year, month, omp_customer_organization_id
      ORDER BY year, month;
      "
      data <- dbGetQuery(con, query) %>%
        mutate(order_date = as.Date(paste(year, month, "01", sep="-")))
      
      customer_cohort <- data %>%
        group_by(omp_customer_organization_id) %>%
        summarise(cohort_month = min(order_date), .groups = "drop")
      
      customer_cohort_summary <- data %>%
        left_join(customer_cohort, by = "omp_customer_organization_id") %>%
        mutate(months_since_first_order = interval(cohort_month, order_date) %/% months(1)) %>%
        group_by(omp_customer_organization_id, cohort_month, months_since_first_order) %>%
        summarise(total_orders = sum(order_no, na.rm = TRUE), .groups='drop')
      
      data_cache$data <- customer_cohort_summary
      
      # 5️⃣ Part Types Ordered by One-Time Customers
    } else if (selected_chart == "Part Types Ordered by One-Time Customers") {
      query <- "
      SELECT 
          j.jmp_part_short_description AS part_type,
          COUNT(DISTINCT s.omp_sales_order_id) AS order_no
      FROM sales_orders AS s
      JOIN jobs AS j 
          ON s.omp_customer_organization_id = j.jmp_customer_organization_id
      GROUP BY j.jmp_part_short_description
      HAVING COUNT(DISTINCT s.omp_sales_order_id) = 1
      ORDER BY order_no DESC;
      "
      data_cache$data <- dbGetQuery(con, query)
    }
  })
  
  output$selected_chart <- renderPlotly({
    req(data_cache$data)
    
    if (input$chart_type == "Customer-Level Analysis") {
      p <- ggplotly(ggplot(data_cache$data, aes(x = months_since_first_order, y = total_orders)) +
                      geom_tile(aes(fill = total_orders), color = "gray80") +
                      scale_fill_distiller(palette = "RdYlBu", direction = -1) +
                      theme_minimal())
      
      p
    } else {
      req("part_type" %in% names(data_cache$data))  # Ensure `part_type` exists
      
      ggplotly(ggplot(data_cache$data, aes(x = reorder(part_type, order_no), y = order_no, fill = part_type)) +
                 geom_col() + coord_flip() + theme_minimal())
    }
  })
  
  onStop(function() { dbDisconnect(con) })  
}