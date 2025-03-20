#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#



function(input, output, session) {
  
  # reactive 
  selected_table <- reactive({
    switch(input$tableChoice,
           "cohort_count" = cohort_count,
           "cohort_count_pct" = cohort_count_pct,
           "cohort_cumulative" = cohort_cumulative,
           "cohort_cumulative_pct" = cohort_cumulative_pct
    )
  })
  
  # Render the cohort table
  output$cohortTable <- renderDT({
    table_data <- selected_table()
    
    # Replace NAs in the table
    table_data[] <- lapply(table_data, function(x) {
      if (is.factor(x)) {
        levels(x) <- c(levels(x), "")  # Add empty level for factors
        x[is.na(x)] <- ""  # Replace NAs with empty strings
      } else {
        x[is.na(x)] <- ""  # Replace NAs with empty strings
      }
      return(x)
    })
    
    # Render datatable
    datatable(
      table_data,
      options = list(
        pageLength = 23, 
        autoWidth = TRUE,
        searching = FALSE,
        rowCallback = JS("
          function(row, data) {
            var startCol = 3;  
            var endCol = 24;   
            var rowValues = [];
            
            // Collect values from columns to be colored
            for (var i = startCol; i <= endCol; i++) {
              if (data[i] !== null && data[i] !== '') {
                var val = parseFloat(data[i]);
                if (!isNaN(val)) {
                  rowValues.push({index: i, value: val});
                }
              }
            }

            if (rowValues.length > 0) {
              var minVal = Math.min.apply(null, rowValues.map(function(item) { return item.value; }));
              var maxVal = Math.max.apply(null, rowValues.map(function(item) { return item.value; }));

              // Apply color gradient from red to green
              rowValues.forEach(function(item) {
                if (minVal === maxVal) return; // Skip coloring if all values are the same
                
                var ratio = (item.value - minVal) / (maxVal - minVal);
                var red = Math.round(255 * (1 - ratio));
                var green = Math.round(255 * ratio);
                var color = 'rgb(' + red + ',' + green + ',0)';
                
                $('td:eq(' + item.index + ')', row).css('background-color', color);
              });
            }
          }
        ")
      )
    )
  })
  
  # Dynamic description text
  output$descriptionText <- renderText({
    switch(input$tableChoice,
           "cohort_count" = "This table shows the number of customers from the original cohort in a given month. Each month shows the number of customers out of the original cohort",
           "cohort_count_pct" = "This table shows the number of customers from the original cohort in a given month, represented as a percentage of the original cohort total.",
           "cohort_cumulative" = "This table shows the number of customers that are retained over time. Each month shows the number of customers that ordered in that month or in any subsequent month",
           "cohort_cumulative_pct" = "This table shows the rate of customer retention. A column shows the percentage of customers from the original cohort that ordered in the current or any subsequent month."
    )
  })
  
  # Render plot
  output$customerPlot <- renderPlot({
    
    
    ggplot(unique_customers, aes(x = order_month, y = new_customers)) +
      geom_line(color = "#0073C2FF", size = 1.2) +  
      geom_point(color = "#D55E00", size = 3) +      
      geom_hline(aes(yintercept = simple_average), 
                 color = "orange", 
                 linetype = "dotted", 
                 size = 1) +  
      labs(
        title = "Unique Customers by Month",              
        subtitle = "Tracking customer growth over time",  
        x = " ",                                          
        y = "Unique Customers",                           
        caption = "Data Source: Sales Orders"             
      ) +
      theme_minimal() +                                  
      scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +  
      theme(
        axis.text.x = element_text(angle = 90, hjust = 1),  
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),  
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "italic"),  
        plot.caption = element_text(hjust = 1, size = 10, face = "italic")
        
      )
  })
  
  
  # Render plot
  output$customerPlot_2 <- renderPlot({
  
    simple_avg_2 <- mean(new_groupby_filtered$customer_count, na.rm = TRUE)
    
    ggplot(new_groupby_filtered, aes(x = as.Date(paste0(first_purchase_month, "-01")))) +
      geom_line(aes(y = customer_count), color = "#0073C2FF", size = 1.2, na.rm = TRUE) +      
      geom_point(aes(y = customer_count), color = "#D55E00", size = 3, na.rm = TRUE) +                  
      
      # Simple avg (dotted line)
      geom_hline(aes(yintercept = simple_avg_2), 
                 color = "orange", 
                 linetype = "dotted", 
                 size = 1) + 
      
      labs(
        title = "New Customers by Month",
        subtitle = "Tracking customer growth over time",
        x = " ",
        y = "New Customers",
        caption = "Data Source: Sales Orders"
      ) +
      theme_minimal() +
      scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") + 
      theme(
        axis.text.x = element_text(angle = 90, hjust = 1),
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "italic"),
        plot.caption = element_text(hjust = 1, size = 10, face = "italic")
      )
  
  })
}











































