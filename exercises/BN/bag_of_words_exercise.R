library(dplyr)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)

#load data
data_fox <- readRDS("data/FOX.Rds")
data_cnn <- readRDS("data/CNN.Rds")

data_news <- bind_rows(
  list("fox" = data_fox, "cnn" = data_cnn),
  .id = "source"
)

set.seed(161)

data_news <- slice_sample(data_news, n = 300)

#create corpus of df
corpus <- corpus(data_news, text_field = "body")

#create tokens object
tokens <- tokens(corpus, what = "word")

#create dfm
dfm <- dfm(tokens)

#show most frequent words in the DFM
topfeatures(dfm, 10)
textstat_frequency(dfm, n = 10)


#removing unnecessary tokens
tokens_pp <- tokens(
  corpus,
  what = "word",
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_seperators = TRUE
) |>
  tokens_tolower() |>
  tokens_wordstem(language = "en") |>
  tokens_remove(stopwords("en"), padding = TRUE)

#inspect pre-processed DFM
dfm_pre_processed <- dfm(tokens_pp)

#object for all collocations
all_collocations <- textstat_collocations(tokens_pp, size = 2)

#object for only top 15 most frequent collocations
top_collocations <- head(all_collocations[order(-all_collocations$count), ], 15)

#create FCM
fcm_pp <- fcm(tokens_pp)
