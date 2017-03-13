############################# Get Data ##############################

library(twitteR)
key <- 'xxxxxxxxxxxxxxxxxxxxxxxx'
secret <- 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
token <- 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
token.secret <-	'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

setup_twitter_oauth(key, secret, token, token.secret)

# tweets that mentioned presidential election today
election <- searchTwitter('president + election', n = 20000, lang = 'en', since = '2016-11-09')


election.txt <- sapply(election, function(x) x$getText())
election.txt <- iconv(election.txt, "UTF-8", "ASCII", sub="") # remove non-ASCII characters
election.txt <- tolower(election.txt)

# save to .RData for future reference
saveRDS(election.txt, 'election_cleaned.RData')

