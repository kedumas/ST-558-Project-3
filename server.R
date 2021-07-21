library(shiny)
library(tidyverse)
library(DT)
library(corrplot)

# Static code is in the helper.R file
source("helper.R")

function(input, output) { 
  
  # Table output for the Data Page
  output$data <- renderDataTable(
    games
  )
  
  #
  output$corPlot <- renderPlot(
    corrplot(corGames, type = "lower", tl.srt = 45)
  )

    }
