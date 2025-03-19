#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# UI Code


# Define the UI
ui <- fluidPage(
  titlePanel("Customer Change Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      # Dropdown menu for table selection with smaller width
      selectInput("tableChoice", 
                  "Choose a table:",
                  choices = c("cohort_count", "cohort_count_normalized", "cohort_revenue"),
                  selected = "cohort_count",
                  width = '100px'),  # Set the width of the dropdown
      
      # Adds a line break for space between dropdown and description
      tags$br(),
      
      # Separate div for description text output, ensuring it’s a separate block below the dropdown
      div(
        style = "margin-top: 20px;",  # Controls the space between the dropdown and description
        textOutput("descriptionText")
      )
    ),
    
    mainPanel(
      # Title for the table
      h3("Customer Retention Table"),  # Table title
      
      # Render the table with increased size
      DTOutput("cohortTable")
    )
  ),
  
  # Custom CSS for styling the table and the dropdown
  tags$style(HTML("
    #cohortTable {
      width: 100%;  /* Make the table take up the full width */
      height: 600px;  /* Set a fixed height for the table */
      overflow-y: scroll;  /* Allow scrolling if the table is too large */
    }
    
    .selectize-input {
      width: 200px !important;  /* Set the width of the dropdown */
    }
  "))
)
















