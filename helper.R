library(tidyverse)
library(knitr)

# Read in the desired data set
games <- read_csv("Video_Games_Sales_as_at_22_Dec_2016.csv")

# Converted the correct columns to factors
facts <- c("Platform", "Year_of_Release", "Genre", "Publisher", "Developer", "Rating")
games[facts] <- lapply(games[facts], factor)

# Not all video games contain the metacritic ratings data. These have been removed to only look at complete entries
games <- na.omit(games)

# One column was in list form and designated as character data, while it is actually numeric information.
User_Score <- as.numeric(unlist(games["User_Score"]))
games["User_Score"] <- User_Score

# Data for correlation plot
corGames <- games %>% select(where(is.numeric), -Global_Sales) %>% cor()

# Different lists of data set variables to use in ui.R
allVars <- colnames(games)
corVars <- colnames(corGames)
numVars <- games %>% select(where(is.numeric)) %>% colnames()
barVars <- games %>% select(where(is.factor), -c(Publisher, Developer)) %>% colnames()
uPlat <- unique(games$Platform)
uYear <- unique(games$Year_of_Release)
uGenr <- unique(games$Genre)
uPubl <- unique(games$Publisher)
uDevl <- unique(games$Developer)
uRatg <- unique(games$Rating)

# Types of plots
dataInputs <- c("Summary Statistics", "Correlation Plot", "Barplot", "Violin Plot", "Scatterplot")
