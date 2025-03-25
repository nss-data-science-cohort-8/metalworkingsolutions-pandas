page_navbar(
  bg = "#1E2127",

  # --- ANDREW -----------------
  nav_panel("Andrew", icon = icon("house"), p(
    page_sidebar(
      sidebar = sidebar(

        # Input: Year selector dropdown (2023, 2024, 2023 & 2024) ----
        uiOutput("dynamic_sidebar"),
        hr(),
      ),

      # Main panel for displaying outputs ----
      navset_card_underline(
        title = "customer analysis",

        # Panel with revenue-related content ----
        nav_panel("Revenue", icon = icon("dollar-sign"), p(
          plotlyOutput("revenue")
        )),

        # Panel with seasonal trends ----
        nav_panel("Seasonal Trends", icon = icon("icicles"), p(
          plotlyOutput("seasonal"),
          hr(),
          conditionalPanel(
            condition = "input.year_selector === '2023 & 2024'",
            plotlyOutput("jobs_by_month")
          )
        )),

        # Panel with order complexity analysis ----
        nav_panel("Order Complexity", icon = icon("chart-simple"), p(
          plotlyOutput("complexity")
        ))
      )
    )
  )),

  # ------ JEFF ------------
  nav_panel("Jeff", icon = icon("chart-line"), p(
    navset_card_underline(
      title = "customer retention",

      # Panel with revenue-related content ----
      nav_panel("Plot1", icon = icon("chart-line"), p(
        plotOutput("customerPlot")
      )),

      # Panel with seasonal trends ----
      nav_panel("Plot2", icon = icon("chart-line"), p(
        plotOutput("customerPlot_2")
      )),

      # Panel with order complexity analysis ----
      nav_panel("Table", icon = icon("chart-simple"), p(
        div(
          style = "width: 100%; overflow-x: auto;",
          selectInput("tableChoice",
            "Choose a table:",
            choices = c(
              "cohort_count",
              "cohort_count_pct",
              "cohort_cumulative",
              "cohort_cumulative_pct"
            ),
            selected = "cohort_count",
            width = "200px"
          ),
          DTOutput("cohortTable")
        )
      ))
    )
  )),

  # --- DOLLADA ----
  nav_panel(
    "Dollada",
    icon = icon("calculator"),
    navset_card_underline(
      title = "What we learned"
    )
  ),

  # --- GRACIE ----
  nav_panel(
    "Gracie",
    icon = icon("calculator"),
    navset_card_underline(
      title = "What we learned"
    )
  )
)
