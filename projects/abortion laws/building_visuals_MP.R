library(tidyverse)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)
library(quanteda.sentiment)
library(seededlda)
library(quanteda.textmodels)
library(tidychatmodels)
library(httr2)
library(gender)
library(ggplot2)
library(svglite)
#remotes::install_github("lmullen/genderdata")

#########################################################################

# read in articles
source <- read.csv("~/SICSS/SICSS_2024/projects/abortion laws/prepared_article_data/federalist_article_data.csv")
outlet <- "federalist"
head(source)

# # clean row "author"
# source$author <- str_replace_all(source$authors, c("\\n" = "", 
#                                               "by" = "", 
#                                               "By" = "", 
#                                               "CNN's" = "",
#                                               ", CNN" = "", 
#                                               "CNN" = "", 
#                                               "Opinion" = "", 
#                                               "Analysis" = "",
#                                               "Associated Press" = "",
#                                               "AP" = "",
#                                               "staff" = "",
#                                               "Dr." = "",
#                                               " and " = ";",
#                                               " & " = ";"
#                                               ))
# source$author <- str_replace_all(source$author, c("^\\s" = "",
#                                               "\\t" = "",
#                                               "$\\s" = ""
#                                               ))
# 
# source_byauthor <- source %>%
#   separate_rows(author, sep = ";")%>%
#   separate_rows(author, sep = ",")%>%
#   mutate(author = str_trim(author)) %>%
#   distinct(url, author, .keep_all = TRUE) %>%
#   filter(str_detect(author, "[a-zA-Z]")) %>%
#   mutate(first_name = word(author, 1)) %>%
#   mutate(name = first_name)
# 
# ###########################################################################
# # GENDER OF AUTHORS
# 
# # via gender package
# gendered <- source_byauthor %>% 
#   rowwise() %>% 
#   do(results = gender(source_byauthor$first_name, method = "ssa")) %>% 
#   do(bind_rows(.$results))
# 
# # add gender info to cnn data
# source_gender <- left_join(source_byauthor, gendered)
# 
# # clean data
# source_gender <- distinct(source_gender)
# source_gender$year_min = NULL 
# source_gender$year_max = NULL

# Tokenization Source
corpus <- corpus(source, text_field = "body")

# remove these words
words2remove <-  append(stopwords("en"),c("abortion", "said", " CNN ", "v", " s ","abortions","says","also","can","0a", "amp","it’s","just","0a",
                                          "3b"))

############################################################################
# QUANTEDA Visualizations

# wordcloud
# base 
dfmat_source <- corpus_subset(corpus) |> 
  tokens(what = "word",
         remove_punct = TRUE, 
         remove_symbols = TRUE,
         remove_numbers = TRUE,
         remove_separators = TRUE) |>
  tokens_remove(words2remove) |>
  dfm() |>
  dfm_trim(min_termfreq = 6000, verbose = FALSE)
textplot_wordcloud(dfmat_source)

# Gendered wordcloud---------------------------

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
  dfm_trim(min_termfreq = 50, verbose = FALSE)
textplot_wordcloud(dfmat_source_gender,
    comparison = TRUE,
    min_size = .5,
    max_size = 10,
    max_words = 100,
    color=c("red","blue"))

  ggsave(filename = paste0(outlet,"_worldcloud_gendered.svg"), plot=last_plot())

# # frequency diagramm
# tstat_freq_source <- textstat_frequency(dfmat_source, n = 100)
# 
# ggplot(tstat_freq_source, 
#        aes(x = frequency, y = reorder(feature, frequency))
#        ) +
#   geom_point() + 
#   labs(x = "Frequency", y = "Feature")

#ggsave(filename = "~/SICSS_2024/projects/abortion laws/plot_cnn_1.svg", plot=last_plot())
# ggsave(filename = paste0(outlet,"_freqdiag.svg"), plot=last_plot())

# frequency diagramm gendered

# # first version: 
# dfmat_source_male <- dfm_subset(dfmat_source, gender == "male")
# tstat_freq_source_male <- textstat_frequency(dfmat_source_male)
# 
# dfmat_source_female <- dfm_subset(dfmat_source, gender == "female")
# tstat_freq_source_female <- textstat_frequency(dfmat_source_female)



#second version

dfmat_source_f <- corpus |> 
  tokens(remove_punct = TRUE) |>
  tokens_remove(words2remove) |>
  dfm() |>
  dfm_trim(min_termfreq = 600, verbose = FALSE) %>%
  dfm_subset(gender =="female")


dfmat_source_m <- corpus |> 
  tokens(remove_punct = TRUE) |>
  tokens_remove(words2remove) |>
  dfm() |>
  dfm_trim(min_termfreq = 600, verbose = FALSE) %>%
  dfm_subset(gender =="male")

tstat_freq_source_male2 <- textstat_frequency(dfmat_source_m)
tstat_freq_source_female2 <- textstat_frequency(dfmat_source_f)

# Frequency Plotting -----------------------------------------------------
# (for version 2 switch data to "...male2")
# ggplot() +
#   geom_point(data = tstat_freq_source_male2,
#              aes(x = frequency, 
#                  y = reorder(feature, frequency),
#                  color = "Male")) +
#   geom_point(data = tstat_freq_source_female2, 
#              aes(x = frequency, 
#                  y = reorder(feature, frequency), 
#                  color = "Female")) +
#   scale_color_manual(values = c("Female" = "red", 
#                                 "Male" = "blue")) +
#   scale_x_continuous(labels = abs) +
#   labs(x = "Frequency", 
#        y = "Feature", 
#        color = "Gender") +
#   theme_minimal()+
#   theme(legend.position = "top",
#         axis.text.y = element_text(lineheight = 5,
#                                    size = 5))
# ggsave(filename = paste0(outlet,"_freqdiag_gen_ver2.svg"), plot=last_plot())

# Frequency plotting update----------------------------------------------
# Berechnung der Anzahl der Wörter pro Geschlecht
word_count_female <- sum(ntoken(dfm_subset(dfmat_source, gender == "female")))
word_count_male <- sum(ntoken(dfm_subset(dfmat_source, gender == "male")))

# Berechnung der relativen Häufigkeit
tstat_freq_source_female$relative_frequency <- tstat_freq_source_female$frequency / word_count_female
tstat_freq_source_male$relative_frequency <- tstat_freq_source_male$frequency / word_count_male

# Plotting der relativen Häufigkeit
ggplot() +
  geom_point(data = tstat_freq_source_male,
             aes(x = relative_frequency, 
                 y = reorder(feature, relative_frequency),
                 color = "Male")) +
  geom_point(data = tstat_freq_source_female, 
             aes(x = relative_frequency, 
                 y = reorder(feature, relative_frequency), 
                 color = "Female")) +
  scale_color_manual(values = c("Female" = "red", 
                                "Male" = "blue")) +
  labs(x = "Relative Frequency", 
       y = "Feature", 
       color = "Gender") +
  theme_minimal() +
  theme(legend.position = "top",
        axis.text.y = element_text(lineheight = 5, size = 5))

ggsave(filename = "~/SICSS_2024/projects/abortion laws/plot_cnn_relative_m.svg", plot = last_plot())

ggplot() +
  geom_point(data = tstat_freq_source_female, 
             aes(x = relative_frequency, 
                 y = reorder(feature, relative_frequency), 
                 color = "Female")) +
  geom_point(data = tstat_freq_source_male,
             aes(x = relative_frequency, 
                 y = reorder(feature, relative_frequency),
                 color = "Male")) +
  scale_color_manual(values = c("Female" = "red", 
                                "Male" = "blue")) +
  labs(x = "Relative Frequency", 
       y = "Feature", 
       color = "Gender") +
  theme_minimal() +
  theme(legend.position = "top",
        axis.text.y = element_text(lineheight = 10, size = 10))

ggsave(filename = "~/SICSS_2024/projects/abortion laws/plot_cnn_relative_f.svg", plot = last_plot())


# Topfeatures-----------
topfeatures(dfmat_source_f, 10)
topfeatures(dfmat_source_m, 10)

# Collocations gendered
test_m <- corpus_subset(corpus, gender %in% "male") 
textstat_collocations(test_m) %>%
  head(15)
test_f <- corpus_subset(corpus, gender %in% "female") 
textstat_collocations(test_f) %>%
  head(15)

# Topic Model
tmod_lda <- textmodel_lda(dfmat_source, k = 3)
topics <- terms(tmod_lda, 10) %>%
  tibble()

topics$outlet <- outlet

topics

write.csv(topics,file = paste0(outlet,"_topics.csv"))
#topics(tmod_lda)

# Keyness-------------------------------------------
textstat_keyness(dfmat_source, target = docvars(corpus, "gender") == "female") %>%
 textplot_keyness()

ggsave(filename = paste0(outlet,"_keyness.svg"), plot=last_plot())

# Polarity ---------------------------------------
# head(data_dictionary_HuLiu)
# head(data_dictionary_LSD2015)
# lapply(valence(data_dictionary_AFINN), head, 10)
# lapply(valence(data_dictionary_ANEW), head, 10)


dict_pol <- data_dictionary_HuLiu

dfm_lookup(dfmat_source, dict_pol)

polarity <- textstat_polarity(dfmat_source, dict_pol)

dfm_pp_train <- dfmat_source[1:200, ]

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