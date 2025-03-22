page_navbar(
  bg = "#1E2127",

  # --- ANDREW -----------------
  nav_panel("Andrew", icon = icon("house"), p(
    page_sidebar(
      sidebar = sidebar(

        # Input: Year selector dropdown (2023, 2024, 2023 & 2024) ----
        uiOutput("dynamic_sidebar"),

        # Add horizontal rule between elements
        hr(),

        # Input: Toggle all customers button ----
        actionButton(
          "top_20_or_all",
          "Toggle all customers"
        )
      ),

      # Main panel for displaying outputs ----
      navset_card_underline(
        title = "analyzing",

        # Panel with revenue-related content ----
        nav_panel("Revenue", icon = icon("dollar-sign"), p(
          plotlyOutput("revenue")
        )),

        # Panel with seasonal trends ----
        nav_panel("Seasonal Trends", icon = icon("icicles"), p(
          plotlyOutput("seasonal"),
          hr(),
          plotlyOutput("jobs_by_month") # Added the new jobs plot here
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
    page_sidebar(
      title = "Customer Analysis",
      sidebar = sidebar(),
      navset_card_underline(
        title = "analyzing",
        nav_panel("retention"),
        nav_panel("churn"),
        nav_panel("peepeepoopoo")
      )
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
