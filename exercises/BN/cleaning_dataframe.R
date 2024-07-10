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
weekday <- str_extract_all(cnn_data$timestamp, "(?<=EDT, )\\w{3}|(?<=EST, )\\w{3}")

#extract date
date_strings <- str_extract_all(cnn_data$timestamp, "\\w+ \\d{1,2}, \\d{4}")
print(date_strings)

#convert to date object
date_objects <- mdy(date_strings)
print(date_objects)

#convert the date format
formatted_date <- format(date_objects, "%e.%m.%Y")

#trim spaces
formatted_date <- str_replace_all(formatted_date, " ", "")
print(formatted_date)


#convert to data frame
date_df <- data.frame(date = formatted_date)


#remove excessive white spaces in titles
cnn_data$title <- str_replace_all(cnn_data$title, "\\s{2,}|\\n|^ | $", "")


#remove excessive white spaces in bodies
cnn_data$body <- str_replace_all(cnn_data$body, "\\s{2,}|\\n|^ | $", "")


#remove all capitalization from titles
cnn_data$title <- str_to_lower(cnn_data$title, "\\w")


#remove all capitalization from bodies
cnn_data$body <- str_to_lower(cnn_data$body, "\\w")


