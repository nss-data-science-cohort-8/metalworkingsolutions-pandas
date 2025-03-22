page_navbar(
  bg = "#1E2127",
  # --- ANDREW -----------------
  nav_panel("Andrew", icon = icon("house"), p(
    fluidRow(
      p(
        h1("proj title ? something else ? "),
      ),
      column(
        width = 3
      ),
      column(
        br(),
        p(
          "Customer analysis for",
          em(strong("Metalworking Solutions")),
          "by the ", em(strong("Pandas")),
          style = (
            paste("text-align:justify;color:black;background-color:",
              "lightblue;padding:15px;border-radius:10px")
          )
        ),
        br(),
        p(em("any disclaimers can go here"),
          style = (
            paste("text-align:justify;color:black;background-color",
              ":papayawhip;padding:15px;border-radius:10px")
          )
        ),
        width = 6
      ),
      hr(),
    ),
  )),
  # ------ JEFF ------------
  nav_panel("Jeff", icon = icon("chart-line"), p(
    page_sidebar(
      # App title ----
      title = "Customer Analysis",

      # Sidebar panel for inputs ----
      sidebar = sidebar(

        # Input: Action Buttons to toggle the sidebar content ----
        actionButton(
          "seasonal",
          "Seasonal Trends"
        ),
        actionButton(
          "change_over_time",
          "Change Over Time"
        ),
        # Dynamic UI content that will change based on the button clicked
        uiOutput("dynamic_sidebar"),

        # Add horizontal rule between elements
        hr(),
        uiOutput(
          "happy_sad_label"
        ),
        actionButton(
          "top_20_or_all",
          "Toggle all customers",
        ),

        # Custom footer
        tags$footer(
          glue(
            "*Sadness Score = (n new cases of depressive or anxiety disorders)",
            " / (country population measured mid-year)     |     ",
            "**Happiness Score = national average Cantril Life Ladder"
          ),
          style = ("background-color: #f8f9fa; color: #333; text-align: center;
               padding: 5px; font-size: 8px; font-family: Arial, sans-serif;
               position: fixed; left: 0; bottom: 0; width: 100%;")
        ),

        # Additional CSS to ensure the footer is above other content
        tags$style(HTML("
    body {
      padding-bottom: 20px; /* Adjust based on footer height */
    }
  "))
      ),

      # Main panel for displaying outputs ----
      navset_card_underline(
        title = "analyizing",

        # Panel with scatter and trendline plot ----
        nav_panel("retention"),
        # Panel with scatter plot ----
        nav_panel("churn"),
        # Panel with table ----
        nav_panel("peepeepoopoo"),
      )
    )
  )),
  # --- DOLLADA ----
  nav_panel(
    "Dollada",
    icon = icon("calculator"),
    navset_card_underline(
      # Tab Title
      title = "What we learned",
    )
  ),
  # --- GRACIE ----
  nav_panel(
    "Gracie",
    icon = icon("calculator"),
    navset_card_underline(
      # Tab Title
      title = "What we learned",
    )
  ),
)
