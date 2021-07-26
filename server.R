library(shiny)
library(tidyverse)
library(DT)
library(corrplot)
library(plotly)

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
  
  # Filter for plots
  filtBox <- reactive({
    
    
  })
  
  # Summary data of the data set
  output$sumData <- renderPrint({
    sumVar <- input$sumOpts
    games %>% select(sumVar) %>% summary()
  })
  
  # Correlation plot with inputs selected byt he user. Default is all variables included.
  output$corPlot <- renderPlot(
    corrplot(corGames[input$corOpts,input$corOpts], type = "lower", tl.srt = 45)
  )
  # fGames <- reactive({
  #   games
  # })
  # fGames <- eventReactive(input$actBox1,{
  #  if(!is.null(input$textBox)){filtObs <- input$textBox}
  #  if(!is.null(input$filterBox)){filt <- input$filterBox}
  #  if(!is.null(input$textBox)){fGames <- games %>% filter(filtObs == filt)
  #    } else fGames <- games
  #  fGames
  #  })
  
  # Barplot of a single variable
  output$bar <- renderPlot({
    barVar <- input$facts

    # Filter the data for the plot
    ggplot(games, aes_string(barVar)) + geom_bar(aes_string(fill = barVar)) + coord_flip() + theme_minimal()
    #if(is.null(input$filterBox)){ggplot(games, aes_string(barVar)) + geom_bar(aes_string(fill = barVar)) + coord_flip() + theme_minimal()
    #  } else games %>% filter(filt == stfiltObs) %>% ggplot( aes_string(barVar)) + geom_bar(aes_string(fill = barVar)) + coord_flip() + theme_minimal()
  })
  # bar <- reactive({
  #   barVar <- input$facts
  #   ggplot(games, aes_string(barVar)) + geom_bar(aes_string(fill = barVar)) + coord_flip() + theme_minimal()
  # })
  # 
  # fGames <- eventReactive(input$actBox1,{
  #   if(!is.null(input$textBox)){filtObs <- input$textBox}
  #   if(!is.null(input$filterBox)){filt <- input$filterBox}
  #   if(!is.null(input$textBox){fGames <- games %>% filter(filtObs == filt)
  #     } else fGames <- games
  #   fGames
  # })
  # 
  # output$bar <- renderPlot({
  #   bar()
  # })
  
  # Violin plot 
  output$violin <- renderPlot({
    xVioVar <- input$xVio
    yVioVar <- input$yVio
    #fVioVar <- input$fVio
    
    # Filter the data for the plot
    ggplot(games, aes_string(xVioVar, yVioVar)) + geom_violin() + coord_flip() + theme_minimal()
  })
  
  # Scatterplot
  output$scatter <- renderPlotly({
    p <- ggplot(games, aes_string(input$xSca, input$ySca, label = c("Name"))) + geom_point() + theme_minimal()
    ggplotly(p, tooltip = c("x", "y", "label"))
      })
  
  # Model Setup

  
  # Download the selected data set
  #output$saveData <- downloadHandler(
  #  filename = "VG_Sales_22Dec2016.csv",
  #  content = function(file) {
  #    vroom::vroom_write(, file)
  #  }
  #)
  
  # Download the selected summary or plot
  #output$saveData <- downloadHandler(
  #  filename = paste0(placeholder, ".csv"),
  #  content = function(file) {
  #    vroom::vroom_write(, file)
  #  }
  #)

}
