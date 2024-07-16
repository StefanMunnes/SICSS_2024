library(tidyverse)
library(rvest)
library(xml2)

# What we want:
# Title: #maincontent
# Authors: .byline__name   (Achtung: can be multiple names!)
# Date: .timestamp
# Text: .paragraph

urls <- scan("foxurls_abortion.txt", character(), quote = "")
urls <- unique(urls)

# Testrun -----------------------------------------------------------------
website <- read_html(urls[640])

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
  readRDS("FOX2.Rds")
  )

# remove duplicates in the body column
FOX <- FOX %>%
  distinct(body, .keep_all = TRUE)

# check if length is realistic
FOX <- FOX %>%
  mutate(article_length = str_length(body))

# safety copy
FOX_OG <- FOX

# save as one file
saveRDS(FOX, file = "FOX_abortion.Rds")







#### Data cleaning
# remove ";Fox News" or "Fox News"
FOX$authors <- gsub(";Fox News|Fox News", "", FOX$authors)

# set empty author fields as NAs
FOX$authors <- ifelse(FOX$authors == "", NA, FOX$authors)

# remove Dr. and Rep.
FOX$authors <- gsub("Dr. |Rep. ", NA, FOX$authors)

# replace "Staff", "Associated Press", "OutKick" by NA
FOX$authors <- gsub("Staff|Associated Press|OutKick", NA, FOX$authors)


# split up authors entry by ";", create a new column for each new author
# rename new columns with "author" and count
# if there are too few authors, too_few = "align_start" fills remaining columns with NAs 
FOX_clean <- FOX %>%
  separate_wider_delim(authors, 
                       delim = ";", 
                       names_sep = "", 
                       too_few = "align_start", # aligns starts of short matches, adding NA on the end to pad to the correct length.
                       cols_remove = TRUE) %>%
  rename_with(~sub("authors", "author", .), starts_with("authors"))

# safety copy
FOX_clean_OG <- FOX_clean






## get the first names of the authors and save them into a new column
# Create a list of columns to duplicate

columns_to_duplicate <- colnames(FOX_clean)[grepl("author", colnames(FOX_clean))]

# Duplicate the columns
for (col in columns_to_duplicate) {
  new_col_name <- paste0(col, "_firstname")
  FOX_clean[[new_col_name]] <- FOX_clean[[col]]
  FOX_clean[[new_col_name]] <- word(FOX_clean[[new_col_name]], 1)
}


## predicting gender based on first names

library("gender")
# install.packages("remotes")
# remotes::install_github("lmullen/genderdata")

library(genderdata)
data(package = "genderdata")


