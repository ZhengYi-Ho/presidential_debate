library(shiny)

shinyUI(fluidPage(
    theme = "bootstrap.css",
    titlePanel("US Electric Utility Rate"),
    hr(),
    
    sidebarLayout(
        sidebarPanel(
            selectInput("select", label = h3("Select Rate Type"), 
                        choices = list("Commercial" = 2, 
                                       "Industrial" = 3, 
                                       "Residential" = 4)),
            hr(),
            p("This app shows the average electric utility rate in the US by states, averaged from 2013 to 2015. You can choose a specific type of electricity rates to display, i.e., residential, commercial or industrial.")),
            
        mainPanel(
            h2("Average US Electric Utility Rate (2013-2015)"), 
            br(),
            
            fluidRow(column(12, align = 'center', 
                            plotOutput("plot1")))
        ))
))