library(dplyr)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)

remotes::install_github("quanteda/quanteda.sentiment")

library(quanteda.sentiment)
library(seededlda)
library(quanteda.textmodels)


data_fox <- readRDS("data/FOX.Rds")
data_cnn <- readRDS("data/CNN.Rds")

data_news <- bind_rows(
  list("fox" = data_fox, "cnn" = data_cnn),
  .id = "source"
)

set.seed(161)

data_news <- slice_sample(data_news, n = 300)

corpus <- corpus(data_news, text_field = "body")

tokens <- tokens(corpus, what = "word")

dfm <- dfm(tokens)

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

dfm_pp <- dfm(tokens_pp)

dict_pol <- data_dictionary_geninqposneg

dict_val <- data_dictionary_ANEW

dfm_lookup(dfm_pp, dict_pol)

textstat_polarity(dfm_pp, dict_pol)

textstat_valence(dfm_pp, dict_val)

tmod_Ida <- textmodel_lda(dfm_pp, k = 3)

topics(tmod_Ida)

terms(tmod_Ida)

#training Naive Bayes

