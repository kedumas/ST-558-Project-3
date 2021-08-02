library(shinydashboard)
library(shinydashboardPlus)
library(DT)
library(plotly)
library(shinycssloaders)

# Static code is in the helper.R file. This includes reading in the initial data set and cleaning and also 
# easily callable subsets of the variables and variable names. See helper.R for more information.
source("helper.R")

fluidPage(dashboardPage(
    skin = "red",
    dashboardHeader(title = "Video Game Trends"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("About", tabName = "About", icon = icon("question")),
            menuItem("Data", tabName = "Data", icon = icon("th")),
            menuItem("Data Exploration", tabName = "DataExploration", icon = icon("binoculars")),
            menuItem("Modeling", tabName = "Modeling", icon = icon("chart-area"))
        )
    ),
    dashboardBody(
        tabItems(
            
            # About page content
            tabItem(tabName = "About",
                    h2("About Page"),
                    mainPanel(
                        h3("About this App"),
                        p("This app will allow users to explore the sales and ratings data for different video games. The ratings are from Metacritic and the sales data is from vgchartz.",
                          "The goal is to see if there are any trends or correlations between ratings, sales and publisher/developer and platform."),
                        br(),
                        h3("About the Data"),
                        h4("This video game data set was taken from", 
                           a(href="https://www.kaggle.com/rush4ratio/video-game-sales-with-ratings", "Kaggle"),
                           "and is called ", em("Video Game Sales with Ratings")),
                        img(src = "psvita.png", height = 300, width = 300),
                        p("Image of the Playstation Vita, from", a(href="https://kotaku.com/fans-are-finally-coming-to-terms-with-the-vitas-death-1833298145", "Kotaku.com.")),
                        p("There are 16 variables in this dataset: Name, Platform, Year of Release, Genre, Publisher, North American Sales (NA_Sales), European Sales (EU_Sales),",
                          "Japanese Sales (JP_Sales), Rest of World Sales (Other_Sales), Global Sales, Critic Score, Critic Count, User Score, User Count, and Rating.",
                          "All sales data is in millions of dollars and Global sales is the sum of all the rest of the sales data, critic scores are 1-100 while user scores are 1.0-10.0.",
                          "The user and critic counts are the number of scores given. The original dataset contained 16,719 observations. This number has been reduced by removing", 
                          "observations that fall into categories with less than 10 observations total. Further, only the top 15 game publishers are included in this dataset. Through this", 
                          "reduction there are now 4,622 different observations in this set for games that range the gambit of genres. Two tables below show", 
                          "the short hand and long form of the variables Platform, which is the hardware the game was designed to run on, and the game's Rating."),
                        tableOutput("platTable"),
                        tableOutput("rateTable"),
                        br(),
                        h3("About the Other Pages"),
                        h4("Data"),
                        p("This page allows the user to look through and filter or subset the data as desired.", 
                          "It also allows the user to download a .csv of either the full dataset or the filtered/subsetted data that they chose.",
                          "The full original dataset from Kaggle is also available in the GitHub repo for this shiny app."),
                        br(),
                        h4("Data Exploration"),
                        p("This page allows for exploratory analysis of the data, including the creation of different plots and summaries.",
                          "The summary statistics and correlation for differenet variables can be obtained. Three other plots are included:",
                          "barplot, violin plot and scatterplot. These plots are able to be filtered and have different variables selected.",
                          "There is also the ability to download the selected plot."),
                        br(),
                        h4("Modeling"),
                        p("The Modeling page has three different tabs: Information, Fitting and Prediction. The Information tab explains the models used, ", 
                          "the Fitting tab allows the user to select different inputs for the models and the Prediction tab will predict the rating of a ",
                          "game based on teh full model and selected user inputs."),
                        br(),
                    )
            ),
            
            # Data page content
            tabItem(tabName = "Data",
                    h2("Data"),
                    mainPanel(
                        selectizeInput("dataFilt", "Filter Table", choices =
                                           list("No Filter" = " ", "Platform" = uPlat, "Year" = uYear, "Genre" = uGenr,
                                                "Publisher" = uPubl,"Rating" = uRatg), multiple = FALSE),
                        selectizeInput("DataSel", "Select Desired Columns", choices = allVars, selected = allVars, multiple = TRUE,
                                       options = list('plugins' = list('remove_button'),
                                                      'create' = TRUE,
                                                      'persist' = FALSE)),
                        downloadButton("saveData", "Save Current Data Set"),
                        dataTableOutput("allData", width = "1000px")
                    )
            ),
            # Data Exploration page content
            tabItem(tabName = "DataExploration",
                    h2("Data Exploration Fun"),
                    mainPanel(
                        
                        # Drop down menu for the desired output
                        selectInput("plotSum", "Select the desired plot or summary", choices = dataInputs),
                        
                        # Action button to save desired plots
                        conditionalPanel(
                            condition = "input.plotSum != 'Summary Statistics' & input.plotSum != 'Scatterplot'",
                            downloadButton("savePlotSum", "Download")
                        ),
                        
                        # Summary statistics of the data set
                        conditionalPanel(
                            condition = "input.plotSum == 'Summary Statistics'", 
                            h3("Summary Statistics"),
                            fluidRow(
                                column(6,
                                       selectizeInput("sumOpts", "Variables for the Summary Statistics", 
                                                      choices = allVars[-c(1, 2, 4, 5, 15)], selected = allVars[-c(1, 2, 4, 5, 15)], multiple = TRUE,
                                                      options = list('plugins' = list('remove_button'),
                                                                     'create' = TRUE,
                                                                     'persist' = FALSE)),
                                ),
                                column(6,
                                       selectInput("pickSum", "Summary", choices = c("Minimum and Maximum", "Quantiles", "Interquartile Range", "Mean and Median"),
                                                   selected = "Minimum and Maximum")
                                )
                            ),
                            verbatimTextOutput("sumData")
                        ),
                        
                        # Check boxes for user input and the corresponding correlation plot
                        conditionalPanel(
                            condition = "input.plotSum == 'Correlation Plot'", 
                            h3("Correlation Plot"), 
                            checkboxGroupInput("corOpts", "Variables for the Correlation Plot", choices = corVars, 
                                               selected = corVars, inline = TRUE),
                            plotOutput("corPlot"),
                            p("**Please note that Global Sales is the sum of all other sales and so it's expected to be highly correlated",
                              "with the other sales data.")
                        ),
                        
                        # Barplot
                        conditionalPanel(
                            condition = "input.plotSum == 'Barplot'",
                            h3("Barplot"),
                            
                            # Options for filtering
                            selectInput("filtBar", "Filter Observations", choices = 
                                            list("No Filter" = "No Filter", "Platform" = uPlat, "Year" = uYear, "Genre" = uGenr, "Publisher" = uPubl,
                                                 "Rating" = uRatg)),
                            selectInput("facts", "Select the Variable of interest for the Barplot", choices = barVars, selected = barVars[2]),
                            plotOutput("bar", width = "100%")
                        ),
                        
                        # Violin Plot
                        conditionalPanel(
                            condition = "input.plotSum == 'Violin Plot'",
                            h3("Violin Plot"),
                            fluidRow(box(
                                # Options for filtering
                                selectInput("filtVio", "Filter Observations", choices = 
                                                list("No Filter" = "No Filter", "Platform" = uPlat, "Year" = uYear, "Genre" = uGenr, "Publisher" = uPubl,
                                                     "Rating" = uRatg)), width = 4),
                                box(selectInput("xVio", "Select the 'X' variable", choices = barVars, selected = barVars[4]), width = 4),
                                box(selectInput("yVio", "Select the 'Y' variable", choices = numVars, selected = numVars[7]), width = 4),
                                box(plotOutput("violin"), width = 12)
                            )
                        ),
                        
                        # Scatterplot
                        conditionalPanel(
                            condition = "input.plotSum == 'Scatterplot'",
                            p("Please use the plotly download button to save a png of the plot."),
                            h3("Scatterplot"),
                            fluidRow(box(
                                # Options for filtering
                                selectInput("filtSca", "Filter Observations", choices = 
                                                list("No Filter" = "No Filter", "Platform" = uPlat, "Year" = uYear, "Genre" = uGenr, "Publisher" = uPubl,
                                                     "Rating" = uRatg)), width = 4),
                                box(selectInput("xSca", "Select the 'X' variable", choices = numVars, selected = numVars[1]), width = 4),
                                box(selectInput("ySca", "Select the 'Y' variable", choices = numVars, selected = numVars[7]), width = 4),
                            ),
                            
                            # Scatterplot output
                            box(plotlyOutput("scatter"), width = 12)
                        )
                        
                    )
            ),
            # Modeling page content
            tabItem(tabName = "Modeling",
                    tags$head(
                        tags$style(
                            HTML(".shiny-notification {
                                 position:fixed;
                                 top: calc(50%);
                                 left: calc(25%);
                                 }"
                            )
                        ),
                    ),
                    h2("Modeling Content"),
                    mainPanel(
                        # Output: Tabset with modeling information, fitting and prediction
                        tabsetPanel(type = "tabs",
                                    tabPanel("Modeling Info", 
                                             br(),
                                             p("This app uses the caret package to fit all models."),
                                             h2("Multiple Linear Regression"),
                                             p("Method in caret: lm"),
                                             h3("Benefits"),
                                             p("Multiple Linear Regression is used for data with a continuous response and two or more predictor variables.", 
                                               "In this app there is only a single response variable.",
                                               "This type of model assumes that there is a linear relationship between the response and predictors."),
                                             h3("Model"),
                                             withMathJax(helpText("$$y_i=\\beta_{0}+\\beta_{1}\ x_{i1}+\\beta_{2}\ x_{i2}+\\cdots+\\beta_{p}\ x_{ip}+\\epsilon_{i}$$")),
                                             withMathJax(helpText("$$i=1,\\cdots,n$$")),
                                             p("Where the response variable:"),
                                             withMathJax(helpText("$$y_i$$")),
                                             p("Coefficients:"),
                                             withMathJax(helpText("$$\\beta_p$$")),
                                             p("Predictor variables:"),
                                             withMathJax(helpText("$$x_{ip}$$")),
                                             p("Error term:"),
                                             withMathJax(helpText("$$\\epsilon_i$$")),
                                             h3("Drawbacks"),
                                             p("Linearity of the relationship between the predictors and response is a needed assumption and real world ", 
                                               "data is doesn't necessarily have this linear relationship. Becasue of this, the model may not be the best ", 
                                               "fit for the data, or may give misleading results."),
                                             h2("Regression Tree Model"),
                                             p("Method in caret: rpart"),
                                             h3("Benefits"),
                                             p("With tree based models, there is no assumption of linearity or other relationships. This allows for a ",
                                               "wider application on different sets of data. Further, the interpretability is high with easy to ",
                                               "understand graphics associated with these models."),
                                             h3("Determining Split"),
                                             p("The way that decision trees are able to regress or classify is by splitting the predictor space. The following ", 
                                               "equation is the way they do this:"),
                                             withMathJax(helpText("$$\\sum_{j=1}^J\ \\sum_{i\\in{R_j}}\ (y_i - \\hat{y}_{R_j})^2$$")),
                                             h3("Drawbacks"),
                                             p("The tree models are greedy. This means that the model will make the best split at that moment, and not consider a worse split",
                                               "now to have an even better outcome further down the line. This can keep the tree from giving the best model.",
                                               "Trees like this are very vulnerable to the split of data. Here, the random seed is 13 and all splits use",
                                               "this seed. This reduces variablility between the data splits for building the tree. It may also be a lot",
                                               "easier to overfit, this is where pruning comes into play."),
                                             h2("Random Forest"),
                                             p("Method in caret: ranger"),
                                             h3("Benefits"),
                                             p("Random forest is a type of bootstrap aggregated tree model. Many, many trees are fit then aggregated. These trees will have a much lower ",
                                               "correlation to one another because of how the splits are produced. Only m predictors are used per split."),
                                             h3("m Predictors"),
                                             p("To use random forest, the total number of predictors, p, is reduced to the number of candidate predictors per split, m. The method known as 'Bagging'", 
                                               "is a special case in that m equals the total number of p predictors. Below we can see the rule of thumb for m when doing regression with random forest."),
                                             withMathJax(helpText("$$m \\approx\ \\frac{p}{3} $$")),
                                             h3("Drawbacks"),
                                             p("The biggest drawback of any aggregated tree method is the loss interpretability that the single regression or classification tree possesses.")
                                             ),
                                    tabPanel("Model Fitting", 
                                             h2(),
                                             fluidRow(column(4, 
                                                             wellPanel(
                                                                 sliderInput("split", "Percentage of Data for the Training Set", min = 50, 
                                                                             max = 85, value = 75, step = 1),
                                                                 actionButton("run", "Run Models"),
                                                                 selectInput("resp", "Response Variable", choices = numVars[-2], selected = numVars[1]),
                                                                 checkboxGroupInput("pred", "Predictor Variables", choices = allVars[c(2:5, 7:15)], 
                                                                                    selected = allVars[c(3, 4, 11)]),
                                                                 selectInput("cv", "Please Select a Cross Validation Method", choices = 
                                                                                 c("Cross Validation" = "cv", "Repeated Cross Validation" = "repeatedcv")),
                                                                 sliderInput("cvNum", "Number of Folds", min = 3, max = 20, value = 10, step = 1),
                                                                 selectInput("cvRep", "Number of Repeats for Repeated CV", choices = c(2, 3, 4, 5, 6)),
                                                                 p("Random Forest Tuning"),
                                                                 selectizeInput("mtryNum", "Number of Variables to Try", choices = 2:67, selected = 7, multiple = TRUE,
                                                                                options = list('plugins' = list('remove_button'),
                                                                                               'create' = TRUE,
                                                                                               'persist' = FALSE)),
                                                                 selectizeInput("sRule", "SplitRule", choices = c("variance", "extratrees"), selected = "variance", multiple = TRUE,
                                                                                options = list('plugins' = list('remove_button'),
                                                                                               'create' = TRUE,
                                                                                               'persist' = FALSE)),
                                                                 selectizeInput("minNode", "Minimum Node Size", choices = c(4, 5, 6), selected = 5, multiple = TRUE,
                                                                                options = list('plugins' = list('remove_button'),
                                                                                               'create' = TRUE,
                                                                                               'persist' = FALSE))
                                                                 )
                                                             ),
                                                      column(8,
                                                             h3("Multiple Linear Regression Model Fit Summary"),
                                                             verbatimTextOutput("mlrModel"),
                                                             h3("Multiple Linear Regression Model Fit Error on Test Set"),
                                                             verbatimTextOutput("mlrErr"),
                                                             h3("Regression Tree Fit Summary"),
                                                             verbatimTextOutput("regTree"),
                                                             h3("Regression Tree Fit Error on Test Set"),
                                                             verbatimTextOutput("treeErr"),
                                                             h3("Random Forest Fit Summary"),
                                                             verbatimTextOutput("randForest"),
                                                             h3("Random Forest Fit Error On Test Set"),
                                                             withSpinner(verbatimTextOutput("rfErr"))
                                                             )
                                             )
                                    ),
                                    tabPanel("Prediction", 
                                             h3("Prediction for Video Game"),
                                             p("To predict a response based on the model described in the Model Fitting Tab, please select that in the 'Model' dropdown below,", 
                                               "else the full model will be fit and predicted on. The default tuning caret uses will be used in the full models."),
                                             fluidRow(
                                                 column(3,
                                                        selectInput("predMod", "Prediction Model", choices = c("Multiple Linear Regression", "Regression Tree", "Random Forest"))
                                                 ),
                                                 column(3,
                                                        selectInput("modPref", "Model", choices = c("Model Fitting Tab", "Full Model"), selected = "Full Model")
                                                 ),
                                                 column(3,
                                                        selectInput("regResp", "Response to Predict", choices = numVars[c(-7, -9)], selected = numVars[1])
                                                 ),
                                                 column(3,
                                                        actionButton("predButton", "Predict!")
                                                 )
                                             ),
                                             br(),
                                             p("Use the options below to input various options for prediction."),
                                             fluidRow(
                                                 column(4,
                                                        selectInput("plat", "Platform", choices = uPlat, selected = uPlat[9])
                                                 ),
                                                 column(4,
                                                        selectInput("year", "Year_of_Release", choices = uYear, selected = uYear[1])
                                                 ),
                                                 column(4,
                                                        selectInput("genre", "Genre", choices = uGenr, selected = uGenr[8])
                                                 )

                                             ),
                                             fluidRow(
                                                 column(4,
                                                        selectInput("publ", "Publisher", choices = uPubl, selected = uPubl[8])
                                                 ),
                                                 column(4,
                                                        selectInput("ratg", "Rating", choices = uRatg, selected = uRatg[3])
                                                 ),
                                                 column(4,
                                                        numericInput("critS", "Critic Score", value = 50, min = 0, max = 100, step = 1)
                                                 ),
                                             ),
                                             fluidRow(
                                                 column(3,
                                                        numericInput("critC", "Critic Count", value = max(games$Critic_Count)/2, min = min(games$Critic_Count), 
                                                                     max = max(games$Critic_Count), step = 1)
                                                 ),
                                                 column(3,
                                                        numericInput("useS", "User Score", value = 5, min = 0, max = 10, step = 0.1)
                                                 ),
                                                 column(3,
                                                        numericInput("useC", "User Count", value = 5000, min = min(games$User_Count), max = max(games$User_Count), 
                                                                     step = 1)
                                                 ),
                                                 column(3,
                                                        sliderInput("naSal", "North American Sales", value = max(games$NA_Sales)/2, min = 0, 
                                                                    max = max(games$NA_Sales), step = 0.01)
                                                 )
                                             ),
                                             fluidRow(
                                                 column(3,
                                                        sliderInput("euSal", "European Sales", value = max(games$EU_Sales)/2, min = 0, 
                                                                    max = max(games$EU_Sales), step = 0.01)
                                                 ),
                                                 column(3,
                                                        sliderInput("jpSal", "Japanese Sales", value = max(games$JP_Sales)/2, min = 0, 
                                                                    max = max(games$JP_Sales), step = 0.01)
                                                 ),
                                                 column(3,
                                                        sliderInput("otSal", "Other Sales", value = max(games$Other_Sales)/2, min = 0, 
                                                                    max = max(games$Other_Sales), step = 0.01)
                                                 ),
                                                 column(3,
                                                        sliderInput("glSal", "Global Sales", value = max(games$Global_Sales)/2, min = 0, 
                                                                    max = max(games$Global_Sales), step = 0.01)
                                                 )
                                             ),
                                             
                                             conditionalPanel(
                                                 condition = "input.predMod == 'Multiple Linear Regression'",
                                                 withSpinner(verbatimTextOutput("mlrPred"), 
                                                             proxy.height = "100px")
                                                 
                                             ),
                                             
                                             conditionalPanel(
                                                 condition = "input.predMod == 'Regression Tree'",
                                                 withSpinner(verbatimTextOutput("regPred"), 
                                                             proxy.height = "100px")
                                             ),

                                             conditionalPanel(
                                                 condition = "input.predMod == 'Random Forest'",
                                                 withSpinner(verbatimTextOutput("rfPred"), 
                                                             proxy.height = "100px")
                                             )
                                    )
                        )
                    )
            )
        )
    )
)
)
