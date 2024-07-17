library(readr)
library(sentence)
library(reticulate)
library(dplyr)
library(factoextra)

library(quanteda.textmodels)
library(seededlda)

from sentence_transformers import SentenceTransformer
df_just_stop_oil <- read_csv("projects/activism_news_gb/dataframe_just_stop_oil.csv")

JSP_embeddings_titl <- read.csv("/Users/ilaria.vitulano/Documents/Weizenbaum/Learning/SICSS/SICSS_2024/projects/activism_news_gb/JSOemb.csv", header = FALSE)

# K means
cluster_kmeans <- kmeans(JSP_embeddings_titl, 5)

df_just_stop_oil$cluster_kmeans <- cluster_kmeans$cluster

factoextra::fviz_cluster(cluster_kmeans,
                         data = JSP_embeddings_titl,
                        geom = "point",
                         ellipse.type = "convex",
                         ggtheme = ggplot2::theme_bw()
)

# LDA
# Install and load necessary packages
install.packages("tm")
install.packages("topicmodels")
install.packages("tidyverse")
install.packages("DBI")
install.packages("RSQLite")
install.packages("SnowballC")

library(tm)
library(topicmodels)
library(tidyverse)
library(DBI)
library(RSQLite)
library(SnowballC)

# Connect to the database
con <- dbConnect(RSQLite::SQLite(), df_just_stop_oil = "JSO.db")

# Query the "title" column from your table
dataforLDA <- dbGetQuery(con, "SELECT title FROM df_just_stop_oil")

# Disconnect from the database
dbDisconnect(con)

# Convert titles to a corpus
corpus <- Corpus(VectorSource(data$title))

# Text preprocessing
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removeWords, stopwords("english"))
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, stemDocument)

# Create a Document-Term Matrix
dtm <- DocumentTermMatrix(corpus)

# Remove sparse terms
dtm <- removeSparseTerms(dtm, 0.99)

# Set the number of topics
num_topics <- 5

# Run LDA
lda_model <- LDA(dtm, k = num_topics, control = list(seed = 1234))

# Display the top terms for each topic
topics <- terms(lda_model, 5)
print(topics)

# Get the topic distribution for each document
topic_distribution <- as.matrix(posterior(lda_model)$topics)

# Print the topic distribution for the first few documents
head(topic_distribution)