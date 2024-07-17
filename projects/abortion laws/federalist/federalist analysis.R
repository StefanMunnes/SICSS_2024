library(dplyr)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)
library(quanteda.sentiment)
library(seededlda)
library(quanteda.textmodels)

data_fed <- read.csv("~/SICSS/SICSS_2024/projects/abortion laws/federalist/Federalist_article_data.csv")
data_fed$doc_id <- paste0("text",1:492)

corpus <- corpus(data_fed,text_field = "final_text")
head(summary(corpus))


#stopwords("en")

tokens_pp <- tokens(
  corpus,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en"), padding = FALSE) |> # show padding
  tokens_wordstem(language = "en")

dfm_pp <- dfm(tokens_pp)
head(dfm_pp)
dim(dfm_pp)

textstat_frequency(dfm_pp, n = 20)
fed_topfeat <- topfeatures(dfm_pp,n=15)

dfm_pp <- dfm_trim(dfm_pp, min_termfreq = 2, termfreq_type = "count")
dim(dfm_pp)

fed_collocations <- textstat_collocations(tokens_pp) |>
  head(15)
write.csv(fed_collocations,"~/SICSS/SICSS_2024/projects/abortion laws/federalist/fed_collocations.csv")

## Feature-Coocurrence-Matrix
fcm_pp <- fcm(tokens_pp, context = "window", count = "frequency", window = 3)
# fcm_pp <- fcm(dfm_pp, context = "document", count = "frequency")
dim(fcm_pp)

fcm_pp_subset <- fcm_select(fcm_pp, names(topfeatures(dfm_pp, 20)))

textplot_network(fcm_pp_subset)

##Sentiment-------------------------------------------
head(data_dictionary_HuLiu)
head(data_dictionary_LSD2015)
lapply(valence(data_dictionary_AFINN), head, 10)
lapply(valence(data_dictionary_ANEW), head, 10)


dict_pol <- data_dictionary_HuLiu

dfm_lookup(dfm_pp, dict_pol)

polarity <- textstat_polarity(dfm_pp, dict_pol)

dfm_pp_train <- dfm_pp[1:200, ]

sentiment_class <- cut(
  polarity$sentiment,
  breaks = c(-4, -0.2, 0.2, 4),
  labels = c("negative", "neutral", "positive")
)

sentiment_class_train <- sentiment_class[1:200]

model_nb <- textmodel_nb(dfm_pp_train, sentiment_class_train)
#dfm_pp_test <- dfm_pp[201:300, ]
predictions_sent <- predict(model_nb, dfm_pp)
table(Predicted = predictions_sent, Actual = sentiment_class[1:492])

data_fed_polarity <- left_join(data_fed,polarity,"doc_id")

average_scores <- data_fed_polarity %>%
  group_by(gender) %>%
  summarize(average_score = mean(sentiment, na.rm = TRUE))

write.csv(average_scores,"~/SICSS/SICSS_2024/projects/abortion laws/federalist/ave_sent_score_by_gen.csv")
write.csv(data_fed_polarity,"~/SICSS/SICSS_2024/projects/abortion laws/federalist/data_fed_polarity.csv")
