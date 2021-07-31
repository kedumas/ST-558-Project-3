library(shinydashboard)
library(shinydashboardPlus)
library(DT)
library(plotly)
library(shinycssloaders)

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
                          "The goal is to see if there are any trends or correlations between ratings, sales and publisher/Developer and platform."),
                        br(),
                        h3("About the Data"),
                        h4("This video game data set was taken from", 
                           a(href="https://www.kaggle.com/rush4ratio/video-game-sales-with-ratings", "Kaggle"),
                           "and is called ", em("Video Game Sales with Ratings")),
                        img(src = "psvita.png", height = 300, width = 300),
                        p("Image of the Playstation Vita, from", a(href="https://kotaku.com/fans-are-finally-coming-to-terms-with-the-vitas-death-1833298145", "Kotaku.com.")),
                        p("There are 16 variables with data ranging from game name, to year released, to sales data to ratings.", 
                          "There are 6,399 different observations in this set for games that range the gambit of genres.",
                          "Two tables below show the short hand and long form of the variables Platform, which is the hardware the game was ",
                          "designed to run on, and the game's Rating."),
                        tableOutput("platTable"),
                        tableOutput("rateTable"),
                        br(),
                        h3("About the Other Pages"),
                        h4("Data"),
                        p("This page allows the user to look through and filter or subset the data as wanted.", 
                          "It also allows the user to download a .csv of either the full dataset or the filtered/subsetted data that they chose."),
                        br(),
                        h4("Data Exploration"),
                        p("This page allows for exploratory analysis of the data, including the creation of different plots and summaries.", 
                          "There is also the ability to download selected plots."),
                        br(),
                        h4("Modeling"),
                        p("The Modeling page has three different tabs: Information, Fitting and Prediction. The Information tab explains the models used, ", 
                          "the Fitting tab allows the user to select different inputs for the models and the Prediction tab will predict a response."),
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
                        selectizeInput("DataSel", "Select Desired Columns", choices = allVars, selected = allVars, multiple = TRUE),
                        downloadButton("saveData", "Save Current Data Set"),
                        dataTableOutput("allData", width = "1000px")
                    )
            ),
            # Data Exploration page content
            tabItem(tabName = "DataExploration",
                    h2("Data Exploration Fun"),
                    mainPanel(
                        
                        # Action button to save desired plots
                        downloadButton("savePlotSum", "Download"),
                        
                        # Drop down menu for the desired output
                        selectInput("plotSum", "Select the desired plot or summary", choices = dataInputs),
                        
                        # Summary statistics of the data set
                        conditionalPanel(
                            condition = "input.plotSum == 'Summary Statistics'", 
                            h3("Summary Statistics"),
                            checkboxGroupInput("sumOpts", "Variables for the Summary Statistics", choices = allVars[-1], 
                                               selected = allVars[-1], inline = TRUE),
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
                                            list("No Filter" = " ", "Platform" = uPlat, "Year" = uYear, "Genre" = uGenr, "Publisher" = uPubl,
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
                                                list("No Filter" = " ", "Platform" = uPlat, "Year" = uYear, "Genre" = uGenr, "Publisher" = uPubl,
                                                     "Rating" = uRatg)), width = 4),
                                box(selectInput("xVio", "Select the 'X' variable", choices = barVars, selected = barVars[1]), width = 4),
                                box(selectInput("yVio", "Select the 'Y' variable", choices = numVars, selected = numVars[1]), width = 4),
                                box(plotOutput("violin"), width = 12)
                            )
                        ),
                        
                        # Scatterplot
                        conditionalPanel(
                            condition = "input.plotSum == 'Scatterplot'",
                            h3("Scatterplot"),
                            fluidRow(box(
                                # Options for filtering
                                selectInput("filtSca", "Filter Observations", choices = 
                                                list("No Filter" = " ", "Platform" = uPlat, "Year" = uYear, "Genre" = uGenr, "Publisher" = uPubl,
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
                        )
                    ),
                    h2("Modeling Content"),
                    mainPanel(
                        
                        # Output: Tabset with modeling information, fitting and prediction
                        tabsetPanel(type = "tabs",
                                    tabPanel("Modeling Info", 
                                             withMathJax(),
                                             h2("Multinominal Logistic Regression"),
                                             p("We're utilizing the caret package to fit a multinomial logistic regression model."),
                                             h3("Benefits"),
                                             p("Multinomial Logistic Regression in used for data with non-ordered categorical responses.", 
                                               "It is a type of generalized linear model and is an extention to the Logistic Regression model and works when ", 
                                               "there are more than two factor levels.",
                                               ""),
                                             h3("Drawbacks"),
                                             p("Linearity of the relationship between the predictors and response is a needed assumption and real world ", 
                                               "data is doesn't necessarily have this linear relationship. Becasue of this, the model may not be the best ", 
                                               "fit for the data, or may give misleading results."),
                                             h2("Classification Tree Model"),
                                             p("We're utilizing the caret package to fit a classification tree."),
                                             h3("Benefits"),
                                             p("With tree based models, there is no assumption of linearity. This allows for "),
                                             h3("Drawbacks"),
                                             p("Test words!"),
                                             h2("Random Forest"),
                                             p("We are utilizing the caret package to fit a random forest."),
                                             h3("Benefits"),
                                             p("Test words!"),
                                             h3("Drawbacks"),
                                             p("Fitting a Random Forest can be very slow! There are nearly 7000 observations in this dataset ",
                                               "and so we reduce the time to fit the model by letting the user choose a specific number for the mtry tuning parameter." )
                                             ),
                                    tabPanel("Model Fitting", 
                                             h2(),
                                             fluidRow(column(4, 
                                                             wellPanel(
                                                                 sliderInput("split", "Percentage of Data for the Training Set", min = 50, 
                                                                             max = 85, value = 50, step = 1),
                                                                 actionButton("run", "Run Models"),
                                                                 selectInput("resp", "Response Variable", choices = barVars[-2], selected = barVars[4]),
                                                                 checkboxGroupInput("pred", "Predictor Variables", choices = allVars[c(2:14)], 
                                                                                    selected = allVars[3]),
                                                                 selectInput("cv", "Please select a Cross Validation method", choices = 
                                                                                 c("Cross Validation" = "cv", "Repeated Cross Validation" = "repeatedcv")),
                                                                 sliderInput("cvNum", "Number of folds", min = 3, max = 20, value = 10, step = 1),
                                                                 selectInput("cvRep", "Number of repeats", choices = c(1, 2, 3, 4, 5, 6)),
                                                                 selectInput("mtryNum", "Number of variables to try for Random Forest", choices = 1:14, 
                                                                             selected = 3),
                                                                 )
                                                             ),
                                                      column(8,
                                                             h3("Multinomial Logistic Regression Model Fit Statistics"),
                                                             verbatimTextOutput("mlrModel"),
                                                             h3("Multinomial Logistic Regression Model Fit Error on Test Set"),
                                                             verbatimTextOutput("mlrAcc"),
                                                             h3("Classification Tree Fit"),
                                                             verbatimTextOutput("classTree"),
                                                             h3("Classification Tree Fit Error on Test Set"),
                                                             verbatimTextOutput("treeAcc"),
                                                             h3("Random Forest Fit"),
                                                             verbatimTextOutput("randForest"),
                                                             h3("Random Forest Fit Error On Test Set"),
                                                             withSpinner(verbatimTextOutput("rfAcc"))
                                                             )
                                             )
                                    ),
                                    tabPanel("Prediction", 
                                             h3("Prediction for Video Game Rating"),
                                             p("Global Sales is omitted from this as it is the sum of all other sales data and is highly correlated to them."),
                                             selectInput("predMod", "Prediction Model", choices = c("Multinomial Logistic Regression", "Classification Tree", "Random Forest")),
                                             actionButton("predButton", "Predict!"),
                                             br(),
                                             fluidRow(
                                                 column(3,
                                                        selectInput("plat", "Platform", choices = uPlat)
                                                 ),
                                                 column(3,
                                                        selectInput("year", "Year_of_Release", choices = uYear)
                                                 ),
                                                 column(3,
                                                        selectInput("genre", "Genre", choices = uGenr)
                                                 ),
                                                 column(3,
                                                        selectInput("publ", "Publisher", choices = uPubl)
                                                 )
                                             ),
                                             fluidRow(
                                                 column(3,
                                                        sliderInput("critS", "Critic Score", value = 50, min = 0, max = 100, step = 1)
                                                 ),
                                                 column(3,
                                                        numericInput("critC", "Critic Count", value = max(games$Critic_Count)/2, min = min(games$Critic_Count), 
                                                                     max = max(games$Critic_Count), step = 1)
                                                 ),
                                                 column(3,
                                                        sliderInput("useS", "User Score", value = 5, min = 0, 10, step = 0.1)
                                                 ),
                                                 column(3,
                                                        numericInput("useC", "User Count", value = 5000, min = min(games$User_Count), max = max(games$User_Count), 
                                                                     step = 1)
                                                 )
                                             ),
                                             fluidRow(
                                                 column(3,
                                                        sliderInput("naSal", "North American Sales", value = max(games$NA_Sales)/2, min = 0, 
                                                                    max = max(games$NA_Sales), step = 0.01)
                                                 ),
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
                                             ),
                                             
                                             conditionalPanel(
                                                 condition = "input.predMod == 'Multinomial Logistic Regression'",
                                                 withSpinner(verbatimTextOutput("mlrPred"))
                                                 
                                             ),
                                             
                                             conditionalPanel(
                                                 condition = "input.predMod == 'Classification Tree'",
                                                 withSpinner(verbatimTextOutput("classPred"))
                                             ),

                                             conditionalPanel(
                                                 condition = "input.predMod == 'Random Forest'",
                                                 withSpinner(verbatimTextOutput("rfPred"))
                                             )
                                    )
                        )
                    )
            )
        )
    )
)
)
