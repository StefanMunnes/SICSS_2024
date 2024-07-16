library(tidyverse)
library(dplyr)
library(rvest)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)
library(quanteda.sentiment)
library(seededlda)
library(quanteda.textmodels)
library(tidychatmodels)
library(httr2)
library(gender)

#remotes::install_github("lmullen/genderdata")


cnn <- read.csv("~/SICSS_2024/projects/abortion laws/cnn_abortion.csv")
head(cnn)


# Tokenization CNN
corpus <- corpus(cnn, text_field = "body")
tokens <- tokens(corpus, what = "word")
dfm <- dfm(tokens)
topfeatures(dfm, 10)



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



# delete "by, opinion, analysis

cnn$author <- str_replace_all(cnn$authors, c("\\n" = "", 
                                              "by" = "", 
                                              "By" = "", 
                                              "CNN's" = "",
                                              ", CNN" = "", 
                                              "CNN" = "", 
                                              "Opinion" = "", 
                                              "Analysis" = "",
                                              "Associated Press" = "",
                                              "AP" = "",
                                              "staff" = "",
                                              "Dr." = "",
                                              " and " = ";",
                                              " & " = ";"
                                              ))
cnn$author <- str_replace_all(cnn$author, c("^\\s" = "",
                                              "\\t" = "",
                                              "$\\s" = ""
                                              ))
cnn_byauthor <- cnn %>%
  separate_rows(author, sep = ";")%>%
  separate_rows(author, sep = ",")%>%
  mutate(author = str_trim(author)) %>%
  distinct(url, author, .keep_all = TRUE) %>%
  filter(str_detect(author, "[a-zA-Z]")) %>%
  mutate(first_name = word(author, 1)) %>%
  mutate(name = first_name)



# lookup gender

# via gender package
gendered <- cnn_byauthor %>% 
  rowwise() %>% 
  do(results = gender(cnn_byauthor$first_name, method = "ssa")) %>% 
  do(bind_rows(.$results))


cnn_gender <- left_join(cnn_byauthor, gendered)


cnn_gender$year_min = NULL 
cnn_gender$year_max = NULL

cnn_gender <- distinct(cnn_gender)

?dfm_lookup

lookup_result <- dfm_lookup(dfm_pp, dict_pol)

lookup_df <- convert(lookup_result, to = "data.frame")



# Via Ollama

#cnn_byauthor$gender <- NA
#  chat_ollama <- create_chat(
#    vendor = 'ollama'
#    ) %>%
#    add_model('llama3') %>%
#    add_message(
#      role = 'system',
#      message = 'give me the gender of the Name in the form "male" or "female" in one word'
#      ) %>%
#    add_message(
#      role = 'User',
#      message = "Maria"
#      ) %>%
#    perform_chat()
#  msgs <- chat_ollama %>% extract_chat(silent = TRUE)
#  msgs$message[3] |> cat()
  
#for (i in 1:nrow(cnn_byauthor)) {
#  tmp <- cnn_byauthor$author[i]
#  cnn_byauthor$gender[i] <- gender_response(tmp)
#}