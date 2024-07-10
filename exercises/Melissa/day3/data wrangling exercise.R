library(tidyverse)

manip_data <- CNN_cleaning %>%
  separate_wider_delim(authors,delim = ";",names_sep = "", too_few = "align_start")%>%
  mutate(across(where(is.character), str_trim))%>%
  separate_wider_regex(cols = timestamp,patterns = c(status = ".+","\\s+.+,\\s",weekday = "\\w{3}","\\s",new_date = ".+"))