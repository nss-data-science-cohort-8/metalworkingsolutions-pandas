fluidPage(
  titlePanel("Customer analysis Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("chart_type", "Select Chart:", 
                  choices = c("Percentage of New and Existing Customers per Month",
                              "Top 10 Ordered Parts by Existing Customers (2023-2024)",
                              "Top 10 Ordered Parts by New Customers (2023-2024)",
                              "Customer-Level Analysis",
                              "Part Types Ordered by One-Time Customers")),
      width = 3
    ),
    
    mainPanel(
      plotOutput("selected_chart", height = "600px"),
      width = 9
    )
  )
)