library(shinydashboard)
library(shinydashboardPlus)
library(DT)
library(plotly)

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
                        p("There are 16 variables with data ranging from game name, to year released, to sales data to ratings.", 
                          "There are 6,947 different observations in this set for games that range the gambit of genres.",
                          "Many publishers and developers have the same name, but not all. For example, Nintendo is both a publisher",
                          "and distributer, but Take-Two Interactive is a publisher for the developer Rockstar North.",
                          "In this example, Nintendo can also be a publisher for other developers such as Game Arts."),
                        img(src = "psvita.png", height = 300, width = 300),
                        p("Image of the Playstation Vita, from", a(href="https://kotaku.com/fans-are-finally-coming-to-terms-with-the-vitas-death-1833298145", "Kotaku.com.")),
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
                        downloadButton("saveData", "Save Current Data Set"),
                        dataTableOutput("allData", width = "1000px")
                    )
            ),
            # Data Exploration page content
            tabItem(tabName = "DataExploration",
                    h2("Data Exploration Fun"),
                    mainPanel(
                        
                        # Action button to save desired plots
                        downloadButton("savePlot", "Download"),
                        
                        # Drop down menu for the desired output
                        selectInput("plotSum", "Select the desired plot or summary", choices = dataInputs),
                        
                        # Summary statistics of the data set
                        conditionalPanel(
                            condition = "input.plotSum == 'Summary Statistics'", 
                            h3("Summary Statistics"),
                            checkboxGroupInput("sumOpts", "Variables for the Summary Statistics", choices = allVars, 
                                               selected = allVars, inline = TRUE),
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
                                                 "Developer" = uDevl, "Rating" = uRatg)),
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
                                                     "Developer" = uDevl, "Rating" = uRatg)), width = 4),
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
                                                     "Developer" = uDevl, "Rating" = uRatg)), width = 4),
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
                                    tabPanel("Modeling Info", textOutput("text"),
                                             h2("Multiple Linear Regression"),
                                             h3("Benefits"),
                                             p("Test words!"),
                                             h3("Drawbacks"),
                                             p("Test words!"),
                                             h2("Regression Tree Model"),
                                             h3("Benefits"),
                                             p("Test words!"),
                                             h3("Drawbacks"),
                                             p("Test words!"),
                                             h2("Random Forest"),
                                             h3("Benefits"),
                                             p("Test words!"),
                                             h3("Drawbacks"),
                                             p("Test words!")
                                             ),
                                    tabPanel("Model Fitting", 
                                             h2(),
                                             fluidRow(column(4, wellPanel(
                                             sliderInput("split", "Percentage of Data for the Training Set", min = 50, 
                                                         max = 85, value = 75, step = 1),
                                             actionButton("run", "Run Models"), 
                                             selectInput("resp", "Response Variable", choices = numVars, selected = numVars[1]),
                                             checkboxGroupInput("pred", "Predictor Variables", choices = allVars[c(2:5, 7:16)], selected = allVars[4]),
                                             selectInput("cv", "Please select a Cross Validation method", choices = 
                                                             c("Cross Validation" = "cv", "Repeated Cross Validation" = "repeatedcv")),
                                             sliderInput("cvNum", "Number of folds", min = 3, max = 20, value = 10, step = 1),
                                             selectInput("cvRep", "Number of repeats", choices = c(1, 2, 3, 4, 5, 6)),
                                             )),
                                             column(8,
                                             h3("Linear Model Fit Statistics"),
                                             verbatimTextOutput("sumModel"),
                                             h3("Linear Model Fit Error on Test Set"),
                                             verbatimTextOutput("mlrRMSE"),
                                             h3("Regression Tree Fit"),
                                             verbatimTextOutput("regTree"),
                                             h3("Regression Tree Fit Error on Test Set"),
                                             verbatimTextOutput("treeRMSE"),
                                             h3("Random Forest Fit"),
                                             verbatimTextOutput("randForest"),
                                             h3("Random Forest Fit Error On Test Set"),
                                             verbatimTextOutput("rfRMSE")
                                             ))
                                    ),
                                    tabPanel("Prediction", 
                                             plotOutput("predict"))
                        )
                    )
            )
        )
    )
))
