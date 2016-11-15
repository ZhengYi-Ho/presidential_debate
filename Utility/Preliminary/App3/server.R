library(shiny)
library(choroplethr)
library(choroplethrZip)
library(dplyr)
library(ggplot2)
library(ggthemes)

by.state <- readRDS('byState.RData')
by.county <- readRDS('byCounty.RData')
by.county.company <- readRDS('byCountyCompany.RData')

apt <- readRDS('apt.RData')
zone <- readRDS('climate.RData')

shinyServer(function(input, output, session) {
    
    # for tab1
    # show county options
    observe({
        t1.county <- by.county %>% filter(state.name == input$t1.state) %>%
                `$`('county.name') %>% unique() %>% sort()
        stillSelected <- isolate(input$t1.county[input$t1.county %in% t1.county])
        
        updateSelectInput(session, "t1.county", choices = t1.county,
                          selected = stillSelected)
    })
    
    # plot1
    output$plot1 <- renderPlot({
        if (input$option1 == F) {
        state_choropleth(by.state[by.state$type == input$t1.ratetype, ][, c('region', 'value')], 
                         legend = "Rate (cent/kWh)")
        } else if (input$option2 == 0|input$t1.county == "") {
            county_choropleth(by.county[by.county$type == input$t1.ratetype, ][, c('region', 'value')],
                           state_zoom = input$t1.state,
                           legend = "Rate (cent/kWh)",
                           title = toupper(input$t1.state))
            } else {
                county.company <- by.county.company %>% filter(county.name == input$t1.county, 
                                           type == input$t1.ratetype) %>% 
                    arrange(rate)
                if (nrow(county.company) > 10) county.company <- county.company[1:10, ]
                ggplot(county.company, aes(x = utility_name, y = rate)) +
                    geom_bar(stat = 'identity', color = 'black', aes(fill = utility_name)) + 
                    labs(x = '', y = 'Rate (cent/kWh)',title = toupper(input$t1.county)) +
                    theme_economist_white() + 
                    theme(axis.title.x=element_blank(),
                          axis.text.x=element_blank(),
                          axis.ticks.x=element_blank()) + 
                    theme(legend.title= element_blank()) + 
                    theme(legend.position = "bottom") + 
                    guides(fill = guide_legend(nrow = 5)) +
                    scale_x_discrete(limits = county.company$utility_name)

                }
            })
    
    # for tab2
    # show county options
    observe({
        t2.county <- by.county %>% filter(state.name == input$t2.state) %>%
            `$`('county.name') %>% unique() %>% sort()
        stillSelected <- isolate(input$county[input$t2.county %in% t2.county])
        
        updateSelectInput(session, "t2.county", choices = t2.county,
                          selected = stillSelected)
    })
    # plot2
    output$plot2 <- renderPlot({
        if (input$t2.state != '' & input$t2.county != '') {
        climate.zone <- zone[zone$state.name == input$t2.state & zone$county.name == input$t2.county, 
                             ]$climate.zone
            if (length(climate.zone) == 0) {
                par(mar = c(0,0,0,0))
                plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
                text(x = 0.5, y = 0.5, c(paste("Currently not available.", "\n", "Check back later.")),
                     cex = 3, col = "orange") 
                
            } else {
                apt <- apt %>% filter(year == input$t2.age, zone == climate.zone, usage > 5 ) %>% arrange(desc(usage))
                ggplot(apt, aes(x = type, y = usage/3.6)) +
                    geom_bar(stat = 'identity', color = 'black', aes(fill = type)) + 
                    labs(x = '', y = "Estimated Usage (KWh/square meter)", 
                         title = paste("Total Estimated Electricity Usage:", round(apt$total/3.6, 3), "KWh/square meter")) +
                    theme_economist_white() + 
                    theme(axis.title.x=element_blank(),
                          axis.text.x=element_blank(),
                          axis.ticks.x=element_blank()) + 
                    theme(legend.title= element_blank()) + 
                    theme(legend.position = "bottom") + 
                    guides(fill = guide_legend(nrow = 5)) +
                    scale_x_discrete(limits = apt$type)
            }
        }
        })

})
