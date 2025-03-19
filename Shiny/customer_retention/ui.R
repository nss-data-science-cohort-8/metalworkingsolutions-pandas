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
  titlePanel("Customer Change Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      # Dropdown menu for table selection with smaller width
      selectInput("tableChoice", 
                  "Choose a table:",
                  choices = c("cohort_count", "cohort_count_normalized", "cohort_cumulative"),
                  selected = "cohort_count",
                  width = '150px'),
      
      # space between dropdown and description
      tags$br(),
      
      # text box
      tags$div(
        style = "border: 1px solid #ccc; padding: 10px; background-color: #f8f8f8; margin-top: 15px;",
        "This is a test text box with some information that cannot be edited."
      ),
      
      # sidebar panel width
      width = 3
    ),
    
    mainPanel(
      # title - table
      h3("Customer Retention Table"),
      
      # render table
      DTOutput("cohortTable")
    )
  ),
  
  # css to style table
  tags$style(HTML("
    #cohortTable {
      width: 100%;  /* Make the table take up the full width */
      /* Removed height and overflow properties */
    }
    
    .selectize-input {
      width: 200px !important;  /* Set the width of the dropdown */
    }
  "))
)















