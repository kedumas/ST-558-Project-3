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
    summary(games) %>% kable()
  })
  
  # Correlation plot with inputs selected byt he user. Default is all variables included.
  output$corPlot <- renderPlot(
    corrplot(corGames[input$corOpts,input$corOpts], type = "lower", tl.srt = 45)
  )

    }
