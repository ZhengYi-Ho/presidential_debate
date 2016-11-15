##################### Get electricity.csv ###########################
iou13 <- read.csv('iou2013.csv', stringsAsFactors = F)
niou13 <- read.csv('niou2013.csv', stringsAsFactors = F)
iou14 <- read.csv('iou2014.csv', stringsAsFactors = F)
niou14 <- read.csv('niou2014.csv', stringsAsFactors = F)
iou15 <- read.csv('iou2015.csv', stringsAsFactors = F)
niou15 <- read.csv('niou2015.csv', stringsAsFactors = F)
df <- rbind(iou13, niou13, iou14, niou14, iou15, niou15)
write.csv(df, 'electricity.csv', row.names = F)

##################### Process utility.csv ###########################

library(choroplethrZip)
library(choroplethrMaps)
library(tidyr)
library(dplyr)

# tidy up the data frame
df$zip <- str_pad(as.character(df$zip), 5, pad = '0')
df.clean <- df %>% gather(type, rate, comm_rate:res_rate) %>% filter(rate != 0)

# Add state.name, county.name, conty.fips.numeric to df by matching 
# zipcodes (region) in zip.regions data frame from choroplethrZip package

data(zip.regions)
zip.regions <- zip.regions[, c('region', 'state.name', 'county.name', 'county.fips.numeric')]
zip.regions <- zip.regions[!duplicated(zip.regions), ] # remove duplicated rows
names(zip.regions)[1] <- 'zip'

df.clean.complete <- merge(df.clean, zip.regions)
write.csv(df.clean.complete, 'electricity_complete.csv', row.names = F)

by.state <- df.clean.complete %>% 
    group_by(state.name, type) %>% summarise(value = round(mean(rate*100), 3))
names(by.state)[1] <- 'region'
saveRDS(by.state, 'byState.RData')

by.county <- df.clean.complete %>%
    group_by(state.name, as.character(county.fips.numeric), type) %>%
    summarise(value = round(mean(rate*100), 3))
names(by.county)[2] <- 'region'
by.county$region <- as.numeric(by.county$region)
data(county.regions)
county.regions <- county.regions[, c('region', "county.name")]
by.county <- merge(by.county, county.regions)
saveRDS(by.county, 'byCounty.RData')

by.county.company <- df.clean.complete %>% 
    group_by(state.name, county.name, type, utility_name) %>% 
    summarise(rate = round(mean(rate*100), 3)) %>% 
    arrange(rate)
saveRDS(by.county.company, 'byCountyCompany.RData')

data(county.regions)
county.regions <- county.regions[, c("county.name", 'state.name', 'state.abb')]
county.regions$climate.zone <- 0
county.regions[, county.regions$state.abb == 'HI']$climate.zone <- 1

