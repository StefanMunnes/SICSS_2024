library(tidyverse)
library(rvest)
library(xml2)

# What we want:
# Title: #maincontent
# Authors: .byline__name   (Achtung: can be multiple names!)
# Date: .timestamp
# Text: .paragraph

urls <- scan("foxurls_abortion.txt", character(), quote = "")
urls <- unique(urls)

# # Testrun -----------------------------------------------------------------
# website <- read_html(urls[640])
# 
# test <- tibble(
#   title = website %>%
#     html_node(".headline") %>%
#     html_text(),
# 
#   authors = website %>%
#     html_nodes(".author-byline a") %>%
#     html_text()  %>%
#     paste(collapse = ";"),
# 
#   timestamp = website %>%
#     html_nodes("time") %>%
#     html_text(),
# 
#   body = website %>%
#     html_nodes(".article-body p") %>%
#     html_text() %>%
#     paste(collapse = ""),
# 
#   #url = url
# )
# 
# 
# # Loop --------------------------------------------------------------------
# # Split the task, otherwise memory overload
# # split urls list into smaller chunks, otherwise memory will run full and R will crash
# url_groups <- split(urls, ceiling(seq_along(urls) / 350))
# 
# for (batch in 1:3) {
# 
#   articles <- data.frame()
# 
#   for (url in url_groups[[batch]]) {
#     Sys.sleep(runif(1)+sample(1:2, 1))
# 
#     print(paste(batch, url))
# 
#     website <- read_html(url)
# 
#     tmp <- tibble(
#       title = website %>%
#         html_node(".headline") %>%
#         html_text(),
# 
#       authors = website %>%
#         html_nodes(".author-byline a") %>%
#         html_text()  %>%
#         paste(collapse = ";"),
# 
#       timestamp = website %>%
#         html_nodes("time") %>%
#         html_text(),
# 
#       body = website %>%
#         html_nodes(".article-body p") %>%
#         html_text() %>%
#         paste(collapse = ""),
# 
#       url = url
#     )
# 
#     articles <- rbind(articles, tmp)
#   }
#   saveRDS(articles, file = paste0("FOX", batch, ".Rds"))
# }
# 
# # Append FOX articles
# FOX <- rbind(
#   readRDS("FOX1.Rds"),
#   readRDS("FOX2.Rds")
#   )
# 
# # remove duplicates in the body column
# FOX <- FOX %>%
#   distinct(body, .keep_all = TRUE)
# 
# # check if length is realistic
# FOX <- FOX %>%
#   mutate(article_length = str_length(body))
# 
# # safety copy
# FOX_OG <- FOX
# 
# # save as one file
# saveRDS(FOX, file = "FOX_abortion.Rds")
# 
# 
# 
# 
# 
# 
# 
# #### Data cleaning
# # remove ";Fox News" or "Fox News"
# FOX$authors <- gsub(";Fox News|Fox News", "", FOX$authors)
# 
# # set empty author fields as NAs
# FOX$authors <- ifelse(FOX$authors == "", NA, FOX$authors)
# 
# # remove Dr. and Rep.
# FOX$authors <- gsub("Dr. |Rep. ", NA, FOX$authors)
# 
# # replace "Staff", "Associated Press", "OutKick" by NA
# FOX$authors <- gsub("Staff|Associated Press|OutKick", NA, FOX$authors)
# 
# 
# # split up authors entry by ";", create a new column for each new author
# # rename new columns with "author" and count
# # if there are too few authors, too_few = "align_start" fills remaining columns with NAs 
# FOX_clean <- FOX %>%
#   separate_wider_delim(authors, 
#                        delim = ";", 
#                        names_sep = "", 
#                        too_few = "align_start", # aligns starts of short matches, adding NA on the end to pad to the correct length.
#                        cols_remove = TRUE) %>%
#   rename_with(~sub("authors", "author", .), starts_with("authors"))
# 
# # safety copy
# FOX_clean_OG <- FOX_clean



## if FOX_clean saved, continue here and import the data set
FOX_clean <- read.csv("~/Dropbox/SICSS 2024 local/SICSS_2024/Own work local/FOX_clean.csv")




# ## get the first names of the authors and save them into a new column
# # Create a list of columns to duplicate
# 
# columns_to_duplicate <- colnames(FOX_clean)[grepl("author", colnames(FOX_clean))]
# 
# # Duplicate the columns
# for (col in columns_to_duplicate) {
#   new_col_name <- paste0(col, "_firstname")
#   FOX_clean[[new_col_name]] <- FOX_clean[[col]]
#   FOX_clean[[new_col_name]] <- word(FOX_clean[[new_col_name]], 1)
# }

# ## get first name of first author
# FOX_clean$author1_firstname <- word(FOX_clean$author1,1)


## predicting gender based on first names

library(gender)
# install.packages("remotes")
# remotes::install_github("lmullen/genderdata")

library(genderdata)
# data(package = "genderdata")

# convert author column: create a list of the first names to feed into gender()
# gender() takes in a character vector for names
author1_namelist <- list(FOX_clean$author1_firstname)
author1_namelist <- unique(unlist(author1_namelist))

# create a "dictionary" of genders for all names

gender_df1 <- gender(author1_namelist, years = 2012, method = "ssa")

gender_df1 <- subset(gender_df1, select = -c(year_min, year_max))

# gender_df <- gender_df %>%
#   select(-year_min, -year_max)

# left outer join, keeps all observations from FOX_clean and matches only the values in gender_df1 that exist in FOX_clean
FOX_clean_gender <- merge(FOX_clean, gender_df1, by.x = c("author1_firstname"), by.y = c("name"), all.x = TRUE)

FOX_clean_gender <- subset(FOX_clean_gender, !is.na(FOX_clean_gender$gender))

write.csv(FOX_clean_gender, file = "FOX_clean_gender.csv")





library(dplyr)
library(quanteda)
library(quanteda.sentiment)
library(seededlda)
library(quanteda.textmodels)
library(readxl)
library(quanteda.textstats)
library(quanteda.textplots)

#### Create corpus, tokens and DFM objects (without pre-processing)

# Create corpus object and get summary:

corpus <- corpus(FOX_clean_gender, text_field = "body")
head(summary(corpus))

# Create tokens object:

tokens <- tokens(corpus)
head(tokens)

# Create Document-Feature-Matrix:

dfm <- dfm(tokens) # DFM, without pre-processing
head(dfm)
dim(dfm)

# Show most frequent words (without pre-processing)

topfeatures(dfm, 10)
textstat_frequency(dfm, n = 10)






#### Pre-process the text for more useful insights

# Remove unnecessary tokens and other text features, homogenize text:

stopwords("en")

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

# Inspect pre-processed DFM:

dfm_pp <- dfm(tokens_pp)
head(dfm_pp)
dim(dfm_pp)

# get the most frequent tokens

top20_dfm <- textstat_frequency(dfm_pp, n = 20)

dfm_pp_og <- dfm_pp

# # Optional: remove "fox" from token list
# dfm_pp <- dfm_remove(dfm_pp, "fox")
# inspect top20_dfm
tokens_to_remove <- c("said", "v", "get", "abort")

dfm_pp <- dfm_remove(dfm_pp, tokens_to_remove)

# get the most frequent tokens

top20_dfm <- textstat_frequency(dfm_pp, n = 20)

dfm_pp_og <- dfm_pp

# only keep tokens that occur at least 2x
dfm_pp <- dfm_trim(dfm_pp, min_termfreq = 2, termfreq_type = "count")
dim(dfm_pp)

# save dfm as a dataframe and export as .csv file
df_dfm_pp <- as.data.frame(as.matrix(dfm_pp))
# write.csv(df_dfm_pp, file = "20240714 dfm.csv")


## Show most important compound and co-occuring words
# Show statistics for top 15 collocations:

textstat_collocations(tokens_pp) |>
  head(15)

## Create a Feature-Coocurrence-Matrix and plot connection for top 40 words:

fcm_pp <- fcm(tokens_pp, context = "window", count = "frequency", window = 3)
# fcm_pp <- fcm(dfm_pp, context = "document", count = "frequency")
dim(fcm_pp)

fcm_pp_subset <- fcm_select(fcm_pp, names(topfeatures(dfm_pp, 40)))

textplot_network(fcm_pp_subset)

## Visualize differences in keywords by news outlet
# Check if keywords differ for different news outlets:

# keyness bar graph
textstat_keyness(dfm_pp, target = docvars(corpus, "gender") == "female") |>
  textplot_keyness()

# wordcloud
dfmat2 <- corpus %>%
  corpus_subset(gender %in% c("female", "male")) %>%
  tokens(remove_punct = TRUE) %>%
  tokens_remove(stopwords("en"), padding = FALSE) %>%
  tokens_wordstem(language = "en") %>%
  tokens_remove(tokens_to_remove) %>%
  dfm()

dfmat2 <- dfm_group(dfmat2, dfmat2$gender) %>%
  dfm_trim(min_termfreq = 3)

textplot_wordcloud(dfmat2, comparison = TRUE, max_words = 25,
                   color = c("red", "blue"))


#### TF-IDF

# Calculate the TF-IDF scores
tfidf <- dfm_tfidf(
  dfm_pp,
  scheme_tf = "count",
  scheme_df = "inverse",
  base = 10,
  force = FALSE
)

# get the top 20 summary scores
top20_tfidf <- textstat_frequency(tfidf, n = 20, force = TRUE)

# save tfidf as dataframe
df_tfidf <- as.data.frame(as.matrix(tfidf))

# save tfidf as .csv file
# write.csv(df_tfidf, file = "20240714 tfidf.csv")










#### sentiment analysis ________________________________________________________

library(dplyr)
library(quanteda)
library(quanteda.sentiment)
library(seededlda)
library(quanteda.textmodels)



## get a dictionary from the quanteda.sentiment package
head(data_dictionary_HuLiu)
# head(data_dictionary_LSD2015)
# 
# ## calculate the polarity (or valence) sentiment for each document
# lapply(valence(data_dictionary_AFINN), head, 10)
# lapply(valence(data_dictionary_ANEW), head, 10)


dict_pol <- data_dictionary_HuLiu

# check how many words were detected from the dictionary
test <- dfm_lookup(dfm_pp, dict_pol)

# gives positive/negative
polarity <- textstat_polarity(dfm_pp, dict_pol)

#### Topic models analysis

# exploratory

tmod_lda <- textmodel_lda(dfm_pp[1:640, ], k = 3, max_iter = 2000)

terms(tmod_lda, 10)



# topics(tmod_lda)

#### Train my own naive bayes classifier for sentiment

# Get a training set from the labeled data and define classes:

dfm_pp_train <- dfm_pp[1:500, ]

sentiment_class <- cut(
  polarity$sentiment,
  breaks = c(-4, -0.2, 0.2, 4),
  labels = c("negative", "neutral", "positive")
)

sentiment_class_train <- sentiment_class[1:500]

# Train the model with the training data and classes:

model_nb <- textmodel_nb(dfm_pp_train, sentiment_class_train)

# Get (unlabelled) test data:

dfm_pp_test <- dfm_pp[501:630, ]

# Predict class for test data with trained model:

predictions_sent <- predict(model_nb, dfm_pp_test)

# Create a simple confusion matrix to check prediction accuracy:

table(Predicted = predictions_sent, Actual = sentiment_class[501:630])

# explanation for confusion matrix:
# for 18, the model predicted they were negative, but they were neutral
# for 3, the model predicted they were negative, but they were positive






#############################################################################
#############################################################################

#### Sentence Embeddings and Clustering

## using OpenAI

# We want to cluster our data into groups according to similar topics. 
# To do this, we can calculate the similarity (or distance) of the article headlines. 
# To do this, we need to calculate embeddings of the headings that encapsulate the meaning. 
# You can choose between different providers of embedding models. 

# install OpenAI package for Python
reticulate::py_install("openai")

# import Python Package
openai <- import("openai")

# retrieves the value of an environment variable named “openai.” to authenticate and make requests to OpenAI
# creates an instance of the OpenAI client
client <- openai$OpenAI(api_key = Sys.getenv("openai"))

# function(text, model = "text-embedding-3-small") defines a function called get_embeddings that takes two arguments:
# client$embeddings$create calls an external service
# result is expected to be a list, and the first element of the data field of this list contains the actual embedding
get_embeddings <- function(text, model = "text-embedding-3-small") {
  client$embeddings$create(input = text, model = model)$data[[1]]$embedding
}

# lapply function applies the get_embeddings function to each element in the FOX_clean$body
# resulting embeddings are stored in a list called embedd_ls
embedd_ls <- lapply(FOX_clean$body, get_embeddings)

# combines all the embeddings into a single matrix using do.call(rbind, embedd_ls)
embedd_openai <- do.call(rbind, embedd_ls)

# https://moj-analytical-services.github.io/NLP-guidance/LSA.html
# computes the cosine similarity between the embeddings
cos_embedd <- lsa::cosine(embedd_openai)


## using Huggingface

reticulate::py_install("sentence_transformers")

# sentence_transformers requires numpy
reticulate::py_install("numpy")

sentence_transformers <- import("sentence_transformers")

model <- sentence_transformers$SentenceTransformer("paraphrase-MiniLM-L6-v2")

embedd_huggingface <- model$encode(FOX_clean$body)








#############################################################################
#############################################################################

#### Clustering

# There are two main families of clustering algorithms: 
# 1. kmeans, where you specify the number of clusters in advance 
# 2. hierarchical clustering, where you set a cut-off value for the maximum 
# distance (or minimum similarity) for clustering

## kmeans clustering

cluster_kmeans <- kmeans(embedd_openai, 3)

FOX_clean$cluster_kmeans <- cluster_kmeans$cluster

# Visually inspect hierarchical clusters:

factoextra::fviz_cluster(cluster_kmeans,
                         data = embedd_openai,
                         geom = "point",
                         ellipse.type = "convex",
                         ggtheme = ggplot2::theme_bw()
)

## hierarchical clustering

fox_distance <- proxy::dist(embedd_openai, method = "cosine")

hcluster <- hclust(fox_distance)

FOX_clean$cluster_hier <- cutree(hcluster, h = 0.3)

# Visually inspect hierarchical clusters:

# hcluster$labels <- FOX_clean$body

# plot(hcluster, hang = -1)






#############################################################################
#############################################################################

library(dplyr)
library(reticulate)
library(tidyverse)
library(tidychatmodels)

#### Sentiment Analysis and Visualisation

# We want to extract the sentiment of the data to recognize patterns in the 
# reporting. Let's output the sentiment in the three categories Positive, 
# Negative and Neutral. You can choose between different language model providers. 

## Using OpenAI

# install OpenAI package for Python
reticulate::py_install("openai")

openai <- import("openai")

client <- openai$OpenAI(api_key = Sys.getenv("openai"))

# Using tidychatmodels, setting API key and system message:

library(tidychatmodels)

chat_model <- create_chat("openai", Sys.getenv("openai")) |>
  add_model("gpt-4o")

chat_system <- chat_model |>
  add_params("temperature" = 0.2, "max_tokens" = 5) |>
  add_message(
    role = "system",
    message = "I want you to answer just with positive, negative, or neutral."
  )

# API call
get_sentiment <- function(txt) {
  Sys.sleep(2)
  
  chat_system |>
    add_message(
      role = "user",
      message = txt
    ) |>
    perform_chat() |>
    extract_chat(silent = TRUE) |>
    filter(.data$role == "assistant") |>
    pull(message)
}

get_sentiment <- function(txt) {
  Sys.sleep(2)
  
  chat_system <- chat_system |>
    add_message(
      role = "user",
      message = txt
    ) |>
    perform_chat() |>
    extract_chat(silent = TRUE) |>
    filter(role == "assistant") |>
    pull(message)
}

fox_sentiment <- lapply(FOX_clean$body, get_sentiment)

# Convert the list of sentiments to a vector
fox_sentiment_vector <- unlist(fox_sentiment)

# Add the sentiment vector to data frame
FOX_clean$Sentiment <- fox_sentiment_vector

FOX_clean$sentiment_openai <- fox_sentiment


## using Huggingface
reticulate::py_install("transformers")

transformers <- import("transformers")

sentiment_pipeline <- transformers$pipeline("sentiment-analysis", model = "ahmedrachid/FinancialBERT-Sentiment-Analysis")

fox_sentiment_ls <- sentiment_pipeline(FOX_clean$body)

# Transform response from json to vector and add to data.frame
# fox_sentiment <- sapply(py$fox_sentiment_ls, function(x) x$label)
fox_sentiment <- sapply(fox_sentiment_ls, function(x) x$label)

FOX_clean$sentiment_huggingface <- fox_sentiment
