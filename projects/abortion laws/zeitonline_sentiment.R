
# sentiment analyses on "Die Zeit" articles related to abortion in Germany 

library(dplyr)
library(readr)
library(quanteda)
library(quanteda.sentiment) 
library(quanteda.textstats)
library(quanteda.textplots)
library(quanteda.textmodels)
library(textplot)
library(stringr)
library(seededlda)
library(tidyverse)
library(httr2)
library(gender)
library(ggplot2)


data <- read.csv("~/SICSS_2024/projects/abortion laws/zeit_abortion_merged.csv")

# keep texts (body, body_clean), firstnames, gender and url

zeit_subset <- data |> 
  select(firstname1, gender, body, body_clean, url)

#View(zeit_subset)

# drop if gender is missing 
# 1269 obs dropped --> including reports from news agencies (no gender determined)
# and names where gender could not be assigned (e.g, "Amrai")

zeit_subset <- zeit_subset[!is.na(zeit_subset$gender), ]

# sentiment analysis by gender

# prepare data
# create corpus and get summary 
corpus <- corpus(zeit_subset, text_field = "body_clean")
head(summary(corpus))

# create tokens
tokens <- tokens(corpus)
head(tokens)

# create document-feature matrix 
dfm <- dfm(tokens) # DFM, without pre-processing
head(dfm)
dim(dfm)


# show most frequent words 
topfeatures(dfm, 20)
textstat_frequency(dfm, n = 20)


# Remove unnecessary tokens and other text features, homogenize text
# adjust stopwords lift so it works for cleaned body variable 

stopwords_trans <- stopwords("de") |>
  str_replace("ä", "ae") |> 
  str_replace("ö", "oe") |> 
  str_replace("ü", "ue") |> 
  str_replace("ß", "ss")

stopwords_trans 

tokens_pp <- tokens(
  corpus,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords_trans, padding = FALSE) |> # show padding
  tokens_wordstem(language = "de")

tokens_pp


# Inspect pre-processed DFM:
dfm_pp <- dfm(tokens_pp)
head(dfm_pp)
dim(dfm_pp)

topfeatures(dfm_pp, 20)
textstat_frequency(dfm_pp, n = 20)


textstat_frequency(dfm_pp, n = 10)

dfm_pp <- dfm_trim(dfm_pp, min_termfreq = 2, termfreq_type = "count")
# getting rid of words that have no meaning here 
dfm_pp <- dfm_remove(dfm_pp, c("seit", "viel", "mehr", "ja", "sag", 
                               "sei", "uns", "sagt", "frag", "ganz", 
                               "gibt", "imm", "schon", "wurd", "bereit", 
                               "erst", "weiss", "les", "mal", "sei", "geht", 
                               "gerad", "rieke", "heut", "bitt", "nehm", "zwei", 
                               "eben", "beid", "bissch", "tatsaech", "wirklich", 
                               "gesagt", "ding", "seite", "viele", 
                               "klaus", "natuerlich", "tatsaechlich", "eigentlich",
                               "brinkbaeumer", "havertz", "bereits", "haette", 
                               "inhaltsseite", "abtreibung", "schwangerschaftsabbruch", 
                               "schwangerschaftsabbrueche"))
dim(dfm_pp)

# top 15 collocations 
textstat_collocations(tokens_pp) |>
  head(15)

# Feature-Coocurrence matrix for top 40 words
fcm_pp <- fcm(tokens_pp, context = "window", count = "frequency", window = 3)
# fcm_pp <- fcm(dfm_pp, context = "document", count = "frequency")
dim(fcm_pp)

fcm_pp_subset <- fcm_select(fcm_pp, names(topfeatures(dfm_pp, 25)))

# create and save textplot

png(filename = "~/SICSS_2024/projects/abortion laws/zeit_textplot_network.png", width = 800, height = 600)


textplot_network(fcm_pp_subset)
dev.off()


# differences in keywords by gender 
png(filename = "~/SICSS_2024/projects/abortion laws/zeit_keyness_plot.png", width = 800, height = 600)

# Create the plot
textstat_keyness(dfm_pp, target = docvars(corpus, "gender") == "female") |>
  textplot_keyness()

# Close the device to save the file
dev.off()



# performing sentiment analysis 

dict_pol <- data_dictionary_Rauh

dfm_lookup(dfm_pp, dict_pol)

polarity <- textstat_polarity(dfm_pp, dict_pol)
polarity

# assuming that all documents are ordered the same way in both data frames 
zeit_subset$doc_id <- paste0("text", 1:1867)

polarity_data <- left_join(zeit_subset, polarity) 

# polarity by gender
average_scores <- polarity_data |>
  group_by(gender) |>
  summarize(average_score = mean(sentiment, na.rm=TRUE))

average_scores



# word cloud by gender 

# removing more meaningless words... 

words2remove <-  append(stopwords_trans,c("seit", "viel", "mehr", "ja", "sag", 
                                          "sei", "uns", "sagt", "frag", "ganz", 
                                          "gibt", "imm", "schon", "wurd", "bereit", 
                                          "erst", "weiss", "les", "mal", "sei", "geht", 
                                          "gerad", "rieke", "heut", "bitt", "nehm", "zwei", 
                                          "eben", "beid", "bissch", "tatsaech", "wirklich", 
                                          "gesagt", "ding", "seite", "viele", 
                                          "klaus", "natuerlich", "tatsaechlich", "eigentlich",
                                          "brinkbaeumer", "havertz", "bereits", "haette", 
                                          "inhaltsseite", "abtreibung", "schwangerschaftsabbruch", 
                                          "schwangerschaftsabbrueche"))
words2remove

dfmat_source <- corpus_subset(corpus) |> 
  tokens(what = "word",
         remove_punct = TRUE, 
         remove_symbols = TRUE,
         remove_numbers = TRUE,
         remove_separators = TRUE) |>
  tokens_remove(words2remove) |>
  dfm() |>
  dfm_trim(min_termfreq = 500, verbose = FALSE)
textplot_wordcloud(dfmat_source)

# wordcloud gendered

png(filename = "~/SICSS_2024/projects/abortion laws/zeit_wordcloud.png", width = 800, height = 600)

dfmat_source_gender <- corpus_subset(corpus, 
                                     gender %in% c("male", "female")) |>
  tokens(what = "word",
         remove_punct = TRUE, 
         remove_symbols = TRUE,
         remove_numbers = TRUE,
         remove_separators = TRUE) |>
  tokens_remove(words2remove) |>
  dfm() |>
  dfm_group(groups = gender) |>
  dfm_trim(min_termfreq = 300, verbose = FALSE)
textplot_wordcloud(dfmat_source_gender,
                   comparison = TRUE,
                   min_size = 2,
                   max_size = 10,
                   color = c("red", "blue"))

dev.off()


# save as csv
write_csv(polarity_data, "~/SICSS_2024/projects/abortion laws/zeit_sentiment.csv")
