
# project work: web scraping and sentiment analysis on abortion in the US (and Germany)

# Gender Inequality in Media Representations of Abortions 
# -> How do women and men write about and discuss abortions? 
# Scrape Zeit online's articles on "abtreibung"


library(tidyverse)
library(rvest)
library(stringr)


# 1.  urls 
url_base <- "https://www.zeit.de/suche/index?q=abtreibung&p="

url_all <- c()

# 316 pages
for (i in 1:316) {
  print(i)
  url_all <- append(url_all, paste0(url_base, as.character(i)))
}


paste0(url_base, 1:316)

url_list <- url_all



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

# 2. scrape all associated articles 

get_all_articles <- function(url) {
  print(paste(url, all_urls[[url]]))
  website <- read_html(all_urls[[url]])
  article <- tibble(
    title = website |>
      html_node(".article-heading__title") |>
      html_text(),
    
    summary = website |>
      html_nodes(".summary") |>
      html_text() |>
      paste(collapse = ";"),
    
    author = website |>
      html_nodes(".byline") |>
      html_text() |>
      paste(collapse = ";"),
    
    source = website |>
      html_nodes(".metadata__source") |>
      html_text() |>
      paste(collapse = ";"),
      
    date = website |> 
      html_node(".metadata__date") |> 
      html_text(),  
      
    
   body = website |>
      html_nodes(".article-page") |>
      html_text() |>
      paste(collapse = " "),
    
    url = all_urls[[url]]
  )
  return(article)   
  Sys.sleep(2)
}

#  3. Exectute the function for all URLs previously collected
all_articles <- lapply(seq_along(all_urls), get_all_articles) 

# 4. Transform lists to data frame
abortion <- bind_rows(all_articles)

# 5. Save as csv
write_csv(abortion, "~/SICSS_2024/projects/abortion laws/abortion_zeitonline.csv")

View(abortion)
