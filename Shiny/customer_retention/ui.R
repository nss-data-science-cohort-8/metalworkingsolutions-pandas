#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

#Original App for EDA
ui <- fluidPage(
  titlePanel("Customer Base Changes Over Time"),
  
  br(),
  
  fluidRow(
    column(3, # Sidebar column
           div(
             class = "sidebar-content",
             style = "height: 100%; display: flex; flex-direction: column;",
             
             # Dropdown 
             selectInput("tableChoice", 
                         "Choose a table:",
                         choices = c("cohort_count", "cohort_count_pct", "cohort_cumulative", "cohort_cumulative_pct"),
                         selected = "cohort_count",
                         width = '200px'),
             
             # # Dynamic description
             # tags$div(
             #   style = "border: 1px solid #ccc; padding: 10px; background-color: #f8f8f8;",
             #   textOutput("descriptionText") 
             # ),
             
             # Plot
             h4(""),  
             div(
               style = "flex-grow: 1; border: 2px solid #0073C2; padding: 10px;",  # Adding a border
               plotOutput("customerPlot")
             ),
             
             br(),
             
             # Plot2 
             h4(""),  
             div(
               style = "flex-grow: 1; border: 2px solid #D55E00; padding: 10px;",  # Adding a border
               plotOutput("customerPlot_2")
             )
           )
    ),
    
    column(9, # Main panel column
           # dynamic title
           tags$div(
             style = "font-size: 24px; font-weight: bold; margin-bottom: 10px;",
             textOutput("dynamic_title")  
           ),
           
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
      min-height: calc(100vh - 120px); /* Fuadjust space */
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




















