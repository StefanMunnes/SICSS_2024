if(!require("pacman")) install.packages("pacman")
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
url_head <- "https://www.motherjones.com/page/"
url_tail <- "/?s=abortion"
search_page_urls <- paste0(url_head,1:181,url_tail)

test_urls <- c(search_page_urls[169],search_page_urls[170], search_page_urls[171])

  
get_article_info <- function(url) {
  website_search <- read_html(url)
    
    urls_scraped <- website_search %>%
      html_nodes("li.article-item") %>%
      html_element(".hed a") %>%
      html_attr("href")
    
    title <- website_search %>%
      html_nodes("li.article-item") %>%
      html_element(".hed a") %>%
      html_text2()
    
    author <- website_search %>%
      html_nodes("li.article-item") %>%
      html_element(".byline a") %>%
      html_text()
    
    date <- website_search %>%
      html_nodes("li.article-item") %>%
      html_element(".dateline") %>%
      html_text()
    
    article_info <- tibble(urls=urls_scraped,titles=title,authors=author,date=date)
  print(article_info)
  return(article_info)
  
  Sys.sleep(2)
}



# Initialize the data frame outside the function
all_article_info <- tibble()

for (search_page_url in search_page_urls) {
  article_info <- get_article_info(test_url)
  df.article_info <- tibble(urls=article_info[[1]],title=article_info[[2]],author=article_info[[3]],date=article_info[[4]])
  all_article_info <- rbind(all_article_info,df.article_info)
}

all_article_info1 <- all_article_info %>%
  filter(author!="Mother Jones")

#remove articles with no specified author
all_article_info1 <- all_article_info %>%
  filter(!str_detect(author, 'Mother Jones'))

#add doc_id
all_article_info1$doc_id <- paste0("text",1:919)


#GET ARTICLE BODY----------------------------------------------------------

url <- all_article_info1$urls[4]

get_article_body <- function(url){

  page <- read_html(url)
  
  # Locate the <article> container
  article <- page %>%
    html_node("article")
  
  # Check if the <article> container exists
  if (!is.null(article)) {
    # Locate the <div class="asdf"> within the <article>
    div_start <- article %>%
      html_node("div.mj-text-cta")
    
    # Check if the <div class="mj-text-cta"> exists
    if (!is.null(div_start)) {
      # Find all <p> elements that are siblings of div.asdf and collect their text
      collected_text <- div_start %>%
        html_nodes(xpath = "./following-sibling::p") %>%
        html_text2() %>%
        paste0(collapse = "")
      
      # Print the collected text
      print(collected_text)
    } else {
      message("<div class='mf-text-cta'> not found within <article>")
    }
  } else {
    message("<article> container not found on the page")
  }
  return(collected_text)
  Sys.sleep(2)
}

#initialize empty tibble
mj_article_text <- tibble()

for (i in 1:2) {
  new_body <- get_article_body(all_article_info1$urls[i])
  new_article_text <- tibble(doc_id=all_article_info1$doc_id[i], body=new_body)
  mj_article_text <- bind_rows(mj_article_text,new_article_text)
  
}


# Loop --------------------------------------------------------------------
# Split the task, otherwise memory overload
# Issue: no end condition, loop will run into NA and break

# split urls list into smaller chunks, otherwise memory will run full and R will crash
groups <- gl(46, ceiling(nrow(all_article_info1)/46),nrow(all_article_info1))
url_batches <- split(all_article_info1,groups)


# cap number of articles 
row_max <- 20
row_now = 0

# loop over each batch, save data set immediately and delete data from previous
# batch to prevent R from crashing
for (batch in seq_along(url_batches)) {
  
  mj_article_text <- tibble()
  
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
      article <- page %>%
        html_node("article")
      
      # Check if the <article> container exists
      if (!is.null(article)) {
        # Locate the <div class="asdf"> within the <article>
        div_start <- article %>%
          html_node("div.mj-text-cta")
        
        # Check if the <div class="mj-text-cta"> exists
        if (!is.null(div_start)) {
          # Find all <p> elements that are siblings of div.asdf and collect their text
          collected_text <- div_start %>%
            html_nodes(xpath = "./following-sibling::p") %>%
            html_text2() %>%
            paste0(collapse = "")
          
          # Print the collected text
          print(collected_text)
        } else {
          message("<div class='mf-text-cta'> not found within <article>")
        }
      } else {
        message("<article> container not found on the page")
      }
      
      
      tmp <- tibble(url,collected_text)
      print(tmp)
      mj_article_text <- rbind(mj_article_text, tmp)
      saveRDS(mj_article_text, file = paste0("mj", batch, ".Rds"))
      
      row_now <- row_now + nrow(tmp)  # editing counter to new row number
      
    }
  }
}
  
  
  #combine all saved results into one data frame
  all_mj_article_text <- bind_rows(lapply(seq_along(url_batches), function(i) {
    file_path <- paste0("mj", i, ".Rds")
    if (file.exists(file_path)) {
      readRDS(file_path)
    } else {
      tibble()  # Return an empty tibble if the file does not exist
    }
    
  }))
  
write.csv(all_mj_article_text,"~/SICSS/SICSS_2024/projects/abortion laws/mother_jones/mj_article_body.csv")
