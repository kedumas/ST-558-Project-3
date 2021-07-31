# Video Game Sales and Ratings

This shiny app will let users explore a subset of video games with sales in different markets and critic and user ratings. The dataset used was found on [Kaggle](https://www.kaggle.com/rush4ratio/video-game-sales-with-ratings) and reduced from 16,719 observations to 4,622. Only the top 15 game publishers were included in the analysis.

Packages used:
shinydashboard
shinydashboardPlus
DT
plotly
shinycssloaders
shiny
tidyverse
varhandle
ggcorrplot
caret

Easy installation:
```
install.packages(c("shinydashboard",
                   "shinydashboardPlus",
                   "DT",
                   "plotly",
                   "shinycssloaders",
                   "shiny",
                   "tidyverse",
                   "varhandle",
                   "ggcorrplot",
                   "caret"))
```

shiny::runGitHub("ST-558-Project-3", "kedumas", ref = "main")
