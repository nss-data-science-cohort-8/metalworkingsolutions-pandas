# nolint start
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
          position = "dodge"
        ) +
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
            hjust = 0.25
          )
        )
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
          position = "dodge"
        ) +
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
  output$cohortTable <- renderDT({
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
        title = "Unique Customers by Month in 2024 ",
        subtitle = "Average of 43.4 Unique Customers per Month",
        x = " ",
        y = "Unique Customers",
        caption = "Data Source: Sales Orders"
      ) +
      theme_minimal() +
      scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
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
        title = "New Customers by Month in 2024",
        subtitle = "Average of 2.2 new customers per Month",
        x = " ",
        y = "New Customers",
        caption = "Data Source: Sales Orders"
      ) +
      theme_minimal() +
      scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "italic"),
        plot.caption = element_text(hjust = 1, size = 10, face = "italic")
      )
  })

  # -- DOLLADA SERVER -----------------------------------------------------------
  # ---- DOLLADA: Chart selection logic ----
  observeEvent(input$chart_type, {
    selected_chart <- input$chart_type

    if (selected_chart == "First-Time Customer Acquisition (Jan 2023 – Nov 2024)") {
      output$selected_chart <- renderUI({
        tagList(
          tags$img(src = "new_customer_per_month.jpg", height = "600px", width = "900px"),
          tags$br(),
          tags$div(
            tags$h4("Summary of First-Time Customer Trends (Jan 2023 – Nov 2024)"),
            tags$ul(
              tags$li("Customer acquisition was high during early 2023, followed by lower monthly averages thereafter."),
              tags$li("Steady customer acquisition with minor fluctuations throughout subsequent months."),
              tags$li("Potential opportunities to enhance customer acquisition during months with fewer new customers.")
            ),
            style = "margin-top:20px; font-size:16px;"
          )
        )
      })
    } else if (selected_chart == "Percentage of New and Existing Customers per Month") {
      output$selected_chart <- renderUI({
        tagList(
          fluidRow(
            column(
              width = 6,
              tags$img(
                src = "percent_new_existing.jpg",
                style = "width:100%; height:auto; border:1px solid #ccc; padding:10px;"
              )
            ),
            column(
              width = 6,
              tags$img(
                src = "sales_order_new&existing.jpg",
                style = "width:100%; height:auto; border:1px solid #ccc; padding:10px;"
              )
            )
          ),
          tags$div(
            tags$h4("Summary of Company Acquisition Trends (Jan 2023 – Nov 2024)"),
            tags$ul(
              tags$li("Percentage of new companies stabilized around 5–10% monthly from mid-2023 onward."),
              tags$li("High proportion of existing companies reflects stable business relationships.")
            ),
            style = "margin-top:20px; font-size:16px;"
          )
        )
      })
    } else if (selected_chart == "Top 10 Ordered Parts by New Customers (2023-2024)") {
      output$selected_chart <- renderUI({
        fluidRow(
          column(
            width = 9,
            tags$img(src = "first_time_buyer_part_2023.jpg", style = "width:100%; max-height:380px; height:auto;"),
            tags$br(), tags$br(),
            tags$img(src = "fist_time_buyer_parts_2024.jpg", style = "width:100%; max-height:380px; height:auto")
          ),
          column(
            width = 3,
            tags$div(
              tags$h4("Insights on Top Ordered Parts by New Customers (2023 vs. 2024)"),
              tags$ul(
                tags$li("Significant shifts observed in product demand between 2023 and 2024."),
                tags$li("2023's leading products include Wheel Box End Panels and Brackets."),
                tags$li("2024 sees rising demand for Coil Casings and numerically coded products.")
              ),
              style = "margin-top:20px; font-size:16px;"
            )
          )
        )
      })
    } else if (selected_chart == "Top 10 Ordered Parts by Existing Customers (2023-2024)") {
      output$selected_chart <- renderUI({
        fluidRow(
          column(
            width = 7,
            tags$img(src = "top10_parts_existing.jpg", style = "width:100%; max-height:400px; height:auto;")
          ),
          column(
            width = 5,
            tags$div(
              tags$h4("Insights on Top Ordered Parts by Existing Customers (2023-2024)"),
              tags$ul(
                tags$li("Wheel Box End Panels (RH & LH) clearly dominate existing customer orders, reflecting very high demand and consistent purchasing patterns."),
                tags$li("The top two products exceed 200,000 orders each, suggesting they are critical or highly popular items among existing customers.")
              ),
              style = "margin-top:20px; font-size:16px;"
            )
          )
        )
      })
    } else if (selected_chart == "Proportion of One-Time Buyers vs Repeated Customers and Ordered Parts") {
      output$selected_chart <- renderUI({
        fluidRow(
          column(
            width = 6,
            plotlyOutput("pie_chart", height = "500px")
          ),
          column(
            width = 6,
            tags$div(
              tags$h4("Insights on percentage distribution between customers"),
              tags$ul(
                tags$li("Approximately 79.7% of customers are repeated buyers, indicating strong customer retention and loyalty."),
                tags$li("About 20.3% represent one-time buyers, suggesting potential opportunities for targeted customer retention strategies."),
                tags$li("Analyze customer feedback to convert one-time buyers into repeated customers.")
              ),
              style = "margin-bottom: 20px; font-size:16px;"
            ),
            DT::dataTableOutput("parts_table")
          )
        )
      })

      output$parts_table <- DT::renderDataTable({
        req(file.exists("one_time_buyer_name_what_they_order.csv"))
        parts_data <- read_csv("one_time_buyer_name_what_they_order.csv")
        DT::datatable(parts_data, options = list(pageLength = 5, autoWidth = TRUE))
      })

      output$pie_chart <- renderPlotly({
        df_total <- data.frame(
          customer_type = c("One-Time Buyer", "Repeated Customer"),
          count = c(25, 98)
        )

        plot_ly(df_total,
          labels = ~customer_type, values = ~count, type = "pie",
          textinfo = "label+percent",
          insidetextorientation = "radial",
          marker = list(colors = c("#C61126", "#445162")),
          textfont = list(size = 16)
        ) %>%
          layout(
            title = list(
              text = "Proportion of One-Time Buyers vs Repeated Customers",
              font = list(size = 20)
            ),
            legend = list(font = list(size = 14)),
            margin = list(t = 120, b = 50, l = 50, r = 50)
          )
      })
    } else if (selected_chart == "Production Hours vs. Earnings: Spotlight on Top 4 Revenue Companies") {
      output$selected_chart <- renderUI({
        tagList(
          fluidRow(
            column(
              width = 6,
              tags$img(src = "time_spent_MORGO.jpg", style = "width:100%; max-height:300px; height:auto; margin-bottom:10px;"),
              tags$img(src = "time_spent_Y002.jpg", style = "width:100%; max-height:300px; height:auto; margin-bottom:10px;")
            ),
            column(
              width = 6,
              tags$img(src = "time_spent_F022.jpg", style = "width:100%; max-height:300px; height:auto; margin-bottom:10px;"),
              tags$img(src = "time_spent_S038.jpg", style = "width:100%; max-height:300px; height:auto; margin-bottom:10px;")
            )
          ),
          fluidRow(
            column(
              width = 12,
              tags$div(
                tags$h4("Key Observations"),
                tags$ul(
                  tags$li("A strong relationship between hours spent and earnings across most companies indicates that increased operational hours directly influence revenue."),
                  tags$li("Fewer operational hours still generate high earnings in some cases, indicating strong operational efficiency or high-value work.")
                ),
                style = "margin-top:20px; font-size:18px;"
              )
            )
          )
        )
      })
    } else {
      output$selected_chart <- renderUI({
        tags$p("Chart coming soon...")
      })
    }
  })

















  # -- GRACIE SERVER ------------------------------------------------------------
}
# nolint end
