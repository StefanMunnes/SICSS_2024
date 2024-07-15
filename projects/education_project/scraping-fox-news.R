# Scraping Fox News Articles for the Term //Education Inequality//

# Load necessary libraries

library(tidyverse)
library(RSelenium)
library(wdman)
library(netstat)
library(binman)

# Start RSelenium

selenium_object <- selenium(retcommand = TRUE,
                            check = FALSE) 
  # Retcommand returns the commandline call that would have been run
  # Check checks for updated versions of rselenium and associated drivers

binman::list_versions("chromedriver")
  # ^ Checks what versions of Chrome we have available in the Chrome driver
  # In the next set of lines, we want to set chromever equal to our version 

remote_driver <- rsDriver(browser = "chrome", 
                          chromever = "126.0.6478.127",
                          verbose = FALSE,
                          port = free_port(random = TRUE)) # close this window
  # ^ Specify the browser (e.g., chrome; firefox), the version, whether to 
  # report status messages (here set to false), and the port on the driver 

remDr <- remote_driver$client

remDr$navigate("https://edition.cnn.com/")





Sys.sleep(1+runif(1))




# Reject cookies
remDr$findElement(using = "xpath", "//button[@id='onetrust-reject-all-handler']")$clickElement() 

# wth is an xpath? 
# https://www.w3schools.com/xml/xpath_intro.asp
# https://devhints.io/xpath#prefixes

# Click search button
remDr$findElement(using = "xpath", "//button[@id='headerSearchIcon']")$clickElement() 

# Find and save searchbox as object
searchbox <- remDr$findElement(using = "xpath", "//input[@aria-label='Search']")

# Click searchbox
searchbox$clickElement() 

# Write search term
searchbox$sendKeysToElement(list('\"Black Lives Matter\"', key = "enter"))

# Limit search to stories
remDr$findElement(using = "xpath", "//label[@for='collection_article']")$clickElement() 


# HERE WE SCRAPE


# Scroll to element (the next button)
element <- remDr$findElement(using = "css selector", ".pagination-arrow-right")
remDr$executeScript("arguments[0].scrollIntoView(true);", list(element))

Sys.sleep(0.2)
# Click next page
remDr$findElement(using = "css selector", ".pagination-arrow-right")$clickElement() 

# close server
remote_driver$server$stop()