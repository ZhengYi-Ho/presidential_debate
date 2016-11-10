############################# Get Data ##############################

library(twitteR)
key <- 'DWrw5zVwBaqpg5TWxOdn92PXN'
secret <- '17M15cgkKO19O4lFvHsrsY3RL3eGtKpXUlmmRrMrGdMo1JQ28I'
token <- '776271306534768640-ljJ26twWCqvw7isZXAIZLadn3TbKCyj'
token.secret <-	'bRwCc83GSZZ951mhFyn2SLCK8TnYvKqGHCR7cNCUXsNbQ'

setup_twitter_oauth(key, secret, token, token.secret)

# tweets that mentioned presidential election today
election <- searchTwitter('president + election', n = 20000, lang = 'en', since = '2016-11-09')


election.txt <- sapply(election, function(x) x$getText())
election.txt <- iconv(election.txt, "UTF-8", "ASCII", sub="") # remove non-ASCII characters
election.txt <- tolower(election.txt)

# save to .RData for future reference
saveRDS(election.txt, 'election_cleaned.RData')

