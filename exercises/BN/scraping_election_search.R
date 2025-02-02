# SICSS Berlin - Day 2 - July 9, 2024
# Web Scraping - Example
install.packages("xlsx")


library(tidyverse)
library(rvest)
library(xlsx)



# First scrape the full page into R
website <- read_html("https://time.com/6995779/france-macron-disastrous-election/")




#scrape title, author, date and body text
title <- website %>%
  html_node("#article-header .self-baseline") %>%
  html_text()

author <- website %>%
  html_node(".inline-block .font-bold")%>%
  html_text()

date <- website%>%
  html_node("time")%>%
  html_text()

body <- website %>%
  html_nodes("#article-body") %>%
  html_text() %>%
  paste(collapse = "")


#creating df for urls
scrape_url_lists <- data.frame()
i <-  1

#collecting urls from 5 search pages
while (i < 6){
  
  Sys.sleep(sample(1:10, 1))
  search_result <- read_html(paste0("https://time.com/search/?q=election&page=",i))
  
  
  scrape_url_list <- search_result %>%
    html_nodes(".media-heading a") %>%
    html_attr("href")
  
  scrape_url_lists <- bind_rows(scrape_url_lists, as.data.frame(scrape_url_list))
  
  i <- i+1
  
}



#creating df for scraped data(title, author, date, body) from collected urls
articles <- setNames(data.frame(matrix(ncol = 4, nrow = 0)), c("title", "author", "date", "body"))

#scraping loop from every url
x <- 1

while (x<46){
  Sys.sleep(2)
  article_url <- read_html(scrape_url_lists[x,1])
  
  title <- article_url %>%
    html_node("#article-header .self-baseline, .lg\\:mb-12") %>%
    html_text()
  
  author <- article_url %>%
    html_node(".inline-block .font-bold, .lg\\:mr-3 a.font-bold, a.font-bold.text-\\[\\#fefefd\\]")%>%
    html_text()
  
  date <- article_url%>%
    html_node("time")%>%
    html_text()
  
  body <- article_url %>%
    html_nodes("#article-body") %>%
    html_text() %>%
    paste(collapse = "")
  
  articles[x, ] <- c(title, author, date, body)
  
  x <- x+1
}

combined_election_df <- cbind(articles, scrape_url_lists)

write_csv(combined_election_df, "exercises/BN/time_election.csv")
write.xlsx(combined_election_df, "exercises/BN/time_election.xlsx")
