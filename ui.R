library(shinydashboard)

dashboardPage(
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
                        "The goal is to see if there are any trends or correlations between ratings, sales and publisher and platform."),
                      br(),
                      h3("About the Data"),
                      h4("This video game data set was taken from", 
                         a(href="https://www.kaggle.com/rush4ratio/video-game-sales-with-ratings", "Kaggle"),
                         "and is called ", em("Video Game Sales with Ratings")),
                      p("There are 16 variables with data ranging from game name, to year released, to sales data to ratings.", 
                        "There are 6,947 different observations in this set for games that range the gambit of genres."),
                      p(""),
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
                     
                      # img(src = "my_image.png", height = 72, width = 72)
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
                            plotOutput("corPlot")
                        ),
                        
                        # Barplot
                        conditionalPanel(
                            condition = "input.plotSum == 'Barplot'",
                            h3("Barplot"),
                            
                            # Options for filtering
                            selectInput("filtBox", "Filter Observations", choices = 
                                                list("Platform" = uPlat, "Year" = uYear, "Genre" = uGenr, "Publisher" = uPubl,
                                                     "Developer" = uDevl, "Rating" = uRatg)),
                            selectInput("facts", "Select the Variable of interest for the Barplot", choices = barVars),
                            plotOutput("bar")
                        ),
                        
                        # Violin Plot
                        conditionalPanel(
                            condition = "input.plotSum == 'Violin Plot'",
                            h3("Violin Plot"),
                            fluidRow(box(
                                # Options for filtering
                                selectInput("filtBox", "Filter Observations", choices = 
                                            list("Platform" = uPlat, "Year" = uYear, "Genre" = uGenr, "Publisher" = uPubl,
                                                 "Developer" = uDevl, "Rating" = uRatg)), width = 4),
                                box(selectInput("xVio", "Select the 'X' variable", choices = barVars, selected = barVars[1]), width = 4),
                                box(selectInput("yVio", "Select the 'Y' variable", choices = numVars, selected = numVars[1]), width = 4),
                                #selectInput("fVioVar", "Select the 'X' variable", choices = barVars),
                                box(plotOutput("violin"), width = 12)
                            )
                        ),
                        
                        # Scatterplot
                        conditionalPanel(
                            condition = "input.plotSum == 'Scatterplot'",
                            h3("Scatterplot"),
                            fluidRow(box(
                                # Options for filtering
                                selectInput("filtBox", "Filter Observations", choices = 
                                                list("Platform" = uPlat, "Year" = uYear, "Genre" = uGenr, "Publisher" = uPubl,
                                                     "Developer" = uDevl, "Rating" = uRatg)), width = 4),
                                #checkboxInput("panel", "Panel?"),
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
                    h2("Modeling Content"),
                    mainPanel(
                        
                        # Output: Tabset with modeling information, fitting and prediction
                        tabsetPanel(type = "tabs",
                                    tabPanel("Modeling Info", textOutput("text"),
                                             h2("Title"),
                                             p("Test words!")),
                                    tabPanel("Model Fitting", 
                                             h2(),
                                             fluidRow(box(sliderInput("split", "Percentage of Data for the Training Set", min = 50, 
                                                                      max = 85, value = 75, step = 1),
                                                         selectInput("resp", "Response Variable", choices = barVars, selected = barVars[1]),
                                                         conditionalPanel(
                                                             condition = "input.resp == 'Platform'",
                                                             checkboxGroupInput("pred", "Predictor Variables", choices = allVars[3:16], inline = TRUE)
                                                         ),
                                                         conditionalPanel(
                                                             condition = "input.resp == 'Year_of_Release'",
                                                             checkboxGroupInput("pred", "Predictor Variables", choices = allVars[c(2,4:16)], inline = TRUE)
                                                         ),
                                                         conditionalPanel(
                                                             condition = "input.resp == 'Genre'",
                                                             checkboxGroupInput("pred", "Predictor Variables", choices = allVars[c(2,3,5:16)], inline = TRUE)
                                                         ),
                                                         conditionalPanel(
                                                             condition = "input.resp == 'Rating'",
                                                             checkboxGroupInput("pred", "Predictor Variables", choices = allVars[2:15], inline = TRUE)
                                                         ),
                                             )),
                                             plotOutput("models")),
                                    tabPanel("Prediction", 
                                             plotOutput("predict"))
                        )
                    )
            )
        )
    )
)
