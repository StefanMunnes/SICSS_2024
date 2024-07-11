library(dplyr)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)
library(tm)


corpus <- corpus(data_news, text_field = "body") 

tokens <- tokens(corpus, what = "word")
dfm <- dfm(tokens)
print(dfm)
topfeatures(dfm,10)

tokens_pp <- tokens(
  corpus,
  what = "word",
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_wordstem(language = "en") |>
  tokens_remove(stopwords("en"), padding = TRUE)

dfm_pp <- dfm(tokens_pp)

topfeatures(dfm_pp, 10)
textstat_frequency(dfm_pp, n = 10)

coll <- textstat_collocations(tokens_pp, size = 10, )

top15coll <- arrange(coll,desc(count))[1:15,]

fcm_pp <- fcm(tokens_pp, context = "window", count = "frequency", window = 3)
topfeatures(fcm_pp,10)
