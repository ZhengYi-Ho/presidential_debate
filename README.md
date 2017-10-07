# Sentiment Analysis of Presidential Debate using Twitter Data 

## Data  

20,000 tweets were queried after the debate using the two candidates’ names (10,000 tweets for each candidate) from Twitter by using the `twitteR` package. An additional filtering step was carried out to remove tweets containing both names just to simplify the assignment of the sentiment scores to each candidate. (7179 tweets were left only mentioning Clinton’s name and 8854 tweets only mentioning Trump’s name.)  

## Analysis  

The sentiment scores were calculated using a **lexicon-based method**. A list of English positive and negative opinion words or sentiment words compiled by them were used. The different between the number of positive words and the number of negative words in each tweet was used to determine the option orientation or the sentiment score of each tweet.  

The tweets were also used to perform a word frequency analysis and to build word clouds.  