library(shiny)

shinyUI(navbarPage(
    (strong("Utility Bill Explorer")), id = "nav", theme = "bootstrap.css",
    
    # tab 1: electricity rate
    tabPanel(strong("Electric Utility Rate"), 
             div(class = "outer", 
                 tags$head(includeCSS("style.css"))),
             
             # sidepanel
             fluidRow(
                 column(3, wellPanel(
                     selectInput("t1.ratetype", h5(strong("Rate Type")), 
                                 choices = list("Commercial" = 'comm_rate', 
                                                "Industrial" = 'ind_rate', 
                                                "Residential" = 'res_rate')),
                     br(),
                     checkboxInput("option1", label = h5(strong("Only Show My State")), F)),
                     conditionalPanel("input.option1", 
                                      selectInput("t1.state", h5(strong("State")), 
                                                  c(structure(tolower(state.name), name = state.name)))),
                     conditionalPanel("input.option1",
                                      checkboxInput("option2", h5(strong("Show Options in My County")), F)),
                     conditionalPanel("input.option2", 
                                      selectInput("t1.county", h5(strong("County")), c("All county"= "")))
                     ),
                 
                 # main panel
                 mainPanel(h3("Average Electric Utility Rate"),
                           fluidRow(column(12, align = 'center', plotOutput("plot1")))))
             ),
    # tab 2: energy use in apartment
    tabPanel(strong("Estimated Energy Usage"), id = "nav", theme = "bootstrap.css",
             div(class = "outer", tags$head(includeCSS("style.css"))),
             
             # sidepanel
             fluidRow(
                 column(3, wellPanel(
                     selectInput("t2.building", h5(strong("Building Type")), 
                                 choices = list('Apartment' = 'apt')),
                     selectInput("t2.state", h5(strong("State")), 
                                 c(structure(tolower(state.name), name = state.name))),
                     selectInput("t2.county", h5(strong("County")), c("All county"= "")),
                     radioButtons("t2.age", label = h5(strong("Apartment Age")), selected = NULL,
                                  choices = list("Pre-1980" = 1, "1980-2004" = 2, "post-2004" = 3)))
                 ),
                 # mainpanel
                 mainPanel(h3("Estimated Electricity Usage by Category"),
                           fluidRow(column(12, align = 'center', plotOutput("plot2")))))),
             
    
    # tab 3: about
    tabPanel((strong("Building Upgrade")),
             fluidRow(
                 column(3, wellPanel(
                     radioButtons("t3.age", label = h5(strong("Building Age")), selected = NULL,
                                  choices = list("Pre-1980" = 1, "1980-2004" = 2, "post-2004" = 3)),
                     numericInput("occupancy", label = h5(strong("Number of People Occupied")), value = 1),
                     checkboxGroupInput("options", label = h5(strong("Upgrade Options")), 
                                        choices = list("Install Air Sealing" = 1,
                                                       "Install Duct Insulation" = 2, "Install Wall Insulation" = 3,
                                                       "Floor/Foundation Insulation" = 4, "Install Attic Insulation" = 5)))
                     ),
                 mainPanel(h3("Annual Utility Cost Savings"),
                           fluidRow(column(12, align = 'center', plotOutput("plot3")))))),
             
    
    tabPanel(strong("About"))

))