# Combining and Cleaning the Data
################################################################################

# Set the Working Directory
setwd("C:/Users/kayle/Dropbox/Resources/SICSS_2024/projects/education_project/")

# Open the Relevant Libraries
library(dplyr)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)
library(tidyverse)
library(lubridate)
library(stringr)
library(xlsx)
library(Hmisc)
library(ldatuning)


# Pull the Two Sets of Articles and Make a Source Column
cnn <- readRDS("cnnurls.Rds")
cnn$source <- c("cnn")
fox <- readRDS("FOX.Rds")
fox$source <- c("fox")

# Combine into One Dataset
articles <- rbind(cnn, fox)

# Clean the Dataset

  # Remove 'By ' from authors Column
  articles$authors <- str_replace_all(articles$authors, 
      "By |Opinion by |Analysis by |\\s{2,}|\\n|^\\s+|\\s+$", "")

  # Leave only the date in the date column
  articles$date <- str_extract_all(articles$timestamp, 
    "\\w+ \\d{1,2}, \\d{4}")|>
    mdy()|>
    format("%Y.%m.%e")|>
    str_replace_all(" ", "")

  articles <- subset(articles, select = -c(timestamp))
  write.xlsx(articles, "full_dataset.xlsx")
  
# Pull the Body Text for Analysis
corpus <- corpus(articles, text_field = "body")
tokens <- tokens(corpus)

corpus_cnn <- corpus(cnn, text_field = "body")
tokens_cnn <- tokens(corpus_cnn)

corpus_fox <- corpus(fox, text_field = "body")
tokens_fox <- tokens(corpus_fox)

# Check Out the Preliminary Results
head(summary(corpus))
head(tokens)

# Make a(n unprocessed) Document-Feature Matrix
dfm <- dfm(tokens) # DFM, without pre-processing
head(dfm)
dim(dfm)

# Top Features are Stopwords: 
  # topfeatures(dfm, 10)
  # textstat_frequency(dfm, n = 10)
  # Check Stopwords: stopwords("en")

# Clean Tokens

  # All
tokens <- tokens(
  corpus,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE)

tokens <- tokens_tolower(tokens)
tokens <- tokens_remove(tokens, stopwords("en"), padding = FALSE)
tokens <- tokens_remove(tokens, c("fox news", "fox", "cnn"))
tokens <- tokens_wordstem(tokens, language = "en")

  # Fox
tokens_fox <- tokens(
  corpus_fox,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE)

tokens_fox <- tokens_tolower(tokens_fox)
tokens_fox <- tokens_remove(tokens_fox, stopwords("en"), padding = FALSE)
tokens_fox <- tokens_remove(tokens_fox, c("fox news", "fox", "cnn", "said"))
tokens_fox <- tokens_wordstem(tokens_fox, language = "en")

  # CNN
tokens_cnn <- tokens(
  corpus_cnn,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE)

tokens_cnn <- tokens_tolower(tokens_cnn)
tokens_cnn <- tokens_remove(tokens_cnn, stopwords("en"), padding = FALSE)
tokens_cnn <- tokens_remove(tokens_cnn, c("fox news", "fox", "cnn", "said"))
tokens_cnn <- tokens_wordstem(tokens_cnn, language = "en")

# Inspecting Results
dfm <- dfm(tokens) # DFM, post-processing
head(dfm)
dim(dfm)
dfm_fox <- dfm(tokens_fox)
dfm_cnn <- dfm(tokens_cnn)
  
# Preliminary Analysis

  # Figure 1. Main Word Differences Between Corpora

# Assuming dfm and corpus are already defined
result <- textstat_keyness(dfm, target = docvars(corpus, "source") == "cnn")

# Create the initial keyness plot
keyness_plot <- textplot_keyness(result, margin = 0.2, n = 10)

# Print the structure of the plot to verify it's a ggplot object
str(keyness_plot)

# Customize the plot
customized_plot <- keyness_plot +
  scale_fill_manual(
    name = "Source",
    values = c("darkred", "steelblue"),
    labels = c("CNN", "Other")
  ) +
  labs(
    title = "Keyness Plot",
    x = "Keyness Score",
    y = "Terms"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12)
  )

# Print the customized plot
print(customized_plot)

fcm_fox <- fcm(tokens_fox, context = "window", count = "frequency", window = 3)
fcm_cnn <- fcm(tokens_cnn, context = "window", count = "frequency", window = 3)

fcm <- fcm_select(fcm, names(topfeatures(dfm, 40)))
fcm_fox <- fcm_select(fcm_fox, names(topfeatures(dfm, 40)))
fcm_cnn <- fcm_select(fcm_cnn, names(topfeatures(dfm, 40)))

  # Figure 2. (panel) Word Network

textplot_network(fcm)
textplot_network(fcm_fox)
textplot_network(fcm_cnn)

# Supplemental Stuff 
# textstat_collocations(tokens) |>
#  head(15)
# fcm <- fcm(tokens, context = "window", count = "frequency", window = 3)
# fcm <- fcm(dfm, context = "document", count = "frequency")
# dim(fcm)

# Topic Modeling
library(dplyr)
library(quanteda)
library(quanteda.sentiment)
library(seededlda)
library(quanteda.textmodels)

head(data_dictionary_HuLiu)
head(data_dictionary_LSD2015)
lapply(valence(data_dictionary_AFINN), head, 10)
lapply(valence(data_dictionary_ANEW), head, 10)

# Setting the Sentiment Dictionary for Polarity
dict_pol <- data_dictionary_HuLiu

dfm_lookup(dfm, dict_pol)
dfm_lookup(dfm_fox, dict_pol)
dfm_lookup(dfm_cnn, dict_pol)

polarity <- textstat_polarity(dfm, dict_pol)
polarity_fox <- textstat_polarity(dfm_fox, dict_pol)
polarity_cnn <- textstat_polarity(dfm_cnn, dict_pol)

describe(polarity)
describe(polarity_fox)
describe(polarity_cnn)

polarity_cnn$source <- c("cnn")
polarity_fox$source <- c("fox")
polarity_cat <- polarity_cnn
polarity_cat <- rbind(polarity_cat, polarity_fox)

  # Figure 3. Sentiment Analysis

a <- ggplot(polarity_cat, aes(source, sentiment))
a + geom_boxplot()

# Topic Models

topsfox <- FindTopicsNumber(
  dfm_fox,
  topics = seq(from = 2, to = 15, by = 1),
  metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010", "Deveaud2014"),
  method = "Gibbs",
  control = list(seed = 77),
  mc.cores = 2L,
  verbose = TRUE
)

FindTopicsNumber_plot(topsfox)

topscnn <- FindTopicsNumber(
  dfm_cnn,
  topics = seq(from = 2, to = 15, by = 1),
  metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010", "Deveaud2014"),
  method = "Gibbs",
  control = list(seed = 77),
  mc.cores = 2L,
  verbose = TRUE
)

FindTopicsNumber_plot(topscnn)

lda_cnn_10 <- textmodel_lda(dfm_cnn, k = 6)
lda_fox_10 <- textmodel_lda(dfm_fox, k = 6)

terms(lda_cnn_10, n = 12)

topics(lda_cnn_10)

# Picture! 
top10 <- terms(lda_cnn_10, n = 10) |>
  as_tibble() |>
  pivot_longer(cols=starts_with("t"),
               names_to="topic", values_to="word")

phi <- lda_cnn_10$phi |>
  as_tibble(rownames="topic")  |>
  pivot_longer(cols=c(-topic))


top10phi <- top10 |>
  left_join(y=phi, by=c("topic", "word"="name")) ##finally I have a tibble I can work with.

top10phi
#> # A tibble: 50 × 3
#>    topic  word       value
#>    <chr>  <chr>      <dbl>
#>  1 topic1 crude    0.00509
#>  2 topic2 today    0.00488
#>  3 topic3 un       0.00482
#>  4 topic4 twitter  0.0101 
#>  5 topic5 patriot  0.00642
#>  6 topic1 grain    0.00426
#>  7 topic2 soviet   0.00457
#>  8 topic3 french   0.00482
#>  9 topic4 joins    0.00720
#> 10 topic5 missiles 0.00612
#> # ℹ 40 more rows


## See https://stackoverflow.com/questions/5409776/how-to-order-bars-in-faceted-ggplot2-bar-chart/5414445#5414445


sort_facets <- function(df, cat_a, cat_b, cat_out, ranking_var){
  res <- df |>
    mutate({{cat_out}}:=factor(paste({{cat_a}}, {{cat_b}}))) |>
    mutate({{cat_out}}:=reorder({{cat_out}}, rank({{ranking_var}})))
  
  return(res)  
}




dd2 <- sort_facets(top10phi, topic, word, category2, value)

gpl <- ggplot(dd2, aes(y=category2, x=value)) +
  geom_bar(stat = "identity") +
  facet_wrap(. ~ topic, scales = "free_y", nrow=3) +
  scale_y_discrete(labels=dd2$word, breaks=dd2$category2,
  )+
  xlab("Probability")+
  ylab(NULL)

gpl












###

topics(tmod_lda)


# Picture! 
top10 <- terms(tmod_lda, n = 10) |>
  as_tibble() |>
  pivot_longer(cols=starts_with("t"),
               names_to="topic", values_to="word")

phi <- tmod_lda$phi |>
  as_tibble(rownames="topic")  |>
  pivot_longer(cols=c(-topic))


top10phi <- top10 |>
  left_join(y=phi, by=c("topic", "word"="name")) ##finally I have a tibble I can work with.

top10phi
#> # A tibble: 50 × 3
#>    topic  word       value
#>    <chr>  <chr>      <dbl>
#>  1 topic1 crude    0.00509
#>  2 topic2 today    0.00488
#>  3 topic3 un       0.00482
#>  4 topic4 twitter  0.0101 
#>  5 topic5 patriot  0.00642
#>  6 topic1 grain    0.00426
#>  7 topic2 soviet   0.00457
#>  8 topic3 french   0.00482
#>  9 topic4 joins    0.00720
#> 10 topic5 missiles 0.00612
#> # ℹ 40 more rows


## See https://stackoverflow.com/questions/5409776/how-to-order-bars-in-faceted-ggplot2-bar-chart/5414445#5414445


sort_facets <- function(df, cat_a, cat_b, cat_out, ranking_var){
  res <- df |>
    mutate({{cat_out}}:=factor(paste({{cat_a}}, {{cat_b}}))) |>
    mutate({{cat_out}}:=reorder({{cat_out}}, rank({{ranking_var}})))
  
  return(res)  
}




dd2 <- sort_facets(top10phi, topic, word, category2, value)

gpl <- ggplot(dd2, aes(y=category2, x=value)) +
  geom_bar(stat = "identity") +
  facet_wrap(. ~ topic, scales = "free_y", nrow=3) +
  scale_y_discrete(labels=dd2$word, breaks=dd2$category2,
  )+
  xlab("Probability")+
  ylab(NULL)

gpl

