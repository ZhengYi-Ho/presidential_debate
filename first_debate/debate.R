############################ Packages ##############################
library(TwitteR)
library(ggplot2)
library(ggthemes)
library(gridExtra)
library(plyr)
library(dplyr)
library(stringr)
library(quanteda)
library(wordcloud)

############################# Get Data ##############################

# Twitter scraping
key <- 'xxxxxxxxxxxxxxxxxx'
secret <- 'xxxxxxxxxxxxxxxxxxxxxxxxx'
token <- 'xxxxxxxxxxxxxxxxxxxxxxxxx'
token.secret <-	'xxxxxxxxxxxxxxxxxxxxx'

setup_twitter_oauth(key, secret, token, token.secret)

# tweets that mentioned the two candidates on or after the debate date
clinton <- searchTwitter('hillary + clinton', n = 10000, lang = 'en', since = '2016-09-26')
trump <- searchTwitter('donald + trump', n = 10000, lang = 'en', since = '2016-09-26')

# clinton
clinton.txt <- sapply(clinton, function(x) x$getText())
clinton.txt <- iconv(clinton.txt, "UTF-8", "ASCII", sub="") # remove non-ASCII characters
clinton.txt <- tolower(clinton.txt)
# remove tweets with trump in it
clinton.txt <- clinton.txt[!grepl('donald trump', clinton.txt) & 
                               !grepl('donald', clinton.txt) & 
                               !grepl('trump', clinton.txt)]

# trump
trump.txt <- sapply(trump, function(x) x$getText())
trump.txt <- iconv(trump.txt, "UTF-8", "ASCII", sub="") # remove non-ASCII characters
trump.txt <- tolower(trump.txt)
# remove tweets with clinton in it
trump.txt <- trump.txt[!grepl('hillary clinton', trump.txt) & 
                           !grepl('hillary', trump.txt) & 
                           !grepl('clinton', trump.txt)]

# save to .RData for future reference

# fileConn<-file("clinton_tweet.txt")
# writeLines(clinton.txt, fileConn)
# close(fileConn)
# bad at dealing with ASCII...

saveRDS(clinton.txt, 'clinton_tweet_cleaned.RData')
saveRDS(trump.txt, 'trump_tweet_cleaned.RData')

# merge the tweets
tweet <- c(clinton.txt, trump.txt)
tweet

############################# Sentiment Scores ##############################

score.sentiment <- function(sentences, pos.words, neg.words, .progress = 'none') { 
    
    require(plyr)
    require(stringr)
    
    # use laply to return scores from a vector of sentences
    scores <- laply(sentences, function(sentence, pos.words, neg.words) {
        
        # clean up sentences with R's regex-driven global substitute, gsub():
        sentence <- gsub('[[:punct:]]', '', sentence)
        sentence <- gsub('[[:cntrl:]]', '', sentence)
        sentence <- gsub('\\d+', '', sentence)
        sentence <- gsub('http\\S+\\s*', '', sentence)
        sentence <- gsub('#\\w+ *', '', sentence)
        sentence <- gsub('@\\w+ *', '', sentence)
        
        # split into words
        word.list <- str_split(sentence, '\\s+')
        words <- unlist(word.list)
        
        # compare words to the dictionaries of positive & negative terms
        pos.matches <- match(words, pos.words)
        neg.matches <- match(words, neg.words)
        
        # find non-NA values
        pos.matches <- !is.na(pos.matches)
        neg.matches <- !is.na(neg.matches)
        
        #  Score  =  Number of positive words  -  Number of negative words
        score <- sum(pos.matches) - sum(neg.matches)
        
        return(score)
    }, pos.words, neg.words, .progress = .progress )
    
    scores.df <- data.frame(score = scores, tweet = sentences)
    return(scores.df)
}

pos <- readLines("positive_words.txt")
neg <- readLines("negative_words.txt")

tweet.num <- c(length(clinton.txt), length(trump.txt))

scores <- score.sentiment(tweet, pos, neg, .progress = 'text')
scores$name <- factor(rep(c('Clinton', 'Trump'), tweet.num))

scores$sentiment <- 0
scores$sentiment[scores$score <= -2] <- -1
scores$sentiment[scores$score >= 2] <- 1 

score.max <- scores[scores$score == max(scores$score), ]
score.min <- scores[scores$score == min(scores$score), ]

############################# Score Statistics ##############################

# histogram
ggplot(scores, aes(x = score)) + 
    geom_histogram(fill = 'blue', color = 'black', bins = 15) +
    facet_grid(name ~.) + 
    labs(x = 'Scores', y = 'Count', 
         title = 'Sentiment Scores Histogram Comparison')

# boxplot
ggplot(scores, aes(x = name, y = score)) + 
    geom_boxplot(aes(fill = name)) + 
    labs(x = '', y = 'Sentiment Scores', 
         title = 'Sentiment Scores Boxplot Comparison') +
    theme(legend.title = element_blank())

sentiment.summary <- scores %>% group_by(name, factor(sentiment)) %>% 
    summarise(count = n())

# barplot
ggplot(scores[scores$name == 'Clinton', ], aes(x = factor(sentiment))) + 
  geom_bar(aes(y = (..count..)/sum(..count..), fill = factor(sentiment))) + 
    labs(x = 'Sentiment', y = 'Count', title = 'Clinton') + 
    scale_fill_discrete(name = "Sentiment",
                        breaks = c(-1, 0, 1),
                        labels=c("Negative", "Neutral", "Positive"))

ggplot(scores[scores$name == 'Trump', ], aes(x = factor(sentiment))) + 
  geom_bar(aes(y = (..count..)/sum(..count..), fill = factor(sentiment))) +
    labs(x = 'Sentiment', y = 'Count', title = 'Trump') + 
    scale_fill_discrete(name = "Sentiment",
                        breaks = c(-1, 0, 1),
                        labels=c("Negative", "Neutral", "Positive"))

############################# Word Frequency ##############################

# clean the text
clean <- function(sentences) { 
    require(plyr)
    clean.text <- laply(sentences, function(sentence) {
        sentence <- gsub('http\\S+\\s*', '', sentence)
        sentence <- gsub('#\\w+ *', '', sentence)
        sentence <- gsub('@\\w+ *', '', sentence)
        sentence <- gsub('[[:cntrl:]]', '', sentence)
        sentence <- gsub('[[:punct:]]', '', sentence)
        sentence <- gsub('\\d+', '', sentence)
        sentence <- gsub('rt', '', sentence)
        return(sentence)
    })
    return(clean.text)
}

clinton.txt <- clean(clinton.txt)
trump.txt <- clean(trump.txt)

# construct corpus
clinton.corpus <- corpus(clinton.txt)
trump.corpus <- corpus(trump.txt)

# define stopwords
stop.words <- c(stopwords('english'), 'clinton', 'hillary', 'donald', 'trump',
                'usa', 'us', 'editorial', 'clintons', 'trumps', 'will', 'now', 'just',
                'still', 'can', 'via', 'new', 'says', 'today', 'amp', 'see', 'time', 'ht')

# tokenization and dfm
clinton.token <- tokenize(clinton.corpus, ngrams = 1, verbose = F)
clinton.dfm <- dfm(clinton.token, ignoredFeatures = stop.words)
trump.token <- tokenize(trump.corpus, ngrams = 1, verbose = F)
trump.dfm <- dfm(trump.token, ignoredFeatures = stop.words)

# find top 25 words
clinton.top <- data.frame(word = rownames(as.matrix(topfeatures(clinton.dfm, 25))), 
                          freq = as.matrix(topfeatures(clinton.dfm, 25))[, 1])

trump.top <- data.frame(word = rownames(as.matrix(topfeatures(trump.dfm, 25))), 
                        freq = as.matrix(topfeatures(trump.dfm, 25))[, 1])  

# plot word frequency
ggplot(clinton.top, aes(x = word, y = freq)) + 
    geom_bar(stat = "identity", fill = 'blue') + 
    labs(x = '', y = 'Frequency', title = 'Top 25 Words in Tweets about Clinton') + 
    coord_flip() + scale_x_discrete(limits = clinton.top$word)

ggplot(trump.top, aes(x = word, y = freq)) + 
    geom_bar(stat = "identity", fill = 'blue') + 
    labs(x = '', y = 'Frequency', title = 'Top 25 Words in Tweets about Trump') + 
    coord_flip() + scale_x_discrete(limits = trump.top$word)

# plot word cloud
plot(clinton.dfm, max.words = 50, scale = c(3, .2))
title('Word Cloud from Tweets about Clinton')

plot(trump.dfm, max.words = 50, scale = c(3, .2))
title('Word Cloud from Tweets about Trump')
