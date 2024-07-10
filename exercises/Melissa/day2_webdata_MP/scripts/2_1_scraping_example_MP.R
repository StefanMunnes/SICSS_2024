library(tidyverse)
library(rvest)
library(stringi)

html = read_html("https://time.com/search/?q=election&page=2")

urls <- html %>%
  html_nodes(".headline") %>%
  html_elements("a") %>%
  html_attr("href")

df.urls <- tibble(urls)

pg_nums <- c[1:5]



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