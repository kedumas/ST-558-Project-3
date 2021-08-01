library(shiny)
library(tidyverse)
library(DT)
library(varhandle)
library(ggcorrplot)
library(plotly)
library(caret)
library(e1071)
library(randomForest)

function(input, output, session) { 
  
  output$platTable <- renderTable(
    data.frame("Platform" = c("Wii", "WiiU", "DS", "3DS", "GC", "GBA", "XB", "X360", "XOne", "PS", "PS2", "PS3", "PS4", "PSP", "PSV", "PC"), 
               "Description" = c("Nintendo Wii", "Nintendo WiiU", "Nintendo DS", "Nintendo 3DS", "Nintendo GameCube", "Nintendo Gameboy Advance",
                                 "Xbox", "Xbox 360", "Xbox One", "Playstation", "Playstation 2", "Playstation 3", "Playstation 4",
                                  "Playstation Portable", "Playstation Vita", "Personal Computer"))
  )
  output$rateTable <- renderTable(
    data.frame("Ratings" = c("E", "E10+", "T", "M"), 
               "Description" = c("Everyone", "Everyone Aged 10+", "Teens Aged 13+", "Mature Aged 17+"))
  )
  
  # Data Page Setup
  # Subsetting the data for desired output
  filtData <- reactive({
    if(input$dataFilt == " ") {filtData <- games
    } else if(input$dataFilt %in% games$Platform) {filtData <- games %>% filter(Platform == input$dataFilt)
    } else if(input$dataFilt %in% games$Year_of_Release) {filtData <- games %>% filter(Year_of_Release == input$dataFilt)
    } else if(input$dataFilt %in% games$Genre) {filtData <- games %>% filter(Genre == input$dataFilt)
    } else if(input$dataFilt %in% games$Publisher) {filtData <- games %>% filter(Publisher == input$dataFilt)
    } else filtData <- games %>% filter(Rating == input$dataFilt)
    filtData
  })
  
  gameSel <- reactive({
    gameSel <- filtData() %>% select(input$DataSel) 
  })
  
  # Table output for the Data Page. Defaults are 10 observations per page and the table is scrollable.
  output$allData <- renderDataTable(
    gameSel() %>% datatable(rownames = FALSE)
  )
  
  # Download the possibly subsetted data table
  output$saveData <- downloadHandler(
    filename = "VideoGameSalesRatings.csv",
    content = function(file) {
      write.csv(gameSel(), file, row.names = FALSE)
    }
  )
  
  # Data Manipulation Page Setup
  # Summary data of the data set. Summary data shown can be selected by the user. Default is all variable 
  # summaries shown.
  sums <- reactive({
    sumVar <- input$sumOpts
    gamesSum <- games
    gamesSum$Year_of_Release <- unfactor(games$Year_of_Release)
    gamesSum %>% select(all_of(sumVar)) %>% summary()
  })
  
  output$sumData <- renderPrint({
    sums()
  })
  
  # Correlation plot with inputs selected by the user. Default is all variables included.
  corrOut <- reactive({
    ggcorrplot(corGames[input$corOpts,input$corOpts], method = "circle", type = "lower", ggtheme = ggplot2::theme_classic) + 
      ggtitle("Correlation Plot") + theme(plot.title = element_text(hjust = 0.5))
  })
  output$corPlot <- renderPlot(
    corrOut()
  )
  
  # Created filter if else flows to determine filtering for bar, violin and scatterplots.
  bGames <- reactive({
    if(input$filtBar == "No Filter") {bGames <- games
    } else if(input$filtBar %in% games$Platform) {bGames <- games %>% filter(Platform == input$filtBar)
    } else if(input$filtBar %in% games$Year_of_Release) {bGames <- games %>% filter(Year_of_Release == input$filtBar) 
    } else if(input$filtBar %in% games$Genre) {bGames <- games %>% filter(Genre == input$filtBar)
    } else if(input$filtBar %in% games$Publisher) {bGames <- games %>% filter(Publisher == input$filtBar)
    } else bGames <- games %>% filter(Rating == input$filtBar)
    bGames
  })
  
  vGames <- reactive({
    if(input$filtVio == "No Filter") {vGames <- games
    } else if(input$filtVio %in% games$Platform) {vGames <- games %>% filter(Platform == input$filtVio)
    } else if(input$filtVio %in% games$Year_of_Release) {vGames <- games %>% filter(Year_of_Release == input$filtVio) 
    } else if(input$filtVio %in% games$Genre) {vGames <- games %>% filter(Genre == input$filtVio)
    } else if(input$filtVio %in% games$Publisher) {vGames <- games %>% filter(Publisher == input$filtVio)
    } else vGames <- games %>% filter(Rating == input$filtVio)
    vGames
  })
  
  sGames <- reactive({
    if(input$filtSca == "No Filter") {sGames <- games
    } else if(input$filtSca %in% games$Platform) {sGames <- games %>% filter(Platform == input$filtSca)
    } else if(input$filtSca %in% games$Year_of_Release) {sGames <- games %>% filter(Year_of_Release == input$filtSca) 
    } else if(input$filtSca %in% games$Genre) {sGames <- games %>% filter(Genre == input$filtSca)
    } else if(input$filtSca %in% games$Publisher) {sGames <- games %>% filter(Publisher == input$filtSca)
    } else sGames <- games %>% filter(Rating == input$filtSca)
    sGames
  })
  
  # Barplot of a single variable. Looking only at Platform, Year of Release, Genre, and Rating. Default is Platform.
  barTitle <- reactive({
    paste0("Filter selected: ", input$filtBar)
    })
  bar <- reactive({
    games <- bGames()
    ggplot(games, aes_string(input$facts)) + geom_bar(aes_string(fill = input$facts)) + coord_flip() +
      theme_minimal() + stat_count(aes(label = ..count..), hjust = 1, geom = "text", position = "identity") +
      ggtitle(req(barTitle()))
  })
  output$bar <- renderPlot({
    bar()
  })

  # Violin plot looking at the same variables as the barplot compared to all the numeric variables. 
  # Default is Platform by NA_Sales.
  vioTitle <- reactive({
    paste0("Filter selected: ", input$filtVio)
  })
  vioPlot <- reactive({
    games <- vGames()
    ggplot(games, aes_string(x = input$xVio, y = input$yVio, fill = input$xVio)) + geom_violin() + 
      geom_boxplot(width=0.1, fill="white")+ coord_flip() + theme_minimal() + ggtitle(req(vioTitle()))
  })
  
  output$violin <- renderPlot({
     vioPlot()
  })
  
  # Scatterplot looking at all the numeric variables compared to each other pairwise as the user specifies. 
  # Default is NA_Sales by Critic_Count.
  scaTitle <- reactive({
    paste0("Filter selected: ", input$filtSca)
  })
  scatPlot <- reactive({
    games <- sGames()
    # Ggplot for a scatterplot is fit, then converted to plotly for interactivity.
    p <- ggplot(games, aes_string(input$xSca, input$ySca, label = c("Name"))) + geom_point() + theme_minimal() +
      ggtitle(req(scaTitle()))
    ggplotly(p, tooltip = c("x", "y", "label"))
  })
  
  output$scatter <- renderPlotly({
    scatPlot()
  })
  
  # # Download the selected summary or plot
  # Names for the output file
  plotInput <- reactive({
    switch(input$plotSum,
           "Correlation Plot" = "correlationPlot",
           "Barplot" = "barplot",
           "Violin Plot" = "violinPlot",
           "Scatterplot" = "scatterplot"
           )
  })
  
  # Identify the plot to be downloaded
  plotImage <- reactive({
    switch(input$plotSum,
           "Correlation Plot" = corrOut(),
           "Barplot" = bar(),
           "Violin Plot" = vioPlot(),
           "Scatterplot" = scatPlot()
    )
  })

  output$savePlotSum <- downloadHandler(
  filename = function() {
    paste(plotInput(), ".png", sep = "")
  },
  content = function(file) {
    png(file)
    print(plotImage())
    dev.off()
  }
  )

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
    if(input$resp != "Rating"){updateCheckboxGroupInput(session, "pred", choices = allVars[c(-1, -newResp)], selected = allVars[c(3, 4, 11)])}
  })

  observe({
    # Update the checkboxes if the user reselects Rating
    if(input$resp == "Rating"){updateCheckboxGroupInput(session, "pred", choices = allVars[c(-1, -15)], selected = allVars[c(3, 4, 11)])}
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
    caret::train(form, data = trainData, method = "multinom", trace = FALSE, trControl = control())
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

  # Classification Tree
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
  # Determining which model to fit
  # Fitting full model so they're not refit each time a new selection is made
  mlrFull <- reactive({
    caret::train(Rating ~ Platform + Year_of_Release + Genre + Publisher + NA_Sales + EU_Sales + JP_Sales + 
                   Other_Sales + Critic_Score + Critic_Count + User_Score + User_Count, data = train(), 
                 method = "multinom", trace = FALSE)
  })
  treeFull <- reactive({ 
    caret::train(Rating ~ Platform + Year_of_Release + Genre + Publisher + NA_Sales + EU_Sales +
                   JP_Sales + Other_Sales + Critic_Score + Critic_Count + User_Score + User_Count,
                 data = train(), method = "rpart", preProcess = c("center", "scale"))
  })  
  rfFull <- reactive({
    caret::train(Rating ~ Platform + Year_of_Release + Genre + Publisher + NA_Sales + EU_Sales +
                   JP_Sales + Other_Sales + Critic_Score + Critic_Count + User_Score + User_Count,
                 data = train(), method = "rf", preProcess = c("center", "scale"), tuneGrid = expand.grid(.mtry = 3))
  })  
  
  # if else flow to determine which model to use in the prediction
  trainData <- eventReactive(input$predButton, {
    if(input$modPref == "Model Fitting Tab" && input$predMod == "Multinomial Logistic Regression"){
        trainData <- mlr()
    } else if(input$modPref == "Model Fitting Tab" && input$predMod == "Classification Tree"){
      trainData <- tree()
    } else if(input$modPref == "Model Fitting Tab" && input$predMod == "Random Forest"){
      trainData <- rForest()
    } else if(input$modPref == "Full Model" && input$predMod == "Multinomial Logistic Regression"){
        trainData <- mlrFull()
    } else if(input$modPref == "Full Model" && input$predMod == "Classification Tree"){
        trainData <- treeFull()
    } else trainData <- rfFull()
    
    trainData
  })
  
  # Adding message for Random Forest Time
  observeEvent(
    input$predButton, 
    if(input$modPref == "Full Model" && input$predMod == "Random Forest"){
      {showNotification("Fitting and predicting with Random Forest may take up to 5 minutes. Please have patience.",
                        type = "warning", duration = 5)}
    }
  )

  # Predicting Multinomial Logistic Regression
  output$mlrPred <- renderPrint({
    predict(trainData(), data.frame(Platform = input$plat, Year_of_Release = input$year, Genre = input$genre, Publisher = input$publ,
                                    NA_Sales = noquote(input$naSal), EU_Sales = noquote(input$euSal), JP_Sales = noquote(input$jpSal),
                                    Other_Sales = noquote(input$otSal), Critic_Score = noquote(input$critS),
                                    Critic_Count = noquote(input$critC), User_Score = noquote(input$useS),
                                    User_Count = noquote(input$useC)
                                    )
    )
  })

  # Predicting Classification Tree
  output$classPred <- renderPrint({
    predict(trainData(), data.frame(Platform = input$plat, Year_of_Release = input$year, Genre = input$genre, Publisher = input$publ,
                                    NA_Sales = noquote(input$naSal), EU_Sales = noquote(input$euSal), JP_Sales = noquote(input$jpSal),
                                    Other_Sales = noquote(input$otSal), Critic_Score = noquote(input$critS),
                                    Critic_Count = noquote(input$critC), User_Score = noquote(input$useS),
                                    User_Count = noquote(input$useC)
                                    )
    )
  })

  # Predicting Random Forest
  output$rfPred <- renderPrint({
    predict(trainData(), data.frame(Platform = input$plat, Year_of_Release = input$year, Genre = input$genre, Publisher = input$publ,
                                    NA_Sales = noquote(input$naSal), EU_Sales = noquote(input$euSal), JP_Sales = noquote(input$jpSal),
                                    Other_Sales = noquote(input$otSal), Critic_Score = noquote(input$critS),
                                    Critic_Count = noquote(input$critC), User_Score = noquote(input$useS),
                                    User_Count = noquote(input$useC)
                                    )
    )
  })
}
