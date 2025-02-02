library(readr)
library(reticulate)
library(dplyr)
library(factoextra)
library(quanteda.textmodels)
library(seededlda)

# 
df_BBC <- read_csv("projects/activism_news_gb/bbc_df_clean.csv")

# split them
df_bbc_jso <- subset(df_BBC, just_stop_oil == 1)
df_bbc_bench <- subset(df_BBC, just_stop_oil == 0)

write.csv(df_bbc_jso, file = "/Users/ilaria.vitulano/Documents/Weizenbaum/Learning/SICSS/SICSS_2024/projects/activism_news_gb/BBC_only_JSO.csv")

BBC_embeddings_titl <- read.csv("/Users/ilaria.vitulano/Documents/Weizenbaum/Learning/SICSS/SICSS_2024/projects/activism_news_gb/BBCemb.csv", header = FALSE)

# K means with 5
cluster_kmeans5 <- kmeans(BBC_embeddings_titl, 5)

df_bbc_jso$cluster_kmeans5 <- cluster_kmeans5$cluster

factoextra::fviz_cluster(cluster_kmeans5,
                         data = BBC_embeddings_titl,
                         geom = "point",
                         ellipse.type = "convex",
                         ggtheme = ggplot2::theme_bw()
)

write.csv(df_bbc_jso, file = "/Users/ilaria.vitulano/Documents/Weizenbaum/Learning/SICSS/SICSS_2024/projects/activism_news_gb/topicsANDclusters_BBC_5.csv")



# K means with 3
cluster_kmeans3 <- kmeans(BBC_embeddings_titl, 3)

df_bbc_jso$cluster_kmeans3 <- cluster_kmeans3$cluster

factoextra::fviz_cluster(cluster_kmeans3,
                         data = BBC_embeddings_titl,
                         geom = "point",
                         ellipse.type = "convex",
                         ggtheme = ggplot2::theme_bw()
)

write.csv(df_bbc_jso, file = "/Users/ilaria.vitulano/Documents/Weizenbaum/Learning/SICSS/SICSS_2024/projects/activism_news_gb/topicsANDclusters_BBC_3.csv")

