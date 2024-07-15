library(tidyverse)
library(RSelenium)
library(wdman)
library(netstat)

selenium()

selenium_object <- selenium(retcommand = TRUE,
                            check = FALSE)

binman::list_versions("chromedriver")


remote_driver <- rsDriver(browser = "chrome", 
                          chromever = "126.0.6478.126",
                          verbose = FALSE,
                          port = free_port(random = TRUE))

remDr <- remote_driver$client

remDr$navigate("https://edition.cnn.com/")
Sys.sleep(10)

# Reject cookies - Not required in the US
remDr$findElement(using = "xpath", "//button[@id='onetrust-reject-all-handler']")$clickElement() 

# Click search button
remDr$findElement(using = "xpath", "//button[@id='headerSearchIcon']")$clickElement() 

# Find and save searchbox as object
searchbox <- remDr$findElement(using = "xpath", "//input[@aria-label='Search']")

# Click searchbox
searchbox$clickElement() 

# Write search term
searchbox$sendKeysToElement(list('\"education inequality\"', key = "enter"))

# Limit search to stories
remDr$findElement(using = "xpath", "//label[@for='collection_article']")$clickElement() 


# Loop --------------------------------------------------------------------
urls <- character()
page <- 1
while (TRUE) {
  # Extract headlines (with URLs)
  webElem <- remDr$findElements(using = "class", value="container__headline-text")
  print(1)
  
  # Save new URLs in object
  new_urls <- sapply(webElem, function(x) unlist(x$getElementAttribute("data-zjs-href")))
  print(2)
  # Add new URLs to list of all URLs, ensure they are not already present
  urls <- c(urls, new_urls[!new_urls %in% urls])
  print(3)
  # Stop at 1000 URLs
  if (length(urls) > 800) {
    print("Limit of 800 URLs reached")
    break
  }
  
  
  # Move to next page
  # Scroll to element (the next button)
  element <- remDr$findElement(using = "css selector", ".pagination-arrow-right")
  remDr$executeScript("arguments[0].scrollIntoView(true);", list(element))
  Sys.sleep(0.2)
  print(4)
  # Check if Next button is inactive, if it is, stop the loop
  inactive_right_button <- remDr$findElements(using = "css selector", value=".pagination-arrow.pagination-arrow-right.text-inactive")
  Sys.sleep(0.2)
  print(5)
  if (length(inactive_right_button) > 0) {
    print("Last page reached")
    break
  }
  
  # Click next page
  remDr$findElement(using = "css selector", ".pagination-arrow-right")$clickElement() 
  print(6)
  # Wait a second
  Sys.sleep(3)
  
  # Progress message
  print(paste0("Page: ", page, " done, ", length(urls), " URLs saved"))
  
  # Increase counter
  page <- page + 1
}

# save URLs
writeLines(urls, "projects/education_project/cnnurls.txt")



# close server
remote_driver$server$stop()

#scraping urls finished




#scraping articles

#import the cnnurls data
cnn_urls <- read.delim("projects/education_project/cnnurls.txt")
articles <- setNames(data.frame(matrix(ncol = 4, nrow = 0)), c("title", "author", "date", "body"))

x <- 1


while (x<805){
  Sys.sleep(3)
  article_url <- read_html(cnn_urls[x,1])
  
  title <- article_url %>%
    html_node("#maincontent") %>%
    html_text()
  
  author <- article_url %>%
    html_node(".byline__names")%>%
    html_text()
  
  date <- article_url%>%
    html_node(".timestamp.vossi-timestamp-primary-core-light")%>%
    html_text()
  
  body <- article_url %>%
    html_nodes(".vossi-paragraph-primary-core-light") %>%
    html_text() %>%
    paste(collapse = "")
  
  articles[x, ] <- c(title, author, date, body)
  
  print(paste("Scraped", x, "articles"))
  
  x <- x+1
}

#create reserve articles df
articles_reserve <- articles

#scrape missing article 602
article_url <- read_html("https://edition.cnn.com/2020/09/02/us/schools-coronavirus-six-months-in-wellness/index.html")
title <- article_url %>%
  html_node(".pg-headline") %>%
  html_text()

author <- article_url %>%
  html_node(".metadata__byline__author")%>%
  html_text()

date <- article_url%>%
  html_node(".update-time")%>%
  html_text()

body <- article_url %>%
  html_nodes(".zn-body__paragraph") %>%
  html_text() %>%
  paste(collapse = "")

articles[601, ] <- c(title, author, date, body)


combined_edineq_df <- cbind(articles, cnn_urls)

#save the df
write_csv(combined_edineq_df, "projects/education_project/cnn_edineq_df.csv")
write.xlsx(combined_edineq_df, "projects/education_project/cnn_edineq_df.xlsx")
