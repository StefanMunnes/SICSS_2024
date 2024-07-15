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
