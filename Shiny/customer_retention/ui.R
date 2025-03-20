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
  
  fluidRow(
    column(3, # Sidebar column
           div(
             class = "sidebar-content",
             style = "height: 100%; display: flex; flex-direction: column;",
             
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
               style = "border: 1px solid #ccc; padding: 10px; background-color: #f8f8f8;",
               textOutput("descriptionText") 
             ),
             
             # plot in sidebar
             tags$br(),
             h4("Customer Growth Plot"),  
             div(style = "flex-grow: 1;", plotOutput("customerPlot")),
             
             # plot2 in sidebar
             tags$br(),
             h4("Customer Growth Plot 2"),  
             div(style = "flex-grow: 1;", plotOutput("customerPlot_2"))
           )
    ),
    
    column(9, # Main panel column
           # Title for the table section
           h3("Customer Retention Table"),
           
           # Render table
           div(
             id = "table-container",
             DTOutput("cohortTable")
           )
    )
  ),
  
  # CSS to style the layout
  tags$style(HTML("
    .row {
      display: flex;
      min-height: calc(100vh - 120px); /* Full viewport height minus header space */
    }
    
    .col-sm-3, .col-sm-9 {
      height: 100%;
    }
    
    .sidebar-content {
      height: 100%;
      overflow-y: auto;
    }
    
    #cohortTable {
      width: 100%;
    }
    
    .selectize-input {
      width: 200px !important;
    }
    
    #customerPlot, #customerPlot_2 {
      width: 100%;
    }
  "))
)














