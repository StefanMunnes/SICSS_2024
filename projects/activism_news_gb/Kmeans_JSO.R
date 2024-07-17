library(readr)
library(sentence)
library(reticulate)
library(dplyr)
library(factoextra)
library(quanteda.textmodels)
library(seededlda)


df_just_stop_oil <- read_csv("projects/activism_news_gb/dataframe_just_stop_oil.csv")

JSP_embeddings_titl <- read.csv("/Users/ilaria.vitulano/Documents/Weizenbaum/Learning/SICSS/SICSS_2024/projects/activism_news_gb/JSOemb.csv", header = FALSE)

# K means 3
cluster_kmeans3 <- kmeans(JSP_embeddings_titl, 3)

df_just_stop_oil$cluster_kmeans3 <- cluster_kmeans3$cluster

factoextra::fviz_cluster(cluster_kmeans3,
                         data = JSP_embeddings_titl,
                        geom = "point",
                         ellipse.type = "convex",
                         ggtheme = ggplot2::theme_bw()
)

write.csv(df_just_stop_oil, file = "/Users/ilaria.vitulano/Documents/Weizenbaum/Learning/SICSS/SICSS_2024/projects/activism_news_gb/topicsANDclusters_JSO_3.csv")

# K means 5

cluster_kmeans5 <- kmeans(JSP_embeddings_titl, 5)

df_just_stop_oil$cluster_kmeans5 <- cluster_kmeans5$cluster

factoextra::fviz_cluster(cluster_kmeans5,
                         data = JSP_embeddings_titl,
                         geom = "point",
                         ellipse.type = "convex",
                         ggtheme = ggplot2::theme_bw()
)

write.csv(df_just_stop_oil, file = "/Users/ilaria.vitulano/Documents/Weizenbaum/Learning/SICSS/SICSS_2024/projects/activism_news_gb/topicsANDclusters_JSO_5.csv")
