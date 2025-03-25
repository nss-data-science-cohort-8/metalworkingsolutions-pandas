server <- function(input, output, session) {
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
    req(input$year_selector)

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
      mutate(customer_id = factor(customer_id, levels = customer_filter))
  })

  # Render the seasonal trends plot
  output$seasonal <- renderPlotly({
    plot_data <- filtered_data()
    validate(
      need(
        nrow(plot_data) > 0, "No data available for the selected year(s)."
      )
    )

    x_axis <- if (input$year_selector == "2023 & 2024") {
      aes(x = make_date(year, month))
    } else {
      aes(x = month)
    }

    plot_title <- paste(
      "Change in Customer Generated Revenue -",
      input$year_selector
    )

    p <- ggplot(plot_data, x_axis) +
      geom_line(aes(y = generated_revenue, color = customer_id)) +
      labs(title = plot_title, x = "Month", y = "Revenue ($)") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 55, hjust = 1))

    if (input$year_selector == "2023 & 2024") {
      p <- p + scale_x_date(date_breaks = "1 month", date_labels = "%b %Y")
    } else {
      p <- p + scale_x_continuous(
        breaks = seq_along(month.name),
        labels = month.name
      )
    }

    ggplotly(p)
  })

  # Render the "Jobs by Month" plot
  output$jobs_by_month <- renderPlotly({
    validate(need(exists("jobs"), "Jobs dataset is missing."))

    p4 <- jobs |>
      filter(customer_id %in% top20_customers_total$customer_id) |>
      mutate(
        month = month(production_due_date),
        year = year(production_due_date),
        month_year = make_date(year, month)
      ) |>
      group_by(month_year, customer_id) |>
      summarise(n_jobs = n_distinct(job_id), .groups = "drop") |>
      arrange(desc(n_jobs)) |>
      mutate(customer_id = fct_reorder(customer_id, n_jobs, .desc = FALSE)) |>
      ggplot(aes(
        x = month_year,
        y = n_jobs,
        fill = customer_id,
        text = paste(
          "Month:", month_year,
          "\nCustomer: ", customer_id,
          "\nNumber of jobs:", n_jobs
        )
      )) +
      geom_bar(position = "stack", stat = "identity") +
      labs(
        title = "Number of Jobs by Due-Date",
        x = "Date",
        y = "Number of Jobs"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))

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
  # Render the "Job Complexity" plots
  filtered_data3 <- reactive({
    req(input$jobselect)
    switch(input$jobselect,
      "Jobs per customer" = top_20_jobs,
      "Big Spenders SOs" = complex_orders,
      "Other Customers SOs" = top_20_total_jobs,
      "Avg. Jobs per SO" = complex_orders_avg
    )
  })

  # Render the complexity plot
  output$complexity <- renderPlotly({
    plot_data3 <- filtered_data3()
    validate(need(nrow(plot_data3) > 0, "No data available for the selection."))

    plot_title <- paste("Order Complexity -", input$jobselect)

    if (input$jobselect == "Jobs per customer") {
      p1 <- ggplot(
        plot_data3,
        aes(
          x = fct_reorder(customer_id, -n_jobs),
          y = n_jobs,
          text = paste(
            "Customer ID: ", customer_id,
            "\nNumber of Jobs: ", n_jobs
          )
        )
      ) +
        geom_col(
                 fill = "#445162", 
                 color = "#c61126", 
                 position = "dodge") +
        geom_text(
          aes(
            label = n_jobs,
            y = n_jobs + 100
          ),
          color = "#445162",
          size = 3
        ) +
        labs(
          title = "Total Jobs by Customer ID",
          x = "Customer ID",
          y = "Number of Jobs"
        ) +
        theme_minimal() +
        theme(
              axis.text.x = element_text(
                                         angle = 55, 
                                         hjust = 0.25))
      ggplotly(p1, tooltip = "text")
    } else if (input$jobselect == "Big Spenders SOs") {
      p2 <- complex_orders |>
        head(50) |>
        ggplot(aes(
          x = fct_reorder(order_id, -jobs_per_order),
          y = jobs_per_order,
          text = paste(
            "customer: ", customer_id,
            "\njobs/order: ", jobs_per_order
          )
        )) +
        geom_col(
                 fill = "#445162",
                 color = "#c61126",
                 position = "dodge") +
        geom_text(
          aes(
            label = jobs_per_order,
            y = jobs_per_order + 1
          ),
          color = "#445162",
          size = 2
        ) +
        labs(
          title = "Top 50 Sales orders by # jobs of Big Spenders",
          x = "Order ID",
          y = "Number of Jobs per Sales Order"
        ) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 65, hjust = 1))
      ggplotly(p2, tooltip = "text")
    } else if (input$jobselect == "Other Customers SOs") {
      p4 <- top_20_total_jobs |>
        head(20) |>
        ggplot(aes(
          y = fct_reorder(order_id, n_jobs),
          x = n_jobs,
          text = paste(
            "Customer ID: ", customer_id,
            "\nNumber of Jobs: ", n_jobs
          )
        )) +
        geom_bar(stat = "identity", fill = "#445162", color = "#c61126") +
        geom_text(
          aes(
            label = n_jobs,
            x = n_jobs - 2
          ),
          color = "#FFFFFF",
          size = 3.5,
          hjust = 1
        ) +
        geom_text(
          aes(
            label = customer_id,
            x = n_jobs / 2
          ),
          color = "#a1a7b0",
          size = 4,
          angle = 0,
          vjust = 0.5
        ) +
        labs(
          title = "Most jobs by sales order for all customers",
          y = "Sales Order ID",
          x = "Number of Jobs per order"
        ) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 0, hjust = 1))
      ggplotly(p4, tooltip = "text")
    } else if (input$jobselect == "Avg. Jobs per SO") {
      p3 <- complex_orders_avg |>
        ggplot(aes(
          x = fct_reorder(customer_id, -avg_jobs_per_order),
          y = avg_jobs_per_order,
          text = paste(
            "customer: ", customer_id,
            "\navg jobs/order: ", avg_jobs_per_order
          )
        )) +
        geom_col(fill = "#445162", color = "#c61126") +
        geom_text(
          aes(
            label = round(avg_jobs_per_order, 1),
            y = round(avg_jobs_per_order, 1) - 0.25
          ),
          color = "#ffffff",
          size = 3.5
        ) +
        labs(
          title = "Average Jobs per Sales Order per Customer",
          x = "Customer",
          y = "Average Number of Jobs"
        ) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 55, hjust = 1))
      ggplotly(p3, tooltip = "text")
    } else {
      return("Sorry, nothing to see here")
    }
  })

  # ---- JEFF SERVER ----------------------------------------------
  selected_table <- reactive({
    switch(input$tableChoice,
      "cohort_count" = cohort_count,
      "cohort_count_pct" = cohort_count_pct,
      "cohort_cumulative" = cohort_cumulative,
      "cohort_cumulative_pct" = cohort_cumulative_pct
    )
  })

  output$cohortTable <- renderDataTable({
    table_data <- selected_table()
    table_data[] <- lapply(table_data, function(x) {
      if (is.factor(x)) {
        levels(x) <- c(levels(x), "")
        x[is.na(x)] <- ""
      } else {
        x[is.na(x)] <- ""
      }
      return(x)
    })

    datatable(
      table_data,
      options = list(
        pageLength = 25,
        autoWidth = FALSE,
        searching = FALSE,
        columnDefs = list(
          list(targets = 0, width = "75px"),
          list(targets = "_all", width = "100px")
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

  # Dynamic title for cohort table
  output$dynamic_title <- renderText({
    title_map[[input$tableChoice]]
  })

  # Plot 1: Unique Customers by Month
  output$customerPlot <- renderPlot({
    ggplot(unique_customers, aes(x = order_month, y = new_customers)) +
      geom_line(color = "#0073C2FF", size = 1.2) +
      geom_point(color = "#D55E00", size = 3) +
      geom_hline(aes(yintercept = simple_average), color = "orange", linetype = "dotted", size = 1) +
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

  # Plot 2: New Customers by Month
  output$customerPlot_2 <- renderPlot({
    simple_avg_2 <- mean(new_groupby_filtered$customer_count, na.rm = TRUE)

    ggplot(new_groupby_filtered, aes(x = as.Date(paste0(first_purchase_month, "-01")))) +
      geom_line(aes(y = customer_count), color = "#0073C2FF", size = 1.2, na.rm = TRUE) +
      geom_point(aes(y = customer_count), color = "#D55E00", size = 3, na.rm = TRUE) +
      geom_hline(aes(yintercept = simple_avg_2), color = "orange", linetype = "dotted", size = 1) +
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
