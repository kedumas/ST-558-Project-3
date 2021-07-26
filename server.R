library(shiny)
library(tidyverse)
library(DT)
library(corrplot)
library(plotly)

# Static code is in the helper.R file. This includes reading in the initial data set and cleaning and also 
# easily callable subsets of the variables and variable names. See helper.R for more information.
source("helper.R")

function(input, output, session) { 
  
  # Data Page Setup
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
  
  # Data Manipulation Page Setup
  # Filter for plots
  filtBox <- reactive({
    
    
  })
  
  # Summary data of the data set. Summary data shown can be selected by the user. Default is all variable 
  # summaries shown.
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
  
  # Barplot of a single variable. Looking only at Platform, Year of Release, Genre, and Rating. Publisher and 
  # Developer both have over 100 different levels and would not be good for this type of plot. Default is Platform.
  output$bar <- renderPlot({
    barVar <- input$facts

    # Filter the data for the plot
    ggplot(games, aes_string(barVar)) + geom_bar(aes_string(fill = barVar)) + coord_flip() + theme_minimal()
    #if(is.null(input$filterBox)){ggplot(games, aes_string(barVar)) + geom_bar(aes_string(fill = barVar)) + coord_flip() + theme_minimal()
    #  } else games %>% filter(filt == stfiltObs) %>% ggplot( aes_string(barVar)) + geom_bar(aes_string(fill = barVar)) + coord_flip() + theme_minimal()
  })

  # Violin plot looking at the same variables as the barplot compared to all the numeric variables. 
  # Default is Platform by NA_Sales.
  output$violin <- renderPlot({
    xVioVar <- input$xVio
    yVioVar <- input$yVio
    #fVioVar <- input$fVio
    
    # Filter the data for the plot
    ggplot(games, aes_string(xVioVar, yVioVar)) + geom_violin() + coord_flip() + theme_minimal()
  })
  
  # Scatterplot looking at all the numeric variables compared to each other pairwise as the user specifies. 
  # Default is NA_Sales by Critic_Count.
  output$scatter <- renderPlotly({
    # Ggplot for a scatterplot is fit, then converted to plotly for interactivity. The logic behind converting to 
    # plotly after using ggplot is so that the x and y axis labels will appear correctly and keep the interactivity.
    p <- ggplot(games, aes_string(input$xSca, input$ySca, label = c("Name"))) + geom_point() + theme_minimal()
    ggplotly(p, tooltip = c("x", "y", "label"))
      })

  # Model Page Setup  
  # Large factor (over 100 factors!) variable warning
  observeEvent(
    input$run, {showNotification("If Publisher or Developer has been selected, the output will be too long to fit the page.", 
                                 type = "warning", duration = 7)}
  )
  
  # Dynamic UI for automatically displaying all valid predictor variables based on the response variable selected.
  # Both observe chunks are used, the first for when the user initially changes the response variable and the second
  # for when the user changes back to NA_Sales, the initial value.
  observe({
    # Determine the position of the response name within allVars vector 
    newResp <- Position(function(x) x == input$resp, allVars)
    # Update the checkboxes by removing the selected response variable as identified by Position()
    if(input$resp != "NA_Sales"){updateCheckboxGroupInput(session, "pred", choices = allVars[c(-1, -newResp)])}
    })
  observe({
    # Update the checkboxes if the user reselected NA_Sales
    if(input$resp == "NA_Sales"){updateCheckboxGroupInput(session, "pred", choices = allVars[c(-1, -6)])}
  })

  # Download Functionality
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
