library(tidyverse)
library(dplyr)
library(rvest)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)
library(quanteda.sentiment)
library(seededlda)
library(quanteda.textmodels)




cnn <- read.csv("~/SICSS_2024/projects/abortion laws/cnn_abortion.csv")
head(cnn)


# Tokenization CNN
corpus <- corpus(cnn, text_field = "body")
tokens <- tokens(corpus, what = "word")
dfm <- dfm(tokens)
topfeatures(dfm, 10)


# delete "by, opinion, analysis <- still to do

tokens_pp <- tokens(
  corpus,
  what = "word",
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
)|>
  tokens_tolower() |>
  tokens_wordstem(language = "en") |>
  tokens_remove(stopwords("en"), padding = TRUE)
dfm_pp <- dfm(tokens_pp)

topfeatures(dfm_pp, 10)

#Sentiment Analysis
dict_pol <- data_dictionary_HuLiu

#cnn
dfm_lookup(dfm_pp, dict_pol)
textstat_polarity(dfm_pp, dict_pol)
textstat_valence(dfm_pp, data_dictionary_AFINN)



