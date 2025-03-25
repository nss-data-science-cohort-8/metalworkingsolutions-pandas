# Define server logic
function(input, output, session) {
  # ---- ANDREW SERVER ---------------------------------------------------------

  # Render the dynamic sidebar with year selector
  output$dynamic_sidebar <- renderUI({
    selectInput(
      "year_selector",
      "Select Year",
      choices = c("2023", "2024", "2023 & 2024")
    )
  })

  # Reactive dataset based on year selection
  filtered_data <- reactive({
    req(input$year_selector) # Ensure input is available

    customer_filter <- switch(input$year_selector,
      "2023" = top20_customers_2023$customer_id,
      "2024" = top20_customers_2024$customer_id,
      "2023 & 2024" = top20_customers_total$customer_id
    )

    year_filter <- switch(input$year_selector,
      "2023" = 2023,
      "2024" = 2024,
      "2023 & 2024" = c(2023, 2024)
    )

    customers |>
      select(
        omp_order_date,
        omp_customer_organization_id,
        omp_order_total_base
      ) |>
      mutate(
        month = month(omp_order_date),
        year = year(omp_order_date)
      ) |>
      rename(
        customer_id = omp_customer_organization_id,
        generated_revenue = omp_order_total_base
      ) |>
      filter(
        year %in% year_filter,
        customer_id %in% customer_filter
      ) |>
      group_by(customer_id, month, year) |>
      summarise(generated_revenue = sum(generated_revenue), .groups = "drop") |>
      mutate(
        customer_id = factor(customer_id, levels = customer_filter)
      )
  })

  # Render the appropriate seasonal trends plot based on year selection
  output$seasonal <- renderPlotly({
    plot_data <- filtered_data()

    # Validate input data to avoid errors
    validate(
      need(nrow(plot_data) > 0, "No data available for the selected year(s).")
    )

    # Dynamically adjust x-axis for combined view
    x_axis <- if (input$year_selector == "2023 & 2024") {
      aes(x = make_date(year, month)) # Combine years on a date axis
    } else {
      aes(x = month)
    }

    # Dynamic title based on year selection
    plot_title <- paste(
      "Change in Customer Generated Revenue -",
      input$year_selector
    )

    p <- ggplot(plot_data, x_axis) +
      geom_line(aes(y = generated_revenue, color = customer_id)) +
      labs(
        title = plot_title,
        x = "Month",
        y = "Revenue ($)"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 55, hjust = 1))

    # Adjust x-axis for combined 2023 & 2024 view
    if (input$year_selector == "2023 & 2024") {
      p <- p +
        scale_x_date(
          date_breaks = "1 month",
          date_labels = "%b %Y"
        )
    } else {
      p <- p +
        scale_x_continuous(
          breaks = seq_along(month.name),
          labels = month.name
        )
    }

    ggplotly(p)
  })

  # Render the "Jobs by Month" plot
  output$jobs_by_month <- renderPlotly({
    # Ensure the dataset exists and is valid
    validate(
      need(exists("jobs"), "Jobs dataset is missing.")
    )

    # Create the jobs-by-month plot
    p4 <- jobs |>
      filter(customer_id %in% top20_customers_total$customer_id) |>
      mutate(
        month = month(production_due_date),
        year = year(production_due_date),
        month_year = make_date(year, month)
      ) |>
      group_by(month_year) |>
      summarise(n_jobs = n_distinct(job_id), .groups = "drop") |>
      arrange(desc(n_jobs)) |>
      ggplot(aes(
        x = month_year,
        y = n_jobs,
        text = paste(
          "Month:", month_year,
          "\nNumber of jobs:", n_jobs
        )
      )) +
      geom_col(fill = "#445162") +
      labs(
        title = "Number of Jobs by Due-Date",
        x = "Date",
        y = "Number of Jobs"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1)
      )

    ggplotly(p4, tooltip = "text")
  })


  filtered_data2 <- reactive({
    req(input$year_selector) # Ensure input is available

    selected_data <- switch(input$year_selector,
      "2023" = customer_revenue_23,
      "2024" = customer_revenue_24,
      "2023 & 2024" = customer_revenue_total
    )

    selected_data |>
      head(20)
  })

  # Render the appropriate revenue plot based on year selection
  output$revenue <- renderPlotly({
    plot_data <- filtered_data2()

    # Validate input data to avoid errors
    validate(
      need(nrow(plot_data) > 0, "No data available for the selected year(s).")
    )


    # Dynamic title based on year selection
    plot_title <- paste(
      "Customer Revenue by Year -",
      input$year_selector
    )

    p <- ggplot(
      plot_data,
      aes(
        x = fct_reorder(customer_id, -total_revenue),
        y = total_revenue,
        text = paste(
          "Customer ID:", customer_id,
          "\nRevenue: ", total_revenue
        )
      )
    ) +
      geom_col(fill = "#A1A7B0", color = "#c61126") +
      labs(
        title = "Revenue by customer for 2023",
        x = "Customer ID",
        y = "Revenue Generated"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(
          angle = 50,
          hjust = 1
        ),
        panel.background = element_rect(fill = "#445162", colour = "#c61126"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
      )

    ggplotly(p, tooltip = "text")
  })






  # ---- JEFF SERVER ----------------------------------------------
  # reactive table selection
  selected_table <- reactive({
    switch(input$tableChoice,
      "cohort_count" = cohort_count,
      "cohort_count_pct" = cohort_count_pct,
      "cohort_cumulative" = cohort_cumulative,
      "cohort_cumulative_pct" = cohort_cumulative_pct
    )
  })

  # render main table
  output$cohortTable <- renderDataTable({
    table_data <- selected_table()

    # replace NAs in the table
    table_data[] <- lapply(table_data, function(x) {
      if (is.factor(x)) {
        levels(x) <- c(levels(x), "") # Add empty level for factors
        x[is.na(x)] <- "" # Replace NAs with empty strings
      } else {
        x[is.na(x)] <- "" # Replace NAs with empty strings
      }
      return(x)
    })

    # render datatable with custom column widths
    datatable(
      table_data,
      options = list(
        pageLength = 25,
        autoWidth = FALSE,
        searching = FALSE,
        columnDefs = list(
          list(targets = 0, width = "75px"), # column width
          list(targets = "_all", width = "100px") # column width
        ),
        rowCallback = JS("
          function(row, data) {
            var startCol = 3;
            var endCol = 24;
            var rowValues = [];

            // Collect values from columns to be colored
            for (var i = startCol; i <= endCol; i++) {
              if (data[i] !== null && data[i] !== '') {
                var val = parseFloat(data[i]);
                if (!isNaN(val)) {
                  rowValues.push({index: i, value: val});
                }
              }
            }

            if (rowValues.length > 0) {
              var minVal = Math.min.apply(null, rowValues.map(function(item) { return item.value; }));
              var maxVal = Math.max.apply(null, rowValues.map(function(item) { return item.value; }));

              // Apply color gradient from red to green
              rowValues.forEach(function(item) {
                if (minVal === maxVal) return; // Skip coloring if all values are the same

                var ratio = (item.value - minVal) / (maxVal - minVal);
                var red = Math.round(255 * (1 - ratio));
                var green = Math.round(255 * ratio);
                var color = 'rgb(' + red + ',' + green + ',0)';

                $('td:eq(' + item.index + ')', row).css('background-color', color);
              });
            }
          }
        ")
      )
    )
  })
  # title mapping
  title_map <- list(
    "cohort_count" = "Customer Retention - Shows the Number of Customers that Placed an Order Relative to the Original Cohort",
    "cohort_count_pct" = "Customer Retention - Shows the Percent of Customers that Placed an Order Relative to the Original Cohort",
    "cohort_cumulative" = "Customer Retention - Shows the Number of Customers that Placed an Order in Current Month or Any Subsequent Month",
    "cohort_cumulative_pct" = "Customer Retention - Shows the Percent of Customers that Placed an Order in Current Month or Any Subsequent Month"
  )

  #  dynamic title
  output$dynamic_title <- renderText({
    title_map[[input$tableChoice]]
  })

  # plot 1
  output$customerPlot <- renderPlot({
    ggplot(unique_customers, aes(x = order_month, y = new_customers)) +
      geom_line(color = "#0073C2FF", size = 1.2) +
      geom_point(color = "#D55E00", size = 3) +
      geom_hline(aes(yintercept = simple_average),
        color = "orange",
        linetype = "dotted",
        size = 1
      ) +
      labs(
        title = "Unique Customers by Month ",
        subtitle = "Average of 42 Unique Customers per Month",
        x = " ",
        y = "Unique Customers",
        caption = "Data Source: Sales Orders"
      ) +
      theme_minimal() +
      scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
      theme(
        axis.text.x = element_text(angle = 90, hjust = 1),
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "italic"),
        plot.caption = element_text(hjust = 1, size = 10, face = "italic")
      )
  })

  # plot 2
  output$customerPlot_2 <- renderPlot({
    simple_avg_2 <- mean(new_groupby_filtered$customer_count, na.rm = TRUE)

    ggplot(new_groupby_filtered, aes(x = as.Date(paste0(first_purchase_month, "-01")))) +
      geom_line(aes(y = customer_count), color = "#0073C2FF", size = 1.2, na.rm = TRUE) +
      geom_point(aes(y = customer_count), color = "#D55E00", size = 3, na.rm = TRUE) +

      # Simple avg (dotted line)
      geom_hline(aes(yintercept = simple_avg_2),
        color = "orange",
        linetype = "dotted",
        size = 1
      ) +
      labs(
        title = "New Customers by Month",
        subtitle = "Average of 3.5 new customers per Month",
        x = " ",
        y = "New Customers",
        caption = "Data Source: Sales Orders"
      ) +
      theme_minimal() +
      scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
      theme(
        axis.text.x = element_text(angle = 90, hjust = 1),
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "italic"),
        plot.caption = element_text(hjust = 1, size = 10, face = "italic")
      )
  })
}
