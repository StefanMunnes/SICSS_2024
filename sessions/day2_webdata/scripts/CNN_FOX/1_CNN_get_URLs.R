library(tidyverse)
library(RSelenium)
library(wdman)
library(netstat)

selenium()

selenium_object <- selenium(retcommand = TRUE,
                            check = FALSE)

binman::list_versions("chromedriver")


remote_driver <- rsDriver(browser = "chrome", 
                          chromever = "126.0.6478.127",
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
searchbox$sendKeysToElement(list('\"biden\"', key = "enter"))

# Limit search to stories
remDr$findElement(using = "xpath", "//label[@for='collection_article']")$clickElement() 


# Loop --------------------------------------------------------------------
urls <- character()
page <- 1
while (TRUE) {
  # Extract headlines (with URLs)
  webElem <- remDr$findElements(using = "class", value="container__headline-text")
  
  # Save new URLs in object
  new_urls <- sapply(webElem, function(x) unlist(x$getElementAttribute("data-zjs-href")))
  
  # Add new URLs to list of all URLs, ensure they are not already present
  urls <- c(urls, new_urls[!new_urls %in% urls])

  # Stop at 400 URLs
  if (length(urls) > 1000) {
    print("Limit of 1000 URLs reached")
    break
  }
  
  # Move to next page
  # Scroll to element (the next button)
  element <- remDr$findElement(using = "css selector", ".pagination-arrow-right")
  remDr$executeScript("arguments[0].scrollIntoView(true);", list(element))
  Sys.sleep(0.2)
  
  # Check if Next button is inactive, if it is, stop the loop
  inactive_right_button <- remDr$findElements(using = "css selector", value=".pagination-arrow.pagination-arrow-right.text-inactive")
  Sys.sleep(0.2)
  if (length(inactive_right_button) > 0) {
    print("Last page reached")
    break
  }

  # Click next page
  remDr$findElement(using = "css selector", ".pagination-arrow-right")$clickElement() 
  
  # Wait a second
  Sys.sleep(1)
  
  # Progress message
  print(paste0("Page: ", page, " done, ", length(urls), " URLs saved"))
  
  # Increase counter
  page <- page + 1
}

# save URLs
writeLines(urls, "data/cnnurls_biden.txt")



# close server
remote_driver$server$stop()
