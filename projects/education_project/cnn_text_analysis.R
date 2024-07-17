library(dplyr)
library(reticulate)
library(tidyverse)
library(lubridate)
library(stringr)
library(xlsx)


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
fox_data <- read.xlsx("")

data_news <- bind_rows(
  list("fox" = data_fox, "cnn" = data_cnn),
  .id = "source"
)


sentence_transformers <- reticulate::import("sentence_transformers")


