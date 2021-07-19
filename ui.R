library(shinydashboard)

dashboardPage(
    skin = "red",
    dashboardHeader(title = "Placeholder"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("About", tabName = "About", icon = icon("question")),
            menuItem("Data", tabName = "Data", icon = icon("th")),
            menuItem("Data Exploration", tabName = "Data Exploration", icon = icon("binoculars")),
            menuItem("Modeling", tabName = "Modeling", icon = icon("chart-area"))
        )
    ),
    dashboardBody(
        tabItems(
            
            # First tab content
            tabItem(tabName = "About",
                    h2("About"),
                    fluidRow(
                        box()
                    )
            ),
            # Second tab content
            tabItem(tabName = "Data",
                    h2("Data"),
                    fluidRow(
                        box()
                    )
            ),
            # Third tab content
            tabItem(tabName = "Data Exploration",
                    h2("Data Exploration Fun"),
                    fluidRow(
                        box()
                    )
            ),
            # Fourth tab content
            tabItem(tabName = "Modeling",
                    h2("Modeling Content"),
                    mainPanel(
                        
                        # Output: Tabset with modeling information, fitting and prediction
                        tabsetPanel(type = "tabs",
                                    tabPanel("Modeling Info", plotOutput("plot")),
                                    tabPanel("Model Fitting", verbatimTextOutput("summary")),
                                    tabPanel("Prediction", tableOutput("table"))
                        )
                    )
            )
        )
    )
)
