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
source <- read.csv("~/SICSS/SICSS_2024/projects/abortion laws/cnn_abortion.csv")
head(source)

# clean row "author"
source$author <- str_replace_all(source$authors, c("\\n" = "", 
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
source$author <- str_replace_all(source$author, c("^\\s" = "",
                                              "\\t" = "",
                                              "$\\s" = ""
                                              ))

source_byauthor <- source %>%
  separate_rows(author, sep = ";")%>%
  separate_rows(author, sep = ",")%>%
  mutate(author = str_trim(author)) %>%
  distinct(url, author, .keep_all = TRUE) %>%
  filter(str_detect(author, "[a-zA-Z]")) %>%
  mutate(first_name = word(author, 1)) %>%
  mutate(name = first_name)

###########################################################################
# GENDER OF AUTHORS

# via gender package
gendered <- source_byauthor %>% 
  rowwise() %>% 
  do(results = gender(source_byauthor$first_name, method = "ssa")) %>% 
  do(bind_rows(.$results))

# add gender info to cnn data
source_gender <- left_join(source_byauthor, gendered)

# clean data
source_gender <- distinct(source_gender)
source_gender$year_min = NULL 
source_gender$year_max = NULL

# Tokenization Source
corpus <- corpus(source_gender, text_field = "body")

# remove these words
words2remove <-  append(stopwords("en"),c("abortion", "said", " CNN ", "v", " s "))

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
  dfm_trim(min_termfreq = 1000, verbose = FALSE)
textplot_wordcloud(dfmat_source)

# wordcloud gendered
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
    max_size = 10)

# frequency diagramm
tstat_freq_source <- textstat_frequency(dfmat_source, n = 100)

ggplot(tstat_freq_source, 
       aes(x = frequency, y = reorder(feature, frequency))
       ) +
  geom_point() + 
  labs(x = "Frequency", y = "Feature")

ggsave(filename = "~/SICSS_2024/projects/abortion laws/plot_cnn_1.svg", plot=last_plot())

# frequency diagramm gendered

# first version: 
dfmat_source_male <- dfm_subset(dfmat_source, gender == "male")
tstat_freq_source_male <- textstat_frequency(dfmat_source_male)

dfmat_source_female <- dfm_subset(dfmat_source, gender == "female")
tstat_freq_source_female <- textstat_frequency(dfmat_source_female)

#second version
dfmat_source_f <- corpus_subset(corpus) |> 
  tokens(remove_punct = TRUE) |>
  tokens_remove(words2remove) |>
  dfm() |>
  dfm_trim(min_termfreq = 2000, verbose = FALSE) %>%
  dfm_subset(gender =="female")

dfmat_source_m <- corpus_subset(corpus) |> 
  tokens(remove_punct = TRUE) |>
  tokens_remove(words2remove) |>
  dfm() |>
  dfm_trim(min_termfreq = 2000, verbose = FALSE) %>%
  dfm_subset(gender =="male")
tstat_freq_source_male2 <- textstat_frequency(dfmat_source_m)
tstat_freq_source_female2 <- textstat_frequency(dfmat_source_f)

# Plotting (for version 2 switch data to "...male2")
ggplot() +
  geom_point(data = tstat_freq_source_male,
             aes(x = frequency, 
                 y = reorder(feature, frequency),
                 color = "Male")) +
  geom_point(data = tstat_freq_source_female, 
             aes(x = frequency, 
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
        axis.text.y = element_text(lineheight = 10,
                                   size = 10))
ggsave(filename = "~/SICSS_2024/projects/abortion laws/plot_cnn_2.svg", plot=last_plot())

# Topfeatures
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
tmod_lda <- textmodel_lda(dfmat_source[1:700, ], k = 4)
terms(tmod_lda, 5)
#topics(tmod_lda)

# Testing stuff
#textstat_keyness(dfmat_source, target = docvars(corpus, "gender") == "male") %>%
#  textplot_keyness()


