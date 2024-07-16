library(tidyverse)
library(lubridate)
library(stringr)

cnn_data <- read.xlsx("projects/education_project/cnn_edineq_df.xlsx", 1)

#remove excessive white spaces in titles
cnn_data$title <- str_replace_all(cnn_data$title, "\\s{2,}|\\n|^ | $", "")


#remove excessive white spaces in bodies
cnn_data$body <- str_replace_all(cnn_data$body, "\\s{2,}|\\n|^ | $", "")


#remove all capitalization from titles
cnn_data$title <- str_to_lower(cnn_data$title, "\\w")


#remove all capitalization from bodies
cnn_data$body <- str_to_lower(cnn_data$body, "\\w")

#remove 'By ' from author
cnn_data$author <- str_replace_all(cnn_data$author, "By |Opinion by |Analysis by |\\s{2,}|\\n|^\\s+|\\s+$", "")


#leave only date in the date column
cnn_data$date <- str_extract_all(cnn_data$date, "\\w+ \\d{1,2}, \\d{4}")|>
  mdy()|>
  format("%e.%m.%Y")|>
  str_replace_all(" ", "")


write_csv(cnn_data, "projects/education_project/data/cnn_edineq_df_clean.csv")
write.xlsx(cnn_data, "projects/education_project/data/cnn_edineq_df_clean.xlsx")
