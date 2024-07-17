library(dplyr)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)


data_cnn <- readRDS("exercises/Jing Zhou/data/cnnurls.Rds")


corpus <- corpus(data_cnn, text_field = "body")

head(summary(corpus))

tokens <- tokens(corpus)
head(tokens)

dfm <- dfm(tokens) # DFM, without pre-processing
head(dfm)
dim(dfm)

topfeatures(dfm, 10)
textstat_frequency(dfm, n = 10)

stopwords("en")

tokens_pp <- tokens(
  corpus,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en"), padding = FALSE) # show padding
  #tokens_wordstem(language = "en")

dfm_pp <- dfm(tokens_pp)
head(dfm_pp)
dim(dfm_pp)

textstat_frequency(dfm_pp, n = 10)

dfm_pp <- dfm_trim(dfm_pp, min_termfreq = 2, termfreq_type = "count")
dim(dfm_pp)

#tf-idf
dfm_pp_tfidf <- dfm_tfidf(dfm_pp)
top_features<-topfeatures(dfm_pp_tfidf, n = 10, groups = docnames(dfm_pp_tfidf))

# data clustering
install.packages("factoextra")
library(cluster)
library(factoextra)


tfidf_matrix <- as.matrix(dfm_pp_tfidf)


k <- 10


set.seed(123) 
kmeans_result <- kmeans(tfidf_matrix, centers = k, nstart = 25)


print(kmeans_result)


fviz_cluster(kmeans_result, data = tfidf_matrix,
             geom = "point",
             ellipse.type = "convex",
             palette = "jco",
             ggtheme = theme_minimal())


data_cnn$cluster <- kmeans_result$cluster


head(data_cnn)

#lda
library(quanteda)

library(LDAvis)
library(ggplot2)
library(wordcloud)
library(quanteda.textmodels)
library(seededlda)


lda_model <- textmodel_lda(dfm_pp, k = 10)



topic_terms <- terms(lda_model, 50)
topic_terms



# 提取主题术语分布
phi <- lda_model$phi

phi
# 提取文档主题分布
theta <- lda_model$theta

theta
# 计算每个文档的长度（文档中词汇的总数）
doc_length <- rowSums(dfm_pp)

doc_length
# 词汇表
vocab <- colnames(dfm_pp)

# 词汇频率
term_frequency <- colSums(dfm_pp)
term_frequency

# 准备LDAvis所需的数据
lda_data <- list(
  phi = phi,
  theta = theta,
  doc.length = doc_length,
  vocab = vocab,
  term.frequency = term_frequency
)

# 创建LDAvis可视化
json_lda <- createJSON(phi = lda_data$phi,
                       theta = lda_data$theta,
                       doc.length = lda_data$doc.length,
                       vocab = lda_data$vocab,
                       term.frequency = lda_data$term.frequency)

serVis(json_lda, out.dir = 'vis', open.browser = TRUE)
