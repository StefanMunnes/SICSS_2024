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

#remotes::install_github("lmullen/genderdata")


cnn <- read.csv("~/SICSS_2024/projects/abortion laws/cnn_abortion.csv")
head(cnn)

# clean cnn$author
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


# GENDER OF AUTHORS

# via gender package
gendered <- cnn_byauthor %>% 
  rowwise() %>% 
  do(results = gender(cnn_byauthor$first_name, method = "ssa")) %>% 
  do(bind_rows(.$results))

# add gender info to cnn data
cnn_gender <- left_join(cnn_byauthor, gendered)
# clean data
cnn_gender <- distinct(cnn_gender)
cnn_gender$year_min = NULL 
cnn_gender$year_max = NULL


# SENTIMENT

# Tokenization CNN
corpus <- corpus(cnn2, text_field = "body")
tokens <- tokens(corpus, what = "word")
dfm <- dfm(tokens)

# topfeatures before cleaning
topfeatures(dfm, 10)

#remove these words
words2remove <-  append(stopwords("en"),c("abortion", "said"))
 
# cleaning tokens
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
  tokens_remove(words2remove, padding = TRUE)
dfm_pp <- dfm(tokens_pp)

# show cleaned data
topfeatures(dfm_pp, 10)

# Dictionary
dict_pol <- data_dictionary_HuLiu

# compute sentiment values and add them to cnn2 by url
lookup <- dfm_lookup(dfm_pp, dict_pol)
lookup_df <- convert(lookup, to = "data.frame")
lookup_df$url <- cnn2$url

polarity <- textstat_polarity(dfm_pp, dict_pol)
#polarity_df <- convert(polarity, to = "data.frame")
#polarity_df$url <- cnn2$url

valence <- textstat_valence(dfm_pp, data_dictionary_AFINN)
#valence_df <- convert(valence, to = "data.frame")
#valence_df$url <- cnn2$url

# JOINING CNN_gender together with CNN_sentiment
cnn2 <- left_join(cnn_gender, lookup_df, by = "url")
#cnn2 <- left_join(cnn_gender, polarity_df, by = "url")
#cnn2 <- left_join(cnn_gender, valence_df, by = "url")

cnn2 <- cnn2 %>%
  mutate(lookup_df = case_when(
    positive > negative ~ "positive",
    positive < negative ~ "negative",
    positive == negative ~ "unclear"
  ))
# clean cnn data
cnn2$doc_id = NULL 
cnn2$name = NULL 


dfm_female <- dfm_subset(dfm_pp, gender == "female")
dfm_male <- dfm_subset(dfm_pp, gender == "male")
topfeatures(dfm_male, 10)
topfeatures(dfm_female, 10)

# RESULTS
#table1 <- table(cnn2$lookup_df, cnn2$gender)
#table2 <- round(prop.table(table(cnn2$lookup_df, cnn2$gender), 2),2)
#table1
#table2


# QUANTEDA Visualizations

# wordcloud
# base 
dfmat_cnn <- corpus_subset(corpus) |> 
  tokens(remove_punct = TRUE) |>
  tokens_remove(words2remove) |>
  dfm() |>
  dfm_trim(min_termfreq = 2500, verbose = FALSE)

# actual cloud
set.seed(100)
textplot_wordcloud(dfmat_cnn)

# wordcloud gendered
dfmat_cnn_gender <- corpus_subset(corpus, 
                                  gender %in% c("male", "female")) |>
  tokens(remove_punct = TRUE, 
         remove_symbols = TRUE,
         remove_numbers = TRUE,
         remove_separators = TRUE) |>
  tokens_remove(words2remove) |>
  dfm() |>
  dfm_group(groups = gender) |>
  dfm_trim(min_termfreq = 300, verbose = FALSE) |>
  textplot_wordcloud(
    comparison = TRUE,
    min_size = 2,
    max_size = 10)



# frequency diagramm
tstat_freq_cnn <- textstat_frequency(dfmat_cnn, n = 100)

ggplot(tstat_freq_cnn, 
       aes(x = frequency, y = reorder(feature, frequency))
       ) +
  geom_point() + 
  labs(x = "Frequency", y = "Feature")

# frequency diagramm gendered
dfmat_cnn_f <- corpus_subset(corpus) |> 
  tokens(remove_punct = TRUE) |>
  tokens_remove(words2remove) |>
  dfm() |>
  dfm_trim(min_termfreq = 4000, verbose = FALSE) %>%
  dfm_subset(gender =="female")

dfmat_cnn_m <- corpus_subset(corpus) |> 
  tokens(remove_punct = TRUE) |>
  tokens_remove(words2remove) |>
  dfm() |>
  dfm_trim(min_termfreq = 4000, verbose = FALSE) %>%
  dfm_subset(gender =="male")
tstat_freq_cnn_male2 <- textstat_frequency(dfmat_cnn_m)
tstat_freq_cnn_female2 <- textstat_frequency(dfmat_cnn_f)


dfmat_cnn_male <- dfm_subset(dfmat_cnn, gender == "male")
tstat_freq_cnn_male <- textstat_frequency(dfmat_cnn_male)

dfmat_cnn_female <- dfm_subset(dfmat_cnn, gender == "female")
tstat_freq_cnn_female <- textstat_frequency(dfmat_cnn_female)

ggplot() +
  geom_point(data = tstat_freq_cnn_male2,
             aes(x = frequency, 
                 y = reorder(feature, frequency),
                 color = "Male")) +
  geom_point(data = tstat_freq_cnn_female2, 
             aes(x = -frequency, 
                 y = reorder(feature, frequency), 
                 color = "Female")) +
  scale_color_manual(values = c("Female" = "red", 
                                "Male" = "blue")) +
  scale_x_continuous(labels = abs) +
  labs(x = "Frequency", 
       y = "Feature", 
       color = "Gender") +
  theme_minimal()+
  theme(legend.position = "top",
        axis.text.y = element_text(lineheight = 5,
                                   size = 10))




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