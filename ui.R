library(shinydashboard)

dashboardPage(
    skin = "red",
    dashboardHeader(title = "Placeholder"),
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
                      br(),
                      h3("About the Data"),
                      h4("The Pokemon data set was taken from", 
                         a(href="https://www.kaggle.com/mariotormo/complete-pokemon-dataset-updated-090420", "Kaggle"),
                         "and is called ", em("The Complete Pokemon Dataset")),
                      p("Specifically, the dataset used was version 6 and identified here as Update_04.21"),
                      br(),
                      h3("About the Other Pages"),
                      h4("There are three other pages to explore in this shiny app"),
                      h4("Data"),
                      p("This page allows the user to look through and filter or subset the data as wanted."),
                      p("It also allows the user to download a .csv of either the full dataset or the filtered/subsetted data that they chose.")
                      # img(src = "my_image.png", height = 72, width = 72)
                    )
            ),
            # Data page content
            tabItem(tabName = "Data",
                    h2("Data"),
                    mainPanel(
                        
                    )
            ),
            # Data Exploration page content
            tabItem(tabName = "DataExploration",
                    h2("Data Exploration Fun"),
                    mainPanel(
                        
                    )
            ),
            # Modeling page content
            tabItem(tabName = "Modeling",
                    h2("Modeling Content"),
                    mainPanel(
                        
                        # Output: Tabset with modeling information, fitting and prediction
                        tabsetPanel(type = "tabs",
                                    tabPanel("Modeling Info", textOutput("text")),
                                    tabPanel("Model Fitting", plotOutput("models")),
                                    tabPanel("Prediction", plotOutput("predict"))
                        )
                    )
            )
        )
    )
)
