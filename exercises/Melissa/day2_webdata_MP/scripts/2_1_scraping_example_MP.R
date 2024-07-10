library(tidyverse)
library(rvest)
library(stringi)

base_html = "https://time.com/search/?q=election&page="
pages <- paste0(base_html,1:5)
print(pages)

all_article_urls <- c()

for (page in pages) {
  url <- read_html(page)
  
  article_urls <- url %>%
    html_nodes(".headline") %>%
    html_elements("a") %>%
    html_attr("href")
  
  all_article_urls <- append(all_article_urls,article_urls)
  
}

print(all_article_urls)
 
#df.urls <- tibble(urls)

get_article_info = function(html) {
  url <- read_html(html)
  
  title <- url %>%
    html_nodes("header") %>%
    html_elements("h1")%>%
    html_text()
  
  author <- url %>%
    html_node("#article-body a.font-bold") %>%
    html_text()
  
  date <- url %>%
    html_node("time") %>%
    html_attr("datetime") %>%
    str_sub(1,10)
  
  texts <- url %>%
    html_nodes("p.self-baseline") %>%
    html_text() %>%
    paste(collapse = ";")
  
  article_info <- tibble(html, title, author, date, texts)
  return(article_info)
  print(article_info)
  
  Sys.sleep(2)
}

all_article_data <- tibble()

for (all_article_url in all_article_urls) {
  new_data <- get_article_info(all_article_url)
  all_article_data <- rbind(all_article_data,new_data)
}



