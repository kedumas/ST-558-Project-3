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

