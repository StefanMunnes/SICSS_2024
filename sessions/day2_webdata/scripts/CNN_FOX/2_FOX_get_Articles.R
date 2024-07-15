library(tidyverse)
library(rvest)

# What we want:
# Title: #maincontent
# Authors: .byline__name   (Achtung: can be multiple names!)
# Date: .timestamp
# Text: .paragraph

urls <- scan("data/foxurls_biden2.txt", character(), quote = "")
urls <- unique(urls)

# Testrun -----------------------------------------------------------------
website <- read_html(urls[857])
test <- tibble(
  title = website %>%
    html_node(".headline") %>%
    html_text(),
  
  authors = website %>%
    html_nodes(".author-byline a") %>%
    html_text()  %>%
    paste(collapse = ";"),
  
  timestamp = website %>%
    html_nodes("time") %>%
    html_text(),
  
  body = website %>%
    html_nodes(".article-body p") %>%
    html_text() %>%
    paste(collapse = ""),
  
  #url = url
)


# Loop --------------------------------------------------------------------
# Split the task, otherwise memory overload
# split urls list into smaller chunks, otherwise memory will run full and R will crash
url_groups <- split(urls, ceiling(seq_along(urls) / 350))

for (batch in 1:3) {
  
  articles <- data.frame()
  
  for (url in url_groups[[batch]]) {    
    Sys.sleep(runif(1)+sample(1:2, 1))
    
    print(paste(batch, url))
    
    website <- read_html(url)
    
    tmp <- tibble(
      title = website %>%
        html_node(".headline") %>%
        html_text(),
      
      authors = website %>%
        html_nodes(".author-byline a") %>%
        html_text()  %>%
        paste(collapse = ";"),
      
      timestamp = website %>%
        html_nodes("time") %>%
        html_text(),
      
      body = website %>%
        html_nodes(".article-body p") %>%
        html_text() %>%
        paste(collapse = ""),
      
      url = url
    )
    
    articles <- rbind(articles, tmp)
  }
  saveRDS(articles, file = paste0("FOX", batch, ".Rds"))
}

# Append FOX articles
FOX <- rbind(
  readRDS("FOX1.Rds"),
  readRDS("FOX2.Rds"),
  readRDS("FOX3.Rds")
  )

# remove duplicates
FOX <- FOX %>%
  distinct(.keep_all = TRUE)

# check if length is realistic
FOX <- FOX %>%
  mutate(article_length = str_length(body))

# save as one file
saveRDS(FOX, file = "data/FOX_biden.Rds")


