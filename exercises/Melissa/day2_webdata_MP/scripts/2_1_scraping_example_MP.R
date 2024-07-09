library(tidyverse)
library(rvest)
library(stringi)

html = read_html("https://time.com/6995779/france-macron-disastrous-election/")

#urls <- html %>%
#  html_nodes("a.media-img") %>%
#  html_element("href")

title <- html %>%
  html_nodes("header") %>%
  html_elements("h1")%>%
  html_text()

author <- html %>%
  html_node(".inline-block .font-bold") %>%
  html_text()

date <- html %>%
  html_node("time") %>%
  html_attr("datetime") %>%
  str_sub(1,10)

text <- html %>%
  html_nodes("p.self-baseline") %>%
  html_text()