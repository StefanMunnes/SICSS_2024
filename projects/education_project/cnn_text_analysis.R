library(dplyr)
library(reticulate)
library(xlsx)
library(ggplot2)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)

library(tidyverse)
library(lubridate)
library(stringr)

install.packages("FactoMineR")
library("FactoMineR")

if(!require(devtools)) install.packages("devtools")
devtools::install_github("kassambara/factoextra")

library("factoextra")


#miniconda_uninstall(path= "C:/Users/Lenovo/AppData/Local/r-miniconda")


use_python("C:/Users/Lenovo/anaconda3")

reticulate::py_config()
reticulate::py_available()

reticulate::py_install("transformers", pip = TRUE)
reticulate::py_install(c("torch", "sentencepiece"), pip = TRUE)



transformers <- reticulate::import("transformers")


sentiment_pipeline <- transformers$pipeline("sentiment-analysis", model = "ahmedrachid/FinancialBERT-Sentiment-Analysis")

#load data
cnn_data <- read.xlsx("projects/education_project/data/cnn_edineq_df_clean.xlsx", 1)

titles_sentiment_ls <- sentiment_pipeline(cnn_data$title)


# titles_sentiment
titles_sentiment <- sapply(titles_sentiment_ls, function(x) x["label"])

cnn_data$sentiment_huggingface <- titles_sentiment



#Visualze sentiments in Bar
library(ggplot2)

sentiment_counts <- cnn_data|>count(sentiment_huggingface)

colnames(sentiment_counts) <- c("Sentiment", "Count")
sentiment_counts_df <- sentiment_counts

sentiment_counts_df$Sentiment <- unlist(sentiment_counts_df$Sentiment)
sentiment_counts_df$Sentiment <- as.factor(sentiment_counts_df$Sentiment)
sentiment_counts_df$Count <- as.numeric(sentiment_counts_df$Count)

ggplot(data = sentiment_counts_df, aes(x = Sentiment, y = Count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Sentiment Distribution of CNN articles", x = "Sentiment", y = "Count") +
  theme_minimal()

#Visualize sentiments in Pie chart
ggplot(data = sentiment_counts_df, aes(x = "", y = Count, fill = Sentiment)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  labs(title = "Sentiment Proportion of CNN articles", fill = "Sentiment") +
  theme_minimal()





#Sentence transformers
reticulate::py_install("sentence-transformers")
py_install("huggingface_hub")


cnn_data <- read.xlsx("projects/education_project/data/cnn_edineq_df_clean.xlsx", 1)




sentence_transformers <- reticulate::import("sentence_transformers")

model <- sentence_transformers$SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

bodies_embeddings <- model$encode(cnn_data$body)#for CNN data




# Determine the optimal number of clusters using the elbow method
sse <- numeric()
list_k <- 1:10
#for cnn
for (k in list_k) {
  cluster_kmeans <- kmeans(bodies_embeddings, centers = k, nstart = 25)
  sse <- c(sse, cluster_kmeans$tot.withinss)
}



# Create a data frame for the elbow plot
elbow_data <- data.frame(k = list_k, sse = sse)

# Plot SSE against the number of clusters to find the elbow point
ggplot(elbow_data, aes(x = k, y = sse)) +
  geom_point() +
  geom_line() +
  labs(x = 'Number of clusters (k)', y = 'Sum of squared distances') +
  theme_minimal()



# Perform k-means clustering with the optimal number of clusters (e.g., k = 3)
optimal_k <- 3  # Replace with the optimal k found from the elbow plot
cluster_kmeans <- kmeans(bodies_embeddings, centers = optimal_k, nstart = 25)

cnn_data$cluster_kmeans <- cluster_kmeans$cluster


factoextra::fviz_cluster(cluster_kmeans,
                         data = bodies_embeddings,
                         geom = "point",
                         ellipse.type = "convex",
                         ggtheme = ggplot2::theme_bw()
)




#Cluster 1 top collocations 
corpus_1 <- corpus(cnn_data[cnn_data$cluster_kmeans==1,], text_field = "body")


tokens_1_pp <- tokens(
  corpus_1,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en"), padding = FALSE) |> # show padding
  tokens_wordstem(language = "en")

textstat_collocations(tokens_1_pp) |>
  head(15)



#Cluster 2 top collocations 
corpus_2 <- corpus(cnn_data[cnn_data$cluster_kmeans==2,], text_field = "body")


tokens_2_pp <- tokens(
  corpus_2,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en"), padding = FALSE) |> # show padding
  tokens_wordstem(language = "en")

textstat_collocations(tokens_2_pp) |>
  head(15)


#Cluster 3 top collocations 
corpus_3 <- corpus(cnn_data[cnn_data$cluster_kmeans==3,], text_field = "body")


tokens_3_pp <- tokens(
  corpus_3,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en"), padding = FALSE) |> # show padding
  tokens_wordstem(language = "en")

textstat_collocations(tokens_3_pp) |>
  head(15)



corpus_cnn <- corpus(cnn_data, text_field = "body")

tokens_cnn <- tokens(
  corpus_cnn,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en"), padding = FALSE) |> # show padding
  tokens_wordstem(language = "en")

dfm_cnn <- dfm(tokens_cnn)
head(dfm_cnn)

textstat_keyness(dfm_cnn, target = docvars(corpus_cnn, "cluster_kmeans") == "3") |>
  textplot_keyness()







#Fox analysis


fox_data <- readRDS("projects/education_project/FOX.Rds")

fox_data$body <- str_to_lower(fox_data$body, "\\w")
fox_data$body <- str_replace_all(fox_data$body, "\\s{2,}|\\n|^ | $", "")

bodies_embeddings_fox <- model$encode(fox_data$body)

#Fox kmeans clustering
sse <- numeric()
list_k <- 1:10
#for fox
for (k in list_k) {
  cluster_kmeans <- kmeans(bodies_embeddings_fox, centers = k, nstart = 25)
  sse <- c(sse, cluster_kmeans$tot.withinss)
}
# Create a data frame for the elbow plot
elbow_data <- data.frame(k = list_k, sse = sse)
#finding oprimal k value for fox
ggplot(elbow_data, aes(x = k, y = sse)) +
  geom_point() +
  geom_line() +
  labs(x = 'Number of clusters (k)', y = 'Sum of squared distances') +
  theme_minimal()

#kmeans clustering for fox
cluster_kmeans <- kmeans(bodies_embeddings_fox, centers = optimal_k, nstart = 25)

fox_data$cluster_kmeans <- cluster_kmeans$cluster


factoextra::fviz_cluster(cluster_kmeans,
                         data = bodies_embeddings_fox,
                         geom = "point",
                         ellipse.type = "convex",
                         ggtheme = ggplot2::theme_bw()
)

corpus_fox <- corpus(fox_data, text_field = "body")

#Cluster 1 top collocations 
corpus_1_fox <- corpus(fox_data[fox_data$cluster_kmeans==1,], text_field = "body")


tokens_1_pp_fox <- tokens(
  corpus_1_fox,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en"), padding = FALSE) |> # show padding
  tokens_wordstem(language = "en")

textstat_collocations(tokens_1_pp_fox) |>
  head(15)



#Cluster 2 top collocations 
corpus_2_fox <- corpus(fox_data[fox_data$cluster_kmeans==2,], text_field = "body")


tokens_2_pp_fox <- tokens(
  corpus_2_fox,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en"), padding = FALSE) |> # show padding
  tokens_wordstem(language = "en")

textstat_collocations(tokens_2_pp_fox) |>
  head(15)


#Cluster 3 top collocations 
corpus_3_fox <- corpus(fox_data[fox_data$cluster_kmeans==3,], text_field = "body")


tokens_3_pp_fox <- tokens(
  corpus_3_fox,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en"), padding = FALSE) |> # show padding
  tokens_wordstem(language = "en")

textstat_collocations(tokens_3_pp_fox) |>
  head(15)



tokens_fox <- tokens(
  corpus_fox,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en"), padding = FALSE) |> # show padding
  tokens_wordstem(language = "en")

dfm_1_pp_fox <- dfm(tokens_1_pp_fox)
head(dfm_1_pp_fox)

dfm_2_pp_fox <- dfm(tokens_2_pp_fox)
head(dfm_2_pp_fox)

dfm_3_pp_fox <- dfm(tokens_3_pp_fox)
head(dfm_3_pp_fox)

textstat_keyness(dfm_fox, target = docvars(corpus_fox, "cluster_kmeans") == "3") |>
  textplot_keyness()


write.xlsx(fox_data, "projects/education_project/data/fox_clusters.xlsx")
write.xlsx(cnn_data, "projects/education_project/data/cnn_clusters.xlsx")

#hierarchical clustering
