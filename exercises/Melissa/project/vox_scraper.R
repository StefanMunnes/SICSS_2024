library(tidyverse)
library(rvest)
library(stringr)


# get urls 
url_base <- "https://www.vox.com/search?q=abortion&page="

url_all <- c()

for (i in 1:10) {
  print(i)
  url_all <- append(url_all, paste0(url_base, as.character(i)))
}


paste0(url_base, 1:10)


# 

get_urls_scraped <- function(url) {
  website_search <- read_html(url)
  
  urls_scraped <- website_search %>%
    html_nodes(".qcd9z1") %>%
    html_attr("href")
  
  return(urls_scraped)
  
  Sys.sleep(2)
}

all_urls <- lapply(url_all, get_urls_scraped) |>
  unlist()
