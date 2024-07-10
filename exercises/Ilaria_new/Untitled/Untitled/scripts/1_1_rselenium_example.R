library(tidyverse)
library(rvest)
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
