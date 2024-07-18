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
search_page_urls <- tibble(urls=paste0(url_head,1:181,url_tail))

search_groups <- gl(15, ceiling(nrow(search_page_urls)/15),nrow(search_page_urls))
search_batches <- split(search_page_urls,search_groups)

  
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
  
  Sys.sleep(3)
}


row_max <- 20
row_now = 0

# COLLECT URL LOOP-----------------------------
all_article_info <- tibble()

for (batch in seq_along(search_batches)) {
  
  print(paste0("Processing batch", batch))
  
  Sys.sleep(5)
  
  for (url in search_batches[[batch]]$urls) {

  article_info <- get_article_info(url)
  all_article_info <- bind_rows(all_article_info,article_info)
}}

# Clean article info
all_article_info <- all_article_info1 %>%
  unique() %>%
  filter(!(authors == "Mother Jones" | is.na(authors)))


#add doc_id
all_article_info$doc_id <- paste0("text",1:3419)

write.csv(all_article_info,"mj_article_info.csv")

#GET ARTICLE BODY----------------------------------------------------------

test_urls <- all_article_info1$urls[1:4]

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
      
      body <- tibble(url,collected_text)
      
      # Print the collected text
      print(body)
    } else {
      message("<div class='mf-text-cta'> not found within <article>")
    }
  } else {
    message("<article> container not found on the page")
  }
  return(body)
  Sys.sleep(2)
}


# for (i in 1:2) {
#   new_body <- get_article_body(all_article_info1$urls[i])
#   new_article_text <- tibble(doc_id=all_article_info1$doc_id[i], body=new_body)
#   mj_article_text <- bind_rows(mj_article_text,new_article_text)
#   
# }


# Loop --------------------------------------------------------------------
# Split the task, otherwise memory overload
# Issue: no end condition, loop will run into NA and break

# split urls list into smaller chunks, otherwise memory will run full and R will crash
groups <- gl(178, ceiling(nrow(all_article_info)/178),nrow(all_article_info))
url_batches <- split(all_article_info,groups)


# cap number of articles 
row_max <- 20
row_now = 0

# loop over each batch, save data set immediately and delete data from previous
# batch to prevent R from crashing

mj_article_text <- tibble()
counter <- 1

for (batch in seq_along(url_batches)) {
  message(paste0("Begin batch ", batch))
  for (url in url_batches[[batch]]$urls) {
    Sys.sleep(runif(1) + 1) # Random sleep to avoid overwhelming the server
    message(paste0("Processing text",counter))
    # Try to read the HTML of the URL
    website <- tryCatch({
      read_html(url)
    }, 
    error = function(e) {
      return(NULL)
    })
    
    # Check if the website was successfully read
    if (!is.null(website)) {
      article <- website %>%
        html_node("article")
      
      # Check if the <article> container exists
      if (!is.null(article)) {
        # Locate the <div class="mj-text-cta"> within the <article>
        div_start <- article %>%
          html_node("div.mj-text-cta")
        
        # Check if the <div class="mj-text-cta"> exists
        if (!is.null(div_start)) {
          # Find all <p> elements that are siblings of div.mj-text-cta and collect their text
          collected_text <- div_start %>%
            html_nodes(xpath = "./following-sibling::p") %>%
            html_text2() %>%
            paste0(collapse = "")
          
          # # Check length
          # article_length <- stri_length(collected_text)
          # if(!is.null(article_length)){
          #   message(paste0("Body successfully collected for ", url))
          # } else {
          #   message("no body found")
          # }
          
          # Create a tibble for the current article
          tmp <- tibble(url = url, collected_text = collected_text)
          print(tmp)
          
          # Accumulate the results in the mj_article_text tibble
          mj_article_text <- bind_rows(mj_article_text, tmp)
          
        } else {
          message("<div class='mj-text-cta'> not found within <article>")
        }
      } else {
        message("<article> container not found on the page")
      }
    } else {
      message("Failed to read the HTML of the page")
    }
    counter <- counter + 1
    Sys.sleep(2) # Additional sleep to avoid overwhelming the server
  }
  
  # Save the accumulated results for the current batch
  saveRDS(mj_article_text, file = paste0("mj", batch, ".Rds"))
  message("RDS saved")
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

all_mj_article_text <- all_mj_article_text %>% rename(
  urls = url,
  body = collected_text
)

all_article_info1 <- left_join(all_article_info,all_mj_article_text)  
    
write.csv(all_article_info1,"all_mj_article_data.csv")

#GENDERIZE-------------------------------------------------------------------
all_article_info1 <- all_article_info1 %>%
  separate_wider_delim(authors," ",names = c("name","rest of name"),too_many = "merge", too_few="align_end")
all_article_info1 <- all_article_info1 %>%  mutate(Name = trimws(Name))

mj_names <- c(all_article_info1$name) %>%
  unique()%>%
  na.omit()

#Run gender  
mj_names_gen <- gender(mj_names,years=2012, method="ssa")


#lookup gen
all_article_info1 <- left_join(all_article_info1,mj_names_gen)

all_article_info2 <- all_article_info1 %>%
  mutate_all(~ ifelse(. == "", NA, .)) %>%
  filter(!is.na(gender) & !is.na(body))
