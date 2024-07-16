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

remDr$navigate("https://www.bbc.com/search?q=%22just%20stop%20oil%22&edgeauth=eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9.eyJrZXkiOiAiZmFzdGx5LXVyaS10b2tlbi0xIiwiZXhwIjogMTcyMTEyNDY1MCwibmJmIjogMTcyMTEyNDI5MCwicmVxdWVzdHVyaSI6ICIlMkZzZWFyY2glM0ZxJTNEJTI1MjJqdXN0JTI1MjBzdG9wJTI1MjBvaWwlMjUyMiJ9.4lc26CYYTFIg5NKACZ6CALy79TDfMZac2b8kMoQKVQQ")
Sys.sleep(10)

# Reject cookies
remDr$findElement(using = "xpath", "//button[@aria-label='I agree']")$clickElement()

# Click search button
remDr$findElement(using = "xpath", "//button[@id='headerSearchIcon']")$clickElement()

# Find and save searchbox as object
searchbox <- remDr$findElement(using = "xpath", "//input[@aria-label='Search']")

# Click searchbox
searchbox$clickElement()

# Write search term
searchbox$sendKeysToElement(list('\"oil\"', key = "enter"))

# Limit search to stories
remDr$findElement(using = "xpath", "//label[@for='collection_article']")$clickElement()


# Loop --------------------------------------------------------------------
urls <- character()
page <- 1
while (TRUE) {
  # Extract headlines (with URLs)
  webElem <- remDr$findElements(using = "css selector", value="a")

  # Save new URLs in object
  new_urls <- sapply(webElem, function(x) unlist(x$getElementAttribute("href")))

  # Add new URLs to list of all URLs, ensure they are not already present
  urls <- c(urls, new_urls[!new_urls %in% urls])

  # Stop at 400 URLs
  if (length(urls) > 2000) {
    print("Limit of 1000 URLs reached")
    break
  }

  # Move to next page
  # Scroll to element (the next button)
  element <- remDr$findElement(using = "css selector", value="button[data-testid='pagination-next-button']")
  remDr$executeScript("arguments[0].scrollIntoView(true);", list(element))
  Sys.sleep(0.2)

  # Check if Next button is inactive, if it is, stop the loop
  # inactive_right_button <- remDr$findElements(using = "css selector", value=".pagination-arrow.pagination-arrow-right.text-inactive")
  # Sys.sleep(0.2)
  # if (length(inactive_right_button) > 0) {
  #   print("Last page reached")
  #   break
  # }

  # Click next page
  remDr$findElement(using = "css selector", value="button[data-testid='pagination-next-button']")$clickElement()

  # Wait a second
  Sys.sleep(2)

  # Progress message
  print(paste0("Page: ", page, " done, ", length(urls), " URLs saved"))

  # Increase counter
  page <- page + 1
}

# save URLs
writeLines(urls, "data/bbc_urls.txt")
urls

# close server
remote_driver$server$stop()

#filter for /bbc/news
news_urls <- grep("https://www.bbc.com/news", urls, value = TRUE)
news_urls <- unique(news_urls)

print(news_urls)
