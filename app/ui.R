ui <- page_navbar(
  bg = "#1E2127",

  # Andrew's Tab
  nav_panel("Andrew",
    icon = icon("house"),
    page_sidebar(
      sidebar = sidebar(
        uiOutput("dynamic_sidebar"),
        hr()
      ),
      navset_card_underline(
        title = "Customer Analysis",
        nav_panel("Revenue",
          icon = icon("dollar-sign"),
          plotlyOutput("revenue")
        ),
        nav_panel("Seasonal Trends",
          icon = icon("icicles"),
          plotlyOutput("seasonal"),
          hr(),
          conditionalPanel(
            condition = "input.year_selector === '2023 & 2024'",
            plotlyOutput("jobs_by_month")
          )
        ),
        nav_panel("Order Complexity",
          icon = icon("chart-simple"),
          selectInput("jobselect", "Select Jobs Analysis", choices = c(
            "Jobs per customer",
            "Big Spenders SOs",
            "Other Customers SOs",
            "Avg. Jobs per SO"
          ), selected = "Jobs per customer"),
          plotlyOutput("complexity")
        )
      )
    )
  ),

  # Jeff's Tab
  nav_panel("Jeff",
    icon = icon("chart-line"),
    navset_card_underline(
      title = "Customer Retention",
      nav_panel("Plot1",
        icon = icon("chart-line"),
        plotOutput("customerPlot")
      ),
      nav_panel("Plot2",
        icon = icon("chart-line"),
        plotOutput("customerPlot_2")
      ),
      nav_panel("Table",
        icon = icon("chart-simple"),
        div(
          style = "width: 100%; overflow-x: auto;",
          selectInput("tableChoice", "Choose a table:", choices = c(
            "cohort_count",
            "cohort_count_pct",
            "cohort_cumulative",
            "cohort_cumulative_pct"
          ), selected = "cohort_count", width = "200px"),
          DTOutput("cohortTable")
        )
      )
    )
  ),

  # Dollada's Tab
  nav_panel("Dollada",
    icon = icon("calculator"),
    page_sidebar(
      selectInput("chart_type", "Select Chart:",
        choices = c(
          "First-Time Customer Acquisition (Jan 2023 – Nov 2024)",
          "Percentage of New and Existing Customers per Month",
          "Top 10 Ordered Parts by New Customers (2023-2024)",
          "Top 10 Ordered Parts by Existing Customers (2023-2024)",
          "Proportion of One-Time Buyers vs Repeated Customers and Ordered Parts",
          "Production Hours vs. Earnings: Spotlight on Top 4 Revenue Companies"
        )
      ),
      sidebar = sidebar(
        hr()
      ),
      navset_card_underline(
        title = "New Customer Analysis Dashboard",
        nav_panel(
          "Charts!",
          uiOutput("selected_chart")
        )
      )
    )
  ),
  
  # Gracie's Tab
  nav_panel(
    "Gracie",
    icon = icon("bar-chart"),
    navset_card_underline(
      nav_panel(
        "Number of Jobs",
        layout_sidebar(
          sidebar = sidebar(
            width = 300,
            selectInput("year_filter", "Select Year:",
                        choices = c("Both" = "all", "2023" = "2023", "2024" = "2024"),
                        selected = "all")
          ),
          plotlyOutput("top_customer_plot", height = "600px")
        )
      )
    )
  )
)

