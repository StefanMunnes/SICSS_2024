library(tidyverse)
library(RSelenium)
library(wdman)
library(netstat) # required for free_port
library(lubridate)
library(glue) # required to feed dates into string
# Fox News ----------------------------------------------------------------
# search term "Climate Change"
remote_driver <- rsDriver(browser = "chrome", 
                          chromever = "126.0.6478.126",
                          verbose = FALSE,
                          port = free_port(random = TRUE))

remDr <- remote_driver$client

# Load page
#remDr$navigate("https://www.foxnews.com/search-results/search?q=%22Climate%20Change%22")
remDr$navigate("https://www.foxnews.com/")

# Click search button
remDr$findElement(using = "xpath", "//a[@class='js-focus-search']")$clickElement() 

# Find and save searchbox as object
searchbox <- remDr$findElement(using = "xpath", "//input[@aria-label='search foxnews.com']")

# Click searchbox
searchbox$clickElement() 

# Write search term
searchbox$sendKeysToElement(list('\"trump\"', key = "enter"))

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

# Create the start and end dates for the search. We will done loop through using
# the index of the vectors
start_dates <- seq(as.Date("2024-01-01"), as.Date("2024-06-30"), by = "2 days")
end_dates <- start_dates + 1

#end_dates <- (start_dates - 1)[-1]
#end_dates <- c(end_dates, as.Date("2024-01-01")) # add the last time point
#length(start_dates)
#length(end_dates)

urls <- character() # Empty character vector for the URLs to be stored in
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
  # month
  remDr$findElement(using = "xpath", "//div[@class='date max']//div[@class='sub month']")$clickElement()  # For end month
  Sys.sleep(.3)
  remDr$findElement(using = "xpath", glue("//div[@class='date max']//div[@class='sub month']//li[@id='{end_month}']"))$clickElement()
  # day
  remDr$findElement(using = "xpath", "//div[@class='date max']//div[@class='sub day']")$clickElement()  # For end day
  Sys.sleep(.3)
  remDr$findElement(using = "xpath", glue("//div[@class='date max']//div[@class='sub day']//li[@id='{end_day}']"))$clickElement()
  # year
  remDr$findElement(using = "xpath", "//div[@class='date max']//div[@class='sub year']")$clickElement()  # For end year
  Sys.sleep(.3)
  remDr$findElement(using = "xpath", glue("//div[@class='date max']//div[@class='sub year']//li[@id='{end_year}']"))$clickElement()
  Sys.sleep(.3)
  
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
  searchbox$sendKeysToElement(list('\"trump\"', key = "enter"))
  
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

writeLines(urls, "data/foxurls_trump2.txt")

# close server
remote_driver$server$stop()

