# Define server logic
function(input, output, session) {
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

  # Render the appropriate revenue plot based on year selection
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
}
