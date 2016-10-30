library(shiny)
library(choroplethr)
library(choroplethrZip)
library(dplyr)
df <- read.csv('utility_processed.csv', stringsAsFactors = F)
rate.state <- df %>% group_by(state.name) %>% 
    summarise(comm = mean(comm_rate), ind = mean(ind_rate), res = mean(res_rate))

shinyServer(function(input, output) {
    output$value <- renderPrint({ input$select })
    output$plot1 <- renderPlot({
        names(rate.state)[1] <- 'region'
        names(rate.state)[as.numeric(input$select)] <- 'value'
        state_choropleth(rate.state[, c('region', 'value')], 
                         num_colors = 5,
                         legend = "Utility Rate ($/kWh)")
    })
    
})


