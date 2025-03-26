
ui <- page_navbar(
  bg = "#1E2127",
  nav_panel("Andrew", icon = icon("house"), p(
    page_sidebar(
      sidebar = sidebar(
        uiOutput("dynamic_sidebar"),
        hr()
      ),
      navset_card_underline(
        title = "Customer Analysis",
        nav_panel("Revenue", icon = icon("dollar-sign"), p(
          plotlyOutput("revenue")
        )),
        nav_panel("Seasonal Trends", icon = icon("icicles"), p(
          plotlyOutput("seasonal"),
          hr(),
          conditionalPanel(
            condition = "input.year_selector === '2023 & 2024'",
            plotlyOutput("jobs_by_month")
          )
        )),
        nav_panel("Order Complexity", icon = icon("chart-simple"), p(
          selectInput("jobselect", "Select Jobs Analysis", choices = c(
            "Jobs per customer",
            "Big Spenders SOs",
            "Other Customers SOs",
            "Avg. Jobs per SO"
          ), selected = "Jobs per customer"),
          plotlyOutput("complexity")
        ))
      )
    )
  )),
  nav_panel("Jeff", icon = icon("chart-line"), p(
    navset_card_underline(
      title = "Customer Retention",
      nav_panel("Plot1", icon = icon("chart-line"), p(
        plotOutput("customerPlot")
      )),
      nav_panel("Plot2", icon = icon("chart-line"), p(
        plotOutput("customerPlot_2")
      )),
      nav_panel("Table", icon = icon("chart-simple"), p(
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
      ))
    )
  )),
  nav_panel("Dollada",
            icon = icon("calculator"),
            navset_card_underline(title = "What we learned")
  ),
  nav_panel("Gracie",
            icon = icon("calculator"),
            navset_card_underline(title = "What we learned")
  )
)

