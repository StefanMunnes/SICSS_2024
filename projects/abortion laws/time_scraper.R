library(tidyverse)
library(rvest)
library(stringi)


get_urls <- function(page) {
  website_search <- read_html(paste0("https://time.com/search/?q=abortion&page=", page))
  
  urls <- website_search %>%
    html_nodes(".media-heading a") %>%
    html_attr("href")
  
  Sys.sleep(20)
  return(urls)
}

all_urls <- lapply(1:11, get_urls) %>%
  unlist()


get_all_articles <- function(url) {
  print(paste(url, all_urls[[url]]))
  website <- read_html(all_urls[[url]])
 
   article <- tibble(
    title = website %>%
      html_node("#article-header .self-baseline, .longform-headline") %>%
      html_text(),
    
    author = website %>%
      html_nodes(".inline-block a.font-bold, #article-body .font-bold") %>%
      html_text() %>%
      paste(collapse = ";"),
    
    tags = website %>%
      html_nodes("#article-header a") %>%
      html_text() %>%
      paste(collapse = ";"),
    
    date = website %>%
      html_node("time") %>%
      html_text(),
    
    body = website %>%
      html_nodes("#article-body p, p") %>%
      html_text() %>%
      paste(collapse = " "),
    
    url = all_urls[[url]]
  )
  return(article)   
  Sys.sleep(2)
}

# Exectute the function for all URLs previously collected
all_articles <- lapply(seq_along(all_urls), get_all_articles) 

# Transform lists to data frame
abortion <- bind_rows(all_articles)

# Save as csv
write_csv(abortion, "~/SICSS_2024/projects/abortion laws/time_abortion.csv")

