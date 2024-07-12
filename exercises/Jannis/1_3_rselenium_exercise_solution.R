# SICSS Berlin - Day 2 - July 10, 2024
# Web scraping - Exercise Solution

library(tidyverse)
library(RSelenium)
library(wdman)
library(netstat)
library(binman)

# Use RSelenium to collect the URLs of 200 articles that mention "Black Lives Matter".

# NOTE: Save these URLs into a .txt file
# NOTE: Don't forget to include a time delay between each request to the server!
# NOTE: You might need additional time delays to give the page time to load!


# Task 1 ------------------------------------------------------------------
# Use RSelenium to collect the URLs of 200 articles mentioning “Climate Change”
# Start a remote driver
remote_driver <- rsDriver(browser = "chrome", 
                          chromever = "126.0.6478.127",
                          verbose = FALSE,
                          port = free_port(random = TRUE)) # close this window

# select and open only the client 
# the remote driver consists of a server and a client, but we are only using the client
remDr <- remote_driver$client

# navigate to cnn.com
remDr$navigate("https://edition.cnn.com/")

# Reject cookies - Not required in the US
remDr$findElement(using = "xpath", "//button[@id='onetrust-reject-all-handler']")$clickElement() 

# Click search button
remDr$findElement(using = "xpath", "//button[@id='headerSearchIcon']")$clickElement() 

# Find and save searchbox as object
searchbox <- remDr$findElement(using = "xpath", "//input[@aria-label='Search']")

# Click searchbox
searchbox$clickElement() 

# Write search term
searchbox$sendKeysToElement(list('\"Climate Change\"', key = "enter"))

# Limit search to stories
remDr$findElement(using = "xpath", "//label[@for='collection_article']")$clickElement() 

## LOOP
urls <- character()
file <- file("../data/processed/practice_CNN_URLs.txt")
page <- 1
while (1==1) {
  
  Sys.sleep(runif(1)+sample(1:2, 1))
  
  print(page)
  
  # Check whether new stuff is added
  pre <- length(urls)
  
  # Extract headlines (with URLs)
  webElem <- remDr$findElements(using = "xpath", value="//span[@data-editable='headline']")
  
  # Save only URLs and add to url object
  for (i in 1:length(webElem)) {
    url_tmp <- webElem[[i]]$getElementAttribute("data-zjs-href")
    urls <- c(urls, unlist(url_tmp))
  }
  
  # Ensure that there are no repeat URLs
  urls <- unique(urls)
  
  # save new length
  new <- length(urls)
  
  # Stop if no new urls were added
  if (pre==new) {
    print("No new urls added")
    close(file)
    break
  } 
  
  # Save URLs to file
  writeLines(urls, file)
  
  # (For exercise) Stop if 200 urls was reached
  if (new > 200) {
    print("200 urls reached")
    close(file)
    break
  }

  # Scroll to element (the next button)
  element <- remDr$findElement(using = "css selector", ".pagination-arrow-right")
  remDr$executeScript("arguments[0].scrollIntoView(true);", list(element))
  
  Sys.sleep(0.2)
  # Click next page
  remDr$findElement(using = "css selector", ".pagination-arrow-right")$clickElement() 
  
  page <- page + 1
}

# close server
remote_driver$server$stop()
