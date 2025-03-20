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
           "cohort_count_normalized" = cohort_count_normalized,
           "cohort_cumulative" = cohort_cumulative,
           "cohort_cumulative_normalized" = cohort_cumulative_normalized
    )
  })
  
  # render table
  output$cohortTable <- renderDT({
    table_data <- selected_table()
    
    # replace all nas
    table_data[] <- lapply(table_data, function(x) {
      if (is.factor(x)) {
        levels(x) <- c(levels(x), "")  # add empty level for factors
        x[is.na(x)] <- ""  # replace nas
      } else {
        x[is.na(x)] <- ""  # replace nas
      }
      return(x)
    })
    
    # render the dt
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
            
            // Collect the values from columns to be colored
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
                if (minVal === maxVal) return; // Skip coloring if values are all the same
                
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
  
  # dynamic text
  output$descriptionText <- renderText({
    switch(input$tableChoice,
           "cohort_count" = "This table shows the cohort count, representing the number of unique customers per cohort for each month.",
           "cohort_count_normalized" = "This table shows the normalized cohort count, representing the proportion of customers retained over time per cohort.",
           "cohort_cumulative" = "This table displays the cumulative count.",
           "cohort_cumulative_normalized" = "This table displays the cumulative count normalized."
           
    )
  })
}










































