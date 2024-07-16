library(tidyverse)
library(rvest)

#urls <- scan("~/SICSS_2024/projects/abortion laws/cnn_urls.csv", character(), quote = "")
urls <- read.csv("~/SICSS_2024/projects/abortion laws/cnn_urls.csv")
head(urls)

url <- urls$x[[1]]


# Loop --------------------------------------------------------------------
# Split the task, otherwise memory overload
# Issue: no end condition, loop will run into NA and break

# split urls list into smaller chunks, otherwise memory will run full and R will crash
url_groups <- split(urls$x, ceiling(seq_along(urls$x) / 300))


# cap number of articles 
row_max <- 200
row_now = 0


# loop over each batch, save data set immediately and delete data from previous
# batch to prevent R from crashing
for (batch in seq_along(url_groups)) {
 
  articles <- data.frame()
  
  for (url in url_groups[[batch]]) {

    if(row_now >=row_max){
      cat("max article limit reached \n")
      break
    }
    
    Sys.sleep(runif(1)+1)
    
    print(paste(batch, url))
    
    website <- tryCatch({
      read_html(url)
      }, 
      error = function(e){
        return(NULL)
        })
    if(!is.null(website)){
      tmp <- tibble(
      title = website %>%
        html_node("#maincontent") %>%
        html_text(),
      
      authors = website %>%
        html_nodes(".byline__name, .byline__names") %>%
        html_text() %>%
        paste(collapse = ";"),
      
      timestamp = website %>%
        html_nodes(".timestamp") %>%
        html_text(),
      
      body = website %>%
        html_nodes(".paragraph") %>%
        html_text() %>%
        paste(collapse = ""),
      
      url = url
    )
    
    articles <- rbind(articles, tmp)
    saveRDS(articles, file = paste0("CNN", batch, ".Rds"))
   
    row_now <- row_now + nrow(tmp)  # editing counter to new row number
    
  }
  }
  if (row_now >= row_max) {
    break
  }
}


# Append CNN articles
CNN <- data.frame()
for (i in seq_along(url_groups)) {
  tmp <- rbind(CNN, readRDS(paste0("CNN", i, ".Rds")))
  CNN <- tmp
}

# remove duplicates
CNN <- CNN %>%
  distinct(.keep_all = TRUE)

# check if length is realistic
CNN <- CNN %>%
  mutate(article_length = str_length(body))

# save as one file
# saveRDS(CNN, file = "data/CNN_trump.Rds")
write_csv(CNN, "~/SICSS_2024/projects/abortion laws/cnn_abortion.csv")