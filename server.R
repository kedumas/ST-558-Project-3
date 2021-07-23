library(shiny)
library(tidyverse)
library(DT)
library(corrplot)

# Static code is in the helper.R file
source("helper.R")

function(input, output, session) { 
  
  # Table output for the Data Page. Defaults are 10 observations per page and the table is scrollable.
  output$allData <- renderDataTable(
    games, 
    options = list(
      pageLength = 10,
      scrollX = TRUE,
      scrollY = "500px",
      ordering = TRUE
      )
  )
  
  # Summary data of the data set
  output$sumData <- renderPrint({
    sumVar <- input$sumOpts
    games %>% select(sumVar) %>% summary()
  })
  
  # Correlation plot with inputs selected byt he user. Default is all variables included.
  output$corPlot <- renderPlot(
    corrplot(corGames[input$corOpts,input$corOpts], type = "lower", tl.srt = 45)
  )
  
  
  # Barplot of a single variable
  output$bar <- renderPlot({
    barVar <- input$facts
    #if is.null(input$ ) {games %>% filter()} else 
    ggplot(games, aes_string(barVar)) + geom_bar(aes_string(fill = barVar)) + coord_flip() + theme_minimal()
  })
  
  # Download the selected data set
  #output$saveData <- downloadHandler(
  #  filename = "VG_Sales_22Dec2016.csv",
  #  content = function(file) {
  #    vroom::vroom_write(, file)
  #  }
  #)

}
