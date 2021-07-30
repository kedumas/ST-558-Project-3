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
  
  output$platTable <- renderTable(
    data.frame("Platform Shorthand" = uPlat, 
               "Platform Long Name" = c("Nintendo Wii", "Nintendo DS", "Xbox 360", "Playstation 3", "Playstation 2", "Nintendo 3DS", 
                                      "Playstation 4", "Playstation", "Xbox", "Personal Computer", "Playstation Portable", 
                                      "Nintendo WiiU", "Nintendo GameCube", "Nintendo Gameboy Advance", "Xbox One", "Playstation Vita", 
                                      "Sega Dreamcast"))
  )
  output$rateTable <- renderTable(
    data.frame("Ratings Shorthand" = c("E", "E10+", "T", "M"), 
               "Ratings Descirption" = c("Everyone", "Everyone Aged 10+", "Teens Aged 13+", "Mature Aged 17+"))
  )
  
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
    } else if(input$filtBar %in% games$Publisher) {bGames <- games %>% filter(Publisher == input$filtBar)
    } else bGames <- games %>% filter(Rating == input$filtBar)
    bGames
  })
  
  vGames <- reactive({
    if(input$filtVio == " ") {vGames <- games
    } else if(input$filtVio %in% games$Platform) {vGames <- games %>% filter(Platform == input$filtVio)
    } else if(input$filtVio %in% games$Year_of_Release) {vGames <- games %>% filter(Year_of_Release == input$filtVio) 
    } else if(input$filtVio %in% games$Genre) {vGames <- games %>% filter(Genre == input$filtVio)
    } else if(input$filtVio %in% games$Publisher) {vGames <- games %>% filter(Publisher == input$filtVio)
    } else vGames <- games %>% filter(Rating == input$filtVio)
    vGames
  })
  
  sGames <- reactive({
    if(input$filtSca == " ") {sGames <- games
    } else if(input$filtSca %in% games$Platform) {sGames <- games %>% filter(Platform == input$filtSca)
    } else if(input$filtSca %in% games$Year_of_Release) {sGames <- games %>% filter(Year_of_Release == input$filtSca) 
    } else if(input$filtSca %in% games$Genre) {sGames <- games %>% filter(Genre == input$filtSca)
    } else if(input$filtSca %in% games$Publisher) {sGames <- games %>% filter(Publisher == input$filtSca)
    } else sGames <- games %>% filter(Rating == input$filtSca)
    sGames
  })
  
  # Barplot of a single variable. Looking only at Platform, Year of Release, Genre, and Rating. Publisher and 
  # Developer both have over 100 different levels and would not be good for this type of plot. Default is Platform.
  output$bar <- renderPlot({
    games <- bGames()
    ggplot(games, aes_string(input$facts)) + geom_bar(aes_string(fill = input$facts)) + coord_flip() +
      theme_minimal() + stat_count(aes(label = ..count..), hjust = 1, geom = "text", position = "identity")
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
    input$run, {showNotification("A delay may be experienced while the models are fit depending on variables selected.", 
                                 type = "warning", duration = 5)}
  )
  
  # Dynamic UI for automatically displaying all valid predictor variables based on the response variable selected.
  # Both observe chunks are used, the first for when the user initially changes the response variable and the second
  # for when the user changes back to NA_Sales, the initial value.
  observe({
    # Determine the position of the response name within allVars vector
    newResp <- Position(function(x) x == input$resp, allVars)
    # Update the checkboxes by removing the selected response variable as identified by Position()
    if(input$resp != "Rating"){updateCheckboxGroupInput(session, "pred", choices = allVars[c(-1, -newResp)], selected = allVars[3])}
  })

  observe({
    # Update the checkboxes if the user reselected NA_Sales
    if(input$resp == "Rating"){updateCheckboxGroupInput(session, "pred", choices = allVars[c(-1, -15)], selected = allVars[3])}
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
    #caret::train(form, data = trainData, method = "lm", preProcess = c("center", "scale"), trControl = control())
    caret::train(form, data = trainData, method = "multinom",preProcess = c("center", "scale"), trace = FALSE)
  })
  
  output$mlrModel <- renderPrint({
    summary(mlr())
  })

  output$mlrAcc <- renderPrint({
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
  
  output$classTree <- renderPrint({
    tree()
  })

  output$treeAcc <- renderPrint({
    test <- test()
    resp <- Position(function(x) x == input$resp, allVars)
    testObs <- test[[resp]]
    pred <- predict(tree(), test)
    postResample(pred, obs = testObs)
  })

  # Random Forest Fit
  rForest <- eventReactive(input$run, {
    trainData <- train()
    form <- reformulate(input$pred, input$resp)
    tunegrid <- expand.grid(.mtry = as.numeric(noquote(input$mtryNum)))
    caret::train(form, data = trainData, method = "rf", preProcess = c("center", "scale"), tuneGrid = tunegrid)
  })

  output$randForest <- renderPrint({
    rForest()
  })

  output$rfAcc <- renderPrint({
    test <- test()
    resp <- Position(function(x) x == input$resp, allVars)
    testObs <- test[[resp]]
    pred <- predict(rForest(), test)
    postResample(pred, obs = testObs)
  })
  
  # Prediction
  # Multinomial Logistic Regression
  output$mlrPred <- renderPrint({
    form <- reformulate(input$pred, input$respMLR)
    train <- caret::train(form, data = train(), method = "multinom",preProcess = c("center", "scale"), trace = FALSE)
    pred <- predict(train, test())
    #predict(pred, data.frame(noquote(input$predMLR) = input$predMLRval))
  })
  
  # Classification Tree
  output$classPred <- renderPrint({
    
  })
  
  # Random Forest
  output$rfPred <- renderPrint({
    
  })
  
  # Download Functionality
  # Download the selected data set
  # output$saveData <- downloadHandler(
  #   filename = function() {
  #     paste(VideoGameSalesRatings, ".csv", sep = "")
  #   },
  #   content = function(file) {
  #     write.csv(file, file, row.names = FALSE)
  #   }
  # )
  # 
  # # Download the selected summary or plot
  # plotInput <- reactive({
  #   switch(input$plotSum,
  #          "rock" = rock,
  #          "pressure" = pressure,
  #          "cars" = cars)
  # })
  # 
  # output$savePlot <- downloadHandler(
  # filename = function() {
  #   paste(input$plotSum, ".csv", sep = "")
  # },
  # content = function(file) {
  #   write.csv(plotInput(), file, row.names = FALSE)
  # }
  # )

}
