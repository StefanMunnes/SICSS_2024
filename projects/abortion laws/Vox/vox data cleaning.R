library(tidyverse)
library(stringr)

# DATA CLEANING------------------------------------

data <- vox_abortion %>% 
  na.omit(data)

data <- separate_wider_delim(data,author," ",names = c("name","rest of name"),too_many = "merge")

# GENDER PROCESSING ----------------------------------
vox_names <- data$name %>% 
  unique()
vox_names_gender <- gender(vox_names,years=2012,method="ssa")

data_gender <- left_join(data,vox_names_gender,relationship = "many-to-many")

data_gender <- data_fed[!is.na(data_gender$gender), ]
write.csv(data_gender,"~/SICSS/SICSS_2024/projects/abortion laws/prepared_article_data/vox_article_data.csv")
