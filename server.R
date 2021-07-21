library(shiny)
library(tidyverse)
library(DT)

# Static code is in the helper.R file
source("helper.R")

function(input, output) { 
  output$data <- renderDataTable(
    games
  )

    }
