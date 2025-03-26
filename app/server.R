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
  
  # Seasonal trends plot
  output$seasonal <- renderPlotly({ ... })  # Keep your existing code here
  
  # Jobs by month
  output$jobs_by_month <- renderPlotly({ ... })  # Keep your existing code here
  
  # Revenue plots
  filtered_data2 <- reactive({ ... })  # Your existing filtered_data2 code
  output$revenue <- renderPlotly({ ... })  # Your existing output$revenue code
  
  # Job Complexity
  filtered_data3 <- reactive({ ... })  # Your existing code
  output$complexity <- renderPlotly({ ... })  # Your existing code
  
  # ---- JEFF SERVER: Cohort Table ----
  selected_table <- reactive({ ... })
  output$cohortTable <- renderDataTable({ ... })
  output$dynamic_title <- renderText({ ... })
  
  # Plot 1: Unique Customers
  output$customerPlot <- renderPlot({ ... })
  
  # Plot 2: New Customers
  output$customerPlot_2 <- renderPlot({ ... })
  
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
    }
    else if (selected_chart == "Percentage of New and Existing Customers per Month") {
      output$selected_chart <- renderUI({
        tagList(
          fluidRow(
            column(width = 6,
                   tags$img(src = "percent_new_existing.jpg", 
                            style = "width:100%; height:auto; border:1px solid #ccc; padding:10px;")
            ),
            column(width = 6,
                   tags$img(src = "sales_order_new&existing.jpg", 
                            style = "width:100%; height:auto; border:1px solid #ccc; padding:10px;")
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
    }
    else if (selected_chart == "Top 10 Ordered Parts by New Customers (2023-2024)") {
      output$selected_chart <- renderUI({
        fluidRow(
          column(width = 7, 
                 tags$img(src = "first_time_buyer_part_2023.jpg", style="width:100%; max-height:380px; height:auto;"),
                 tags$br(),tags$br(),
                 tags$img(src = "fist_time_buyer_parts.jpg_2024.jpg", style="width:100%; max-height:380px; height:auto")
          ),
          column(width = 5, 
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
    }
    else if (selected_chart == "Top 10 Ordered Parts by Existing Customers (2023-2024)") {
      output$selected_chart <- renderUI({
        fluidRow(
          column(width = 7, 
                 tags$img(src = "top10_parts_existing.jpg", style="width:100%; max-height:400px; height:auto;")
          ),
          column(width = 5, 
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
    }
    else if (selected_chart == "Proportion of One-Time Buyers vs Repeated Customers and Ordered Parts") {
      output$selected_chart <- renderUI({
        fluidRow(
          column(width = 6,
                 plotlyOutput("pie_chart", height = "500px")
          ),
          column(width = 6,
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
        req(file.exists("one_time_buyer_name_what_they_order.xlsx")) 
        parts_data <- readxl::read_excel("one_time_buyer_name_what_they_order.xlsx")
        DT::datatable(parts_data, options = list(pageLength = 5, autoWidth = TRUE))
      })
      
      output$pie_chart <- renderPlotly({
        df_total <- data.frame(
          customer_type = c("One-Time Buyer", "Repeated Customer"),
          count = c(25, 98)
        )
        
        plot_ly(df_total, labels = ~customer_type, values = ~count, type = 'pie',
                textinfo = 'label+percent',
                insidetextorientation = 'radial',
                marker = list(colors = c("#C61126", "#445162")),
                textfont = list(size = 16)) %>%
          layout(title = list(text = "Proportion of One-Time Buyers vs Repeated Customers",
                              font = list(size = 20)),
                 legend = list(font = list(size = 14)),
                 margin = list(t = 120, b = 50, l = 50, r = 50))
      })
    }
    else if (selected_chart == "Production Hours vs. Earnings: Spotlight on Top 4 Revenue Companies") {
      output$selected_chart <- renderUI({
        tagList(
          fluidRow(
            column(width = 6,
                   tags$img(src = "time_spent_MORGO.jpg", style = "width:100%; max-height:300px; height:auto; margin-bottom:10px;"),
                   tags$img(src = "time_spent_Y002.jpg", style = "width:100%; max-height:300px; height:auto; margin-bottom:10px;")
            ),
            column(width = 6,
                   tags$img(src = "time_spent_F022.jpg", style = "width:100%; max-height:300px; height:auto; margin-bottom:10px;"),
                   tags$img(src = "time_spent_S038.jpg", style = "width:100%; max-height:300px; height:auto; margin-bottom:10px;")
            )
          ),
          fluidRow(
            column(width = 12,
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
    }
    else {
      output$selected_chart <- renderUI({
        tags$p("Chart coming soon...")
      })
    }
  })
}
# nolint end
