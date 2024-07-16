# Scraping Fox News Articles for the Term //Education Inequality//

setwd("C:/Users/kayle/Dropbox/Resources/SICSS_2024/projects/education_project/")

# Load necessary libraries

library(tidyverse)
library(RSelenium)
library(wdman)
library(netstat)
library(binman)
library(glue)
library(rvest)

  # I found this helpful for generating a random delayer: Sys.sleep(1+runif(1))

# Start RSelenium

selenium_object <- selenium(retcommand = TRUE,
                            check = FALSE) 
  # Retcommand returns the commandline call that would have been run
  # Check checks for updated versions of rselenium and associated drivers

binman::list_versions("chromedriver")
  # ^ Checks what versions of Chrome we have available in the Chrome driver
  # In the next set of lines, we want to set chromever equal to our version 

remote_driver <- rsDriver(browser = "chrome", 
                          chromever = "126.0.6478.126",
                          verbose = FALSE,
                          port = free_port(random = TRUE)) # close this window
  # ^ Specify the browser (e.g., chrome; firefox), the version, whether to 
  # report status messages (here set to false), and the port on the driver 

remDr <- remote_driver$client
  # Specify the client through which the remote driver will run

remDr$navigate("https://www.foxnews.com/")

# Click search button
remDr$findElement(using = "xpath", "//a[@class='js-focus-search']")$clickElement() 

# Find and save searchbox as object
searchbox <- remDr$findElement(using = "xpath", "//input[@aria-label='search foxnews.com']")

# Click searchbox
searchbox$clickElement() 

# Write search term
searchbox$sendKeysToElement(list('education inequality', key = "enter"))

# Select "By Content" dropdown
remDr$findElement(using = "xpath", "//button[contains(., 'Content')]")$clickElement() 

# Select "By Content" dropdown
remDr$findElement(using = "xpath", "//input[@title='Article']")$clickElement() 

# Click Search
remDr$findElement(using = "xpath", "//a[contains(., 'Search')]")$clickElement() 

# Loop --------------------------------------------------------------------
# Multiple issues:
# 1. Sometimes the date filter is ignored and the search results include all articles
# 2. Scroll down + button press does not work for some reason
# 3. starting 22 Feb 2022 the search results were stuck at the loading circle. 
# 4. does not stop when current date is reached

# Create the start and end dates for the search. We will then loop through using
# the index of the vectors
start_dates <- seq(as.Date("2020-01-01"), as.Date("2024-07-15"), by = "7 days")
end_dates <- start_dates + 6

# Create an empty character vector
urls <- character() 
index_end <- length(start_dates) # Identify the index of the last date
date_index <- 1
while (date_index <= index_end) {
  
  start_date <- start_dates[[date_index]]
  end_date <- end_dates[[date_index]]
  print(paste("Index:", date_index, "- Current range:", start_date, "to", end_date))
  
  if (date_index == index_end) {
    print("Finale date range reached")
  }
  
  # For testing ################################################################
  #start_date <- as.Date("2021-01-01")
  #end_date <- as.Date("2021-05-01")
  ##############################################################################
  
  # Set date to be entered in the search form
  start_day <- formatC(day(start_date), width=2, format="d", flag="0")
  start_month <- formatC(month(start_date), width=2, format="d", flag="0")
  start_year <- year(start_date)
  
  end_day <- formatC(day(end_date), width=2, format="d", flag="0")
  end_month <- formatC(month(end_date), width=2, format="d", flag="0")
  end_year <- year(end_date)
  
  # Scroll to top of page so that I have the entry field in the window
  remDr$executeScript("window.scrollTo(0, 0)")
  Sys.sleep(.3)
  
  # Select dates - start from end, otherwise "start date is larger than end date" warning which leads to errors
  # End
  # year
  remDr$findElement(using = "xpath", "//div[@class='date max']//div[@class='sub year']")$clickElement()  # For end year
  Sys.sleep(.3)
  remDr$findElement(using = "xpath", glue("//div[@class='date max']//div[@class='sub year']//li[@id='{end_year}']"))$clickElement()
  Sys.sleep(.3)
  # month
  remDr$findElement(using = "xpath", "//div[@class='date max']//div[@class='sub month']")$clickElement()  # For end month
  Sys.sleep(.3)
  remDr$findElement(using = "xpath", glue("//div[@class='date max']//div[@class='sub month']//li[@id='{end_month}']"))$clickElement()
  # day
  remDr$findElement(using = "xpath", "//div[@class='date max']//div[@class='sub day']")$clickElement()  # For end day
  Sys.sleep(.3)
  remDr$findElement(using = "xpath", glue("//div[@class='date max']//div[@class='sub day']//li[@id='{end_day}']"))$clickElement()

  
  # Start
  # month
  remDr$findElement(using = "xpath", "//div[@class='sub month']")$clickElement()  # For start month
  Sys.sleep(.3)
  remDr$findElement(using = "xpath", glue("//div[@class='sub month']//li[@id='{start_month}']"))$clickElement()
  # day
  remDr$findElement(using = "xpath", "//div[@class='sub day']")$clickElement()  # For start day
  Sys.sleep(.3)
  remDr$findElement(using = "xpath", glue("//div[@class='sub day']//li[@id='{start_day}']"))$clickElement()
  # year
  remDr$findElement(using = "xpath", "//div[@class='sub year']")$clickElement()  # For start year
  Sys.sleep(.3)
  remDr$findElement(using = "xpath", glue("//div[@class='sub year']//li[@id='{start_year}']"))$clickElement()
  Sys.sleep(.3)
  
  # Sometimes it still gives the start before end error. When that happens an
  # error gets shown for a short amount of time, and when that error disappears 
  # the entered date gets reset. So we have to catch when that happens and then
  # restart without increasing the date
  errorElements <- remDr$findElements(using = "css selector", ".error.active")
  if (length(errorElements) > 0) {
    print("Website shows error, start date larger than end date")
    Sys.sleep(10)
    next
  }
  
  # Find and save searchbox as object (does not have a type, so we need to use the only two identifying attributes that we have)
  searchbox <- remDr$findElement(using = "xpath", "//input[@type='text'][@searchtextsize='140']")
  
  Sys.sleep(.3)
  # Click searchbox
  searchbox$clickElement()
  
  # Delete content (because sometimes "Climate Change" is still in the box, and sometimes it is not)
  searchbox$clearElement()
  
  # Write search term
  searchbox$sendKeysToElement(list('education inequality', key = "enter"))
  
  # Wait to load
  Sys.sleep(runif(1))
  
  repeat {
    # Get URLs
    webElem <- remDr$findElements(using = "css selector", ".title a")
    
    if (length(webElem) == 0) {
      print(paste("No URLs in this date range", length(urls), "URLs scraped so far."))
      break
    }
    
    new_urls <- sapply(webElem, function(x) unlist(x$getElementAttribute("href")))
    
    if (all(new_urls %in% urls)) {
      print(paste("No new URLs.", length(urls), "URLs scraped so far."))
      break
    }
    
    urls <- c(urls, new_urls[!new_urls %in% urls])
    
    # If there is a load more, load more
    element <- remDr$findElement(using = "css selector", ".load-more span")
    remDr$executeScript("arguments[0].scrollIntoView(true);", list(element))
    element$clickElement()
    rm(element)
    Sys.sleep(1)
  }
  
  date_index <- date_index + 1
}


# close server
remote_driver$server$stop()


# Getting data from URLS



# What we want:
# Title: #maincontent
# Authors: .byline__name   (Achtung: can be multiple names!)
# Date: .timestamp
# Text: .paragraph

writeLines(urls, "foxurls_edinequality.txt")

urls <- scan("foxurls_edinequality.txt", character(), quote = "")
urls <- unique(urls)

# Testrun -----------------------------------------------------------------
website <- read_html(urls[385])
test <- tibble(
  title = website %>%
    html_node(".headline") %>%
    html_text(),
  
  authors = website %>%
    html_nodes(".author-byline a") %>%
    html_text()  %>%
    paste(collapse = ";"),
  
  timestamp = website %>%
    html_nodes("time") %>%
    html_text(),
  
  body = website %>%
    html_nodes(".article-body p") %>%
    html_text() %>%
    paste(collapse = ""),
  
  #url = url
)


# Loop --------------------------------------------------------------------

articles <- data.frame()
  
for (url in urls) {    
    Sys.sleep(runif(1)+sample(1:2, 1))
    
    print(paste(url))
    
    website <- read_html(url)
    
    tmp <- tibble(
      title = website %>%
        html_node(".headline") %>%
        html_text(),
      
      authors = website %>%
        html_nodes(".author-byline a") %>%
        html_text()  %>%
        paste(collapse = ";"),
      
      timestamp = website %>%
        html_nodes("time") %>%
        html_text(),
      
      body = website %>%
        html_nodes(".article-body p") %>%
        html_text() %>%
        paste(collapse = ""),
      
      url = url
    )
    
    articles <- rbind(articles, tmp)
  }

saveRDS(articles, file = paste0("FOX", ".Rds"))

# Append FOX articles
FOX <- rbind(readRDS("FOX.Rds"))

# remove duplicates

FOX <- articles |> group_by(title, authors) |> slice(1)

# check if length is realistic
FOX <- FOX %>%
  mutate(article_length = str_length(body))

# save as one file
saveRDS(FOX, file = "FOX.Rds")