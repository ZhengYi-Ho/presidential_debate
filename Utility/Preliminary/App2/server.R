library(shiny)
library(choroplethr)
library(choroplethrZip)
library(choroplethrMaps)
library(dplyr)
library(ggplot2)
library(ggthemes)

df <- read.csv('ca_county_utility.csv', stringsAsFactors = F)
data("zip.regions")
county.df <- zip.regions[zip.regions$state.name == 'california', 
                         c('county.name', 'county.fips.numeric')]
names(county.df)[2] <- 'region'
county.df$value <- 0
county.df <- county.df[!duplicated(county.df), ]

shinyServer(function(input, output) {
 
    output$plot1 <- renderPlot({
        county.df[county.df$county.name == input$select, ]$value <- 1
        county_choropleth(county.df, state_zoom = 'california', 
                          legend = 'County',
                          num_colors = 2)
    })
    
    output$plot2 <- renderPlot({
        df_subset <- df %>% filter(county.name == input$select, 
                                   type == input$radio) %>% 
            select(utility_name, rate) %>% 
            group_by(utility_name) %>% 
            summarise(avg.rate = mean(rate)) %>%
            arrange(avg.rate)

        ggplot(df_subset, aes(x = utility_name, y = avg.rate)) +
            geom_bar(stat = 'identity', color = 'black', aes(fill = utility_name)) + 
            labs(x = '', y = 'Average Rate (USD/kWh)', 
                 title = 'Average Electricity Rate by Utility Company') +
            theme_economist_white() + 
            theme(axis.title.x=element_blank(),
                  axis.text.x=element_blank(),
                  axis.ticks.x=element_blank()) + 
            theme(legend.title=element_blank()) + 
            theme(legend.position = "bottom") + 
            guides(fill = guide_legend(nrow = 5)) +
            scale_x_discrete(limits = df_subset$utility_name)
    })
    
})