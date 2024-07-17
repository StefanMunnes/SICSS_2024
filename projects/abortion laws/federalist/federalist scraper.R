library(tidyverse)
library(rvest)
library(stringr)


## get urls 
url_head <- "https://thefederalist.com/page/"
url_tail <- "/?s=abortion"

search_results_urls <- paste0(url_head, 1:14, url_tail)

page <- search_results_urls[1]

get_article_urls <- function(page) {
  website_search <- read_html(page)
  
  urls_scraped <- website_search %>%
    html_nodes("h2.title-md a") %>%
    html_attr("href")
  
  return(urls_scraped)
  
  Sys.sleep(2)
}

article_urls <- lapply(search_results_urls, get_article_urls) |>
  unlist()
df.article_urls <- data.frame(article_urls)

# Loop --------------------------------------------------------------------
# Split the task, otherwise memory overload
# Issue: no end condition, loop will run into NA and break

# split urls list into smaller chunks, otherwise memory will run full and R will crash
groups <- gl(25, ceiling(nrow(df.article_urls)/25),nrow(df.article_urls))
url_batches <- split(df.article_urls,groups)


# cap number of articles 
row_max <- 20
row_now = 0

# loop over each batch, save data set immediately and delete data from previous
# batch to prevent R from crashing
for (batch in seq_along(url_batches)) {
  
  articles <- tibble()
  
  for (url in url_batches[[batch]]$article_urls) {
    
    # if(row_now >=row_max){
    #   cat("max article limit reached \n")
    #   break
    # }
    #^this code was breaking the whole loop
    
    Sys.sleep(runif(1)+1) #random sleep to avoid overwhelming server
    
    cat("Processing batch", batch, "URL:", url, "\n")
    
    website <- tryCatch({
      read_html(url)
    }, 
    error = function(e){
      return(NULL)
    })
    if(!is.null(website)){
      title <- website%>%
        html_node(".title-lg") %>%
        html_text2()
      
      author <- website%>%
        html_node(".article-meta-author") %>%
        html_element("span")%>%
        html_text2()
      
      datetime <- website%>%
        html_element("time")%>%
        html_attr("datetime")
      
      # Get body text
      # Select the div element
      
      target_div <- html_node(website, "div.article-body")
      
      # Extract the child elements of the target div
      child_elements <- html_children(target_div)
      
      # Initialize an empty vector to store the text
      text_vector <- c()
      
      # Loop through the child elements and extract text until <hr> is reached
      for (element in child_elements) {
        if (html_name(element) == "hr") {
          break  # Stop the loop if an <hr> element is found
        }
        text_vector <- c(text_vector, html_text(element, trim = TRUE))
      }
      
      # Combine the text into a single string or keep as a vector, based on your preference
      final_text <- paste(text_vector, collapse = " ")
      
      tmp <- tibble(title, author, datetime,final_text,url)
      print(tmp)
      articles <- rbind(articles, tmp)
      saveRDS(articles, file = paste0("federalist", batch, ".Rds"))
      
      row_now <- row_now + nrow(tmp)  # editing counter to new row number
      
    }
  }
  


#combine all saved results into one data frame
federalist <- bind_rows(lapply(seq_along(url_batches), function(i) {
  file_path <- paste0("federalist", i, ".Rds")
  if (file.exists(file_path)) {
    readRDS(file_path)
  } else {
    tibble()  # Return an empty tibble if the file does not exist
  }
  
}))

}

