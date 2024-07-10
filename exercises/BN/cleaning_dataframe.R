library(tidyverse)
library(lubridate)
library(stringr)

cnn_data <- readRDS("sessions/day3_data_cleanup/data/CNN_cleaning.Rds")

#split the authors columns and add them at the end
cnn_data[c("author 1", "author 2", "author 3", "author 4")] <- str_split_fixed(cnn_data$authors, ";", 4)

#reorder the columns
cnn_data <- cnn_data[c("title", "author 1", "author 2", "author 3", "author 4", "timestamp", "body", "url")]

#extract whether it was the date of publishing or update
published_or_updated <- str_extract_all(cnn_data$timestamp, "Published|Updated")

#extract weekday
weekday <- str_extract_all(cnn_data$timestamp, "(?<=EDT, )|(|?<=EST, )\\w{3}")
