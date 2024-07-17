
# sentiment analyses on articles related to "abortion" in Germany 

#install.packages("textplot")
library(dplyr)
library(quanteda)
library(quanteda.sentiment) 
library(quanteda.textstats)
library(quanteda.textplots)
library(textplot)
library(stringr)


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
dim(dfm_pp)

# top 15 collocations 
textstat_collocations(tokens_pp) |>
  head(15)

# Feature-Coocurrence matrix for top 40 words
fcm_pp <- fcm(tokens_pp, context = "window", count = "frequency", window = 3)
# fcm_pp <- fcm(dfm_pp, context = "document", count = "frequency")
dim(fcm_pp)

fcm_pp_subset <- fcm_select(fcm_pp, names(topfeatures(dfm_pp, 40)))

# textplot
textplot_network(fcm_pp_subset)

# differences in keywords by gender 
textstat_keyness(dfm_pp, target = docvars(corpus, "gender") == "female") |>
  textplot_keyness()



