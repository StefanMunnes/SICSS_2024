pacman::p_load(
  "rvest"
  ,"dplyr"
  ,"tidyr"
  ,"stringr"
  ,"stringi"
  ,"robotstxt"
  ,"urltools"
  ,"httr"
  ,"htmltools"
  ,"rlang"
  ,"tidyverse"
  ,"rvest"
  ,"xml2"
  ,"xlsx"
  ,"car"
  ,"stargazer"
  ,"spacyr"
  ,"reticulate"
  ,"forcats"
)

urls <- read.csv("vox_urls.csv")
head(urls)

df.urls <- data.frame(x=urls$X,urls=urls$urls)

url <- df.urls$urls[1]

# Loop --------------------------------------------------------------------
# Split the task, otherwise memory overload
# Issue: no end condition, loop will run into NA and break

# split urls list into smaller chunks, otherwise memory will run full and R will crash
groups <- gl(5, ceiling(nrow(df.urls)/5),nrow(df.urls))
url_batches <- split(df.urls,groups)


# cap number of articles 
row_max <- 20
row_now = 0

# loop over each batch, save data set immediately and delete data from previous
# batch to prevent R from crashing
for (batch in seq_along(url_batches)) {
  
  articles <- data.frame()
  
  for (url in url_batches[[batch]]$urls) {
    
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
      tmp <- data.frame(
        
        title <- website %>%
          html_element(".xkp0cg7")%>%
          html_text2(),
        
        author <- website %>%
          html_element("._15r56j10") %>%
          html_text2(),
        
        datetime <- website %>%
          html_element("time")%>%
          html_attr("datetime"),
        
        body <- website %>%
          html_nodes("._1agbrixt .duet--article--article-body-component p")%>%
          html_text2() %>%
          paste(collapse = " "),
        
        url <- url
      )
      print(tmp)
      articles <- rbind(articles, tmp)
      saveRDS(articles, file = paste0("VOX", batch, ".Rds"))
      
      row_now <- row_now + nrow(tmp)  # editing counter to new row number
      
    }
  }

}

  #combine all saved results into one data frame
  VOX <- bind_rows(lapply(seq_along(url_batches), function(i) {
    file_path <- paste0("VOX", i, ".Rds")
    if (file.exists(file_path)) {
      readRDS(file_path)
    } else {
      tibble()  # Return an empty tibble if the file does not exist
    }
  
}))



# remove duplicates
VOX <- VOX %>%
  distinct(.keep_all = TRUE)

# check if length is realistic
VOX <- VOX %>%
  mutate(article_length = str_length(body))

names(VOX)[1] <- "title"
names(VOX)[2] <- "author"
names(VOX)[3] <- "datetime"
names(VOX)[4] <- "body"
names(VOX)[5] <- "url"

# save as one file
write_csv(VOX, "~/vox_abortion.csv")
