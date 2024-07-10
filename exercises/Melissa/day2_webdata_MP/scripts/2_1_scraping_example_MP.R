library(tidyverse)
library(rvest)
library(stringi)

base_html = "https://time.com/search/?q=election&page="
pages <- paste0(base_html,1:5)
print(pages)

all_article_urls <- tibble()

for (page in pages) {
  url <- read_html(page)
  
  article_urls <- url %>%
    html_nodes(".headline") %>%
    html_elements("a") %>%
    html_attr("href") %>%
    list()
  
  all_article_urls <- rbind(all_article_urls,article_urls)
  
}

print(all_article_urls)
 
#df.urls <- tibble(urls)

get_article_info = function(html) {
  url <- read_html("https://time.com/6995779/france-macron-disastrous-election/")
  
  title <- url %>%
    html_nodes("header") %>%
    html_elements("h1")%>%
    html_text()
  
  author <- url %>%
    html_node(".inline-block .font-bold") %>%
    html_text()
  
  date <- url %>%
    html_node("time") %>%
    html_attr("datetime") %>%
    str_sub(1,10)
  
  text <- url %>%
    html_nodes("p.self-baseline") %>%
    html_text()
  
  new_article_info <- tibble(title, author, date, text)
  
  Sys.sleep(2)
}

colnames(all_article_urls)[1] <- "all_article_urls"
article_data <- tibble()

for (i in 1:45) {
  html <- all_article_urls[i]
  new_data <- get_article_info(html)
  
  df.new_data <- tibble(new_data)
  
  rbind(article_data,new_data)
  
}

