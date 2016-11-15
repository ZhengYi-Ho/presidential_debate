library(shiny)

shinyUI(fluidPage(
    theme = "bootstrap.css",
    titlePanel("California Electricity Rate Explorer"),
    hr(),
    
    sidebarLayout(
        wellPanel( 
            tags$style(type ="text/css", '#leftPanel { width:250px; float:left;}'),
            id = "leftPanel",
            selectInput("select", label = h3("County"), 
                        choices = list("Los Angeles" = 'los angeles', 
                                       "San Diego" = 'san diego', 
                                       "Orange" = 'orange',
                                       'Riverside' = 'riverside',
                                       'San Bernardino' = 'san bernardino',
                                       'Santa Clara' = 'santa clara',
                                       'Alameda' = 'alameda',
                                       'Sacramento' = 'sacramento',
                                       'Contra Costa' = 'contra costa',
                                       'Fresno' = 'fresno')),
            hr(),
            radioButtons("radio", label = h3("Utility Type"),
                         choices = list("Commercial" = 'comm_rate', 
                                        "Industrial" = 'ind_rate', 
                                        "Residential" = 'res_rate')),
            br(),
            p(' \n'),
            p("This app allows you to explore the electricity rate in 10 major counties in California. Just specify the county and utility rate type. The average utility rate (2013 - 2015) offered by utility companies in the county will be displayed.")),
        
        mainPanel(
            
            fluidRow(
                splitLayout(cellWidths = c("35%", "65%"), 
                            plotOutput("plot1"), 
                            plotOutput("plot2", height = '500px')))
            
        ))
))
    