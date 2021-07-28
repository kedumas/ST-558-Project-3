library(shiny)
library(tidyverse)
library(DT)
library(corrplot)
library(plotly)
library(caret)

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
  
  # Created filter if else flows to determine filtering for bar, violin and scatterplots.
  bGames <- reactive({
    if(input$filtBar == " ") {bGames <- games
    } else if(input$filtBar %in% games$Platform) {bGames <- games %>% filter(Platform == input$filtBar)
    } else if(input$filtBar %in% games$Year_of_Release) {bGames <- games %>% filter(Year_of_Release == input$filtBar) 
    } else if(input$filtBar %in% games$Genre) {bGames <- games %>% filter(Genre == input$filtBar)
    } else if(input$filtBar %in% games$Developer) {bGames <- games %>% filter(Developer == input$filtBar) 
    } else if(input$filtBar %in% games$Publisher) {bGames <- games %>% filter(Publisher == input$filtBar)
    } else bGames <- games %>% filter(Rating == input$filtBar)
    bGames
  })
  
  vGames <- reactive({
    if(input$filtVio == " ") {vGames <- games
    } else if(input$filtVio %in% games$Platform) {vGames <- games %>% filter(Platform == input$filtVio)
    } else if(input$filtVio %in% games$Year_of_Release) {vGames <- games %>% filter(Year_of_Release == input$filtVio) 
    } else if(input$filtVio %in% games$Genre) {vGames <- games %>% filter(Genre == input$filtVio)
    } else if(input$filtVio %in% games$Developer) {vGames <- games %>% filter(Developer == input$filtVio) 
    } else if(input$filtVio %in% games$Publisher) {vGames <- games %>% filter(Publisher == input$filtVio)
    } else vGames <- games %>% filter(Rating == input$filtVio)
    vGames
  })
  
  sGames <- reactive({
    if(input$filtSca == " ") {sGames <- games
    } else if(input$filtSca %in% games$Platform) {sGames <- games %>% filter(Platform == input$filtSca)
    } else if(input$filtSca %in% games$Year_of_Release) {sGames <- games %>% filter(Year_of_Release == input$filtSca) 
    } else if(input$filtSca %in% games$Genre) {sGames <- games %>% filter(Genre == input$filtSca)
    } else if(input$filtSca %in% games$Developer) {sGames <- games %>% filter(Developer == input$filtSca) 
    } else if(input$filtSca %in% games$Publisher) {sGames <- games %>% filter(Publisher == input$filtSca)
    } else sGames <- games %>% filter(Rating == input$filtSca)
    sGames
  })
  
  # Barplot of a single variable. Looking only at Platform, Year of Release, Genre, and Rating. Publisher and 
  # Developer both have over 100 different levels and would not be good for this type of plot. Default is Platform.
  output$bar <- renderPlot({
    games <- bGames()
    ggplot(games, aes_string(input$facts)) + geom_bar(aes_string(fill = input$facts)) + coord_flip() + theme_minimal()
  })

  # Violin plot looking at the same variables as the barplot compared to all the numeric variables. 
  # Default is Platform by NA_Sales.
  output$violin <- renderPlot({
    games <- vGames()
    ggplot(games, aes_string(x = input$xVio, y = input$yVio)) + geom_violin() + coord_flip() + theme_minimal()
  })
  
  # Scatterplot looking at all the numeric variables compared to each other pairwise as the user specifies. 
  # Default is NA_Sales by Critic_Count.
  output$scatter <- renderPlotly({
    games <- sGames()
    # Ggplot for a scatterplot is fit, then converted to plotly for interactivity.
    p <- ggplot(games, aes_string(input$xSca, input$ySca, label = c("Name"))) + geom_point() + theme_minimal()
    ggplotly(p, tooltip = c("x", "y", "label"))
  })

  # Model Page Setup  
  # Large factor (over 100 factors!) variable warning
  observeEvent(
    input$run, {showNotification("If Publisher or Developer has been selected, the output will be exceedingly long. If multiple predictors are selected, a delay may be experienced while the models are fit.", 
                                 type = "warning", duration = 7)}
  )
  
  # Dynamic UI for automatically displaying all valid predictor variables based on the response variable selected.
  # Both observe chunks are used, the first for when the user initially changes the response variable and the second
  # for when the user changes back to NA_Sales, the initial value.
  observe({
    # Determine the position of the response name within allVars vector 
    newResp <- Position(function(x) x == input$resp, allVars)
    # Update the checkboxes by removing the selected response variable as identified by Position()
    if(input$resp != "NA_Sales"){updateCheckboxGroupInput(session, "pred", choices = allVars[c(-1, -newResp)], selected = allVars[4])}
    })
  observe({
    # Update the checkboxes if the user reselected NA_Sales
    if(input$resp == "NA_Sales"){updateCheckboxGroupInput(session, "pred", choices = allVars[c(-1, -6)], selected = allVars[4])}
  })
  trainIndex <- reactive({
    set.seed(13)
    order(sample(nrow(games) * noquote(input$split)/100))
  })
  
  train <- reactive({
    train <- games[trainIndex(),]
  })
  
  test <- reactive({
    test <- games[-trainIndex(),]
  })
  
  control <- reactive({
    if(input$cvRep == "1"){trainControl(method = "cv", number = noquote(input$cvNum))
      } else trainControl(method = "repeatedcv", number = noquote(input$cvNum), repeats = noquote(input$cvRep))
  })
  
  # Multiple Linear Regression
  mlr <- eventReactive(input$run, {
    trainData <- train()
    form <- reformulate(input$pred, input$resp)
    caret::train(form, data = trainData, method = "lm", preProcess = c("center", "scale"), trControl = control())
  })
  
  output$sumModel <- renderPrint({
    summary(mlr())
  })
  
  output$mlrRMSE <- renderPrint({
    test <- test()
    resp <- Position(function(x) x == input$resp, allVars)
    testObs <- test[[resp]]
    pred <- predict(mlr(), test)
    postResample(pred, obs = testObs)
  })
  
  # Regression Tree
  tree <- eventReactive(input$run, {
    trainData <- train()
    form <- reformulate(input$pred, input$resp)
    caret::train(form, data = trainData, method = "rpart", preProcess = c("center", "scale"), trControl = control())
  })
  
  output$regTree <- renderPrint({
    tree()
    # library(rpart.plot)
    # rpart.plot(rpartFit$finalModel)
  })
  output$treeRMSE <- renderPrint({
    test <- test()
    resp <- Position(function(x) x == input$resp, allVars)
    testObs <- test[[resp]]
    pred <- predict(tree(), test)
    postResample(pred, obs = testObs)
  })
  
  # Random Forest Fit
  # rForest <- eventReactive(input$run, {
  #   trainData <- train()
  #   form <- reformulate(input$pred, input$resp)
  #   caret::train(form, data = trainData, method = "rf", preProcess = c("center", "scale"), trControl = control())
  # })
  # 
  # output$randForest <- renderPrint({
  #   rForest()
  # })

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
