
# project work: web scraping and sentiment analysis on abortion laws in the US

# Research questions: how are abortions and associated laws framed by newspaper outlets, 
# conservative versus more liberal ones? 


# try scraping the Wall Street Journal and associated articles on "abortion"

library(tidyverse)
library(rvest)
library(stringr)


# get urls 
url_base <- "https://www.zeit.de/suche/index?q=abtreibung&p="

url_all <- c()

for (i in 1:316) {
  print(i)
  url_all <- append(url_all, paste0(url_base, as.character(i)))
}


paste0(url_base, 1:316)

url_list <- url_all

# 

get_urls_scraped <- function(url) {
  website_search <- read_html(url)
  
  urls_scraped <- website_search |> 
    html_nodes("a.zon-teaser__link") |> 
    html_attr("href")
  
  return(urls_scraped)
  
  Sys.sleep(2)
}

all_urls <- lapply(url_list, get_urls_scraped) |>
  unlist()

# get everything

get_all_articles <- function(url) {
  print(paste(url, all_urls[[url]]))
  website <- read_html(all_urls[[url]])
  article <- tibble(
    title = website |>
      html_node("#article-header .self-baseline, .longform-headline") %>%
      html_text(),
    
    author = website |>
      html_nodes(".inline-block a.font-bold, #article-body .font-bold") %>%
      html_text() |>
      paste(collapse = ";"),
    
    tags = website |>
      html_nodes("#article-header a") |>
      html_text() |>
      paste(collapse = ";"),
    
    date = website |> 
      html_node("time") |> 
      html_text(),
    
    body = website |>
      html_nodes("#article-body p, p") |>
      html_text() |>
      paste(collapse = " "),
    
    url = all_urls[[url]]
  )
  return(article)   
  Sys.sleep(2)
}



