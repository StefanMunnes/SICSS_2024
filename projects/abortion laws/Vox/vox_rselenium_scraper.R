library(tidyverse)
library(RSelenium)
library(wdman)
library(netstat)
library(binman)

selenium()

selenium_object <- selenium(retcommand = TRUE,
                            check = FALSE)

binman::list_versions("chromedriver")



# Task 1 ------------------------------------------------------------------
# Use RSelenium to collect the URLs of 200 articles mentioning “Climate Change”
# Start a remote driver
remote_driver <- rsDriver(browser = "chrome", 
                          chromever = "126.0.6478.126",
                          verbose = FALSE,
                          port = free_port(random = TRUE)) # close this window

# Time for browser to open
Sys.sleep(10)

# select and open only the client 
# the remote driver consists of a server and a client, but we are only using the client
remDr <- remote_driver$client

# navigate to cnn.com
remDr$navigate("https://www.vox.com/")
Sys.sleep(10)

# Reject cookies - Not required in the US
# Consent
remDr$findElement(using = "xpath", "//button[@aria-label='Consent']")$clickElement() 

# Click menu button
remDr$findElement(using = "xpath", "//button[@aria-label='Open Drawer']")$clickElement() 

# Click search button
#remDr$findElement(using = "xpath", "//button[@id='headerSearchIcon']")$clickElement() 

# Find and save searchbox as object
searchbox <- remDr$findElement(using = "xpath", "//input[@name='query']")

# Click searchbox
searchbox$clickElement() 

# Write search term
searchbox$sendKeysToElement(list('\"Abortion\"', key = "enter"))

# Limit search to stories
#remDr$findElement(using = "xpath", "//class[@for='collection_article']")$clickElement() 



## LOOP
urls <- character()
page <- 1
while (TRUE) {
  
  webElem <- remDr$findElements(using = "class", value="qcd9z1")
  
  # Save new URLs in object
  new_urls <- sapply(webElem, function(x) unlist(x$getElementAttribute("href")))
  print(new_urls)
  
  # Add new URLs to list of all URLs, ensure they are not already present
  urls <- c(urls, new_urls[!new_urls %in% urls])
  
  # Stop at 400 URLs
  if (length(urls) > 1000) {
    print("Limit of 1000 URLs reached")
    break
  }
  
  
  # Move to next page
  # Scroll to element (the next button)
  element <- remDr$findElement(using = "xpath", value="//a[@rel='next']")
  check_element <- tryCatch({remDr$findElement(using = "xpath", value="//a[@rel='next']") 
    TRUE
    }, error = function(e) {
      FALSE
      })
  
  remDr$executeScript("arguments[0].scrollIntoView(true);", list(element))
  Sys.sleep(0.2)
  
  # Check if Next button is inactive, if it is, stop the loop
#  inactive_right_button <- remDr$findElements(using = "css selector", value=".pagination-arrow.pagination-arrow-right.text-inactive")
#  Sys.sleep(0.2)
#  if (length(inactive_right_button) > 0) {
#    print("Last page reached")
#    break
#}
  

#  next_button_present <- is_element_present(remDr,"//rel[@for='Next']")
  
  if(!check_element){
    print("Last page reached")
    break
    }
  
  # Click next page
  element$clickElement() 
  
  # Wait a second
  Sys.sleep(1)
  
  # Progress message
  print(paste0("Page: ", page, " done, ", length(urls), " URLs saved"))
  
  # Increase counter
  page <- page + 1
}

vox_urls <- tibble(urls)

# save URLs
write.csv(vox_urls, "vox_urls.csv")

# close server
remote_driver$server$stop()

