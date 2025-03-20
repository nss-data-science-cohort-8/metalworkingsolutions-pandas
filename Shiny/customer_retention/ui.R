#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# UI Code


ui <- fluidPage(
  titlePanel("Customer Base Changes Over Time"),
  
  sidebarLayout(
    sidebarPanel(
      # dropdown 
      selectInput("tableChoice", 
                  "Choose a table:",
                  choices = c("cohort_count", "cohort_count_pct", "cohort_cumulative", "cohort_cumulative_pct"),
                  selected = "cohort_count",
                  width = '200px'),
      
      # add space btw dropdown and description
      tags$br(),
      
      # dynamic text 
      tags$div(
        style = "border: 1px solid #ccc; padding: 10px; background-color: #f8f8f8; margin-top: 15px;",
        textOutput("descriptionText") 
      ),
      
      # plot in sidebar
      tags$br(),
      h4("Customer Growth Plot"),  
      plotOutput("customerPlot", height = "300px"), 
      
      # sidebar width
      width = 4  
    ),
    
    mainPanel(
      # Title for the table section
      h3("Customer Retention Table"),
      
      # Render table
      DTOutput("cohortTable")
    )
  ),
  
  # CSS to style the table
  tags$style(HTML("
    #cohortTable {
      width: 100%;  /* Make the table take up the full width */
    }
    
    .selectize-input {
      width: 200px !important;  /* Set the width of the dropdown */
    }
    
    #customerPlot {
      width: 100%;  /* Make the plot take full width of sidebar */
    }
  "))
)














