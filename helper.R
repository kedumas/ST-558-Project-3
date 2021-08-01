library(tidyverse)

# Read in the desired data set
games <- read_csv("Video_Games_Sales_as_at_22_Dec_2016.csv")

# Removing the Developer variable from the dataset as there are over 1200 different ones with the vast majority being 
# under 10 observations each, and over 500 having only a single observation
games <- games %>% select(-Developer)

# Not all video games contain the metacritic ratings data. These have been removed to only look at complete entries
games <- na.omit(games)

# Removing observations for games released before or during 1999
games <- games[games$Year_of_Release > 1999,]

# Removing observations for categories with less than 15 observations each
games <- games[games$Rating != "AO",]
games <- games[games$Rating != "RP",]
games <- games[games$Platform != "DC",]

# Removing the N/A values for the release year
games <- games %>% filter(str_detect(Year_of_Release, "2"))
# Collected the unique values for he year of release in order. To be used with the other u_ variables
uYear <- unique(games$Year_of_Release) %>% sort() %>% factor()

# Removing all but the top 15 publishers
obs <- table(games$Publisher)
games <- games[games$Publisher %in% names(obs[obs > 130]),]

# Converted the correct columns to factors
facts <- c("Platform", "Year_of_Release", "Genre", "Publisher", "Rating")
games[facts] <- lapply(games[facts], factor)


# One column was in list form and designated as character data, while it is actually numeric information.
User_Score <- as.numeric(unlist(games["User_Score"]))
games["User_Score"] <- User_Score

# Data for correlation plot
corGames <- games %>% select(where(is.numeric)) %>% cor()

# Different lists of data set variables to use in ui.R
allVars <- colnames(games)
corVars <- colnames(corGames)
numVars <- games %>% select(where(is.numeric)) %>% colnames()
barVars <- games %>% select(where(is.factor), -Publisher) %>% colnames()

# Unique values of selected variables for use in selectInput in ui.R
uPlat <- unique(games$Platform)
uPubl <- unique(games$Publisher)
uGenr <- unique(games$Genre)
uRatg <- unique(games$Rating)

# Types of plots
dataInputs <- c("Summary Statistics", "Correlation Plot", "Barplot", "Violin Plot", "Scatterplot")
