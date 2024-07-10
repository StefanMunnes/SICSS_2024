library(tidyverse)

manip_data <- CNN_cleaning %>%
  separate_wider_delim(authors,delim = ";",names_sep = "", too_few = "align_start")

rexp <- "^(\\w+)\\s?(.*)$" 

manip_data1 <- manip_data %>%
  separate_wider_delim(timestamp,delim = "   ",names = c("status","timestamp"), too_many = "merge")%>%
  separate_wider_delim(timestamp,delim = ",", names = c("discard","date"), too_many = "merge")%>%
  mutate(across(where(is.character), str_trim))%>%
  separate_wider_regex(cols = date,patterns = c(weekday = "\\w{3}","\\s",new_date = ".+"),too_few = "align_start")

