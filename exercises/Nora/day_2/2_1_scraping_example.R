# SICSS Berlin - Day 2 - July 9, 2024
# Web Scraping - Example

library(tidyverse)
library(rvest)
library(stringi)

# Basic scraping ----------------------------------------------------------
# Let's stay on https://en.wikipedia.org/wiki/Computational_social_science

# First scrape the full page into R

# Now find the elements we want with selector gadget.
# Let's get the title, the full text and the link to broader topic
# Script: first you get the node, but that is still in useless code, so you
# extract what you want,which is the text (html_text()).

# For the website, we use selector gadget again, but this time it is a bit more
# difficult now when we run it as above, we might miss an error... with
# html_node() it is only the first element found, but we want them all. so we
# have to use html_nodes(). Lastly, we want it to be one singular string, not a
# vector of strings, so we use paste(collapse = "")

# For the link, we do the same as above. Using html_text() we can see that we
# are targeting the right area, but we want the URL not the text, we can do this
# with html_attr, to extract by attribute, and the attribute is called "href",
# because that's how links are called in html.

website <- read_html("https://time.com/collection/next-generation-leaders/6973222/ncuti-gatwa-2024/")

title <- website %>%
  html_node(".margin-8-top") %>%
  html_text()

text <- website %>%
  html_nodes("p:nth-child(1)") %>%
  html_text() %>%
  paste(collapse = "")

#url <- website %>%
 # html_node("https://time.com/collection/next-generation-leaders/6973222/ncuti-gatwa-2024/") %>%
  #html_attr("href")

date <- website %>%
  html_node("time") %>%
  html_text()

#what is this code doing?
byline <- website %>%
  html_nodes("#article-body a.font-bold") %>%
  html_text() %>%
  paste(collapse = ";")

# Lastly, it is very easy to combine this into a data frame right away, using tibble()
ncuti_time <- tibble(
  title = website %>%
    html_node(".margin-8-top") %>%
    html_text(),

  text = website %>%
    html_nodes("p:nth-child(1)") %>%
    html_text() %>%
    paste(collapse = ""),

  date <- website %>%
    html_node("time") %>%
    html_text(),

  url = website %>%
    html_node(".navigation-not-searchable .mw-redirect") %>%
    html_attr("href")
)

## Task 3

# Write scraping function that iterates through page numbers by inserting them into the URL
get_urls <- function(page) {
  website <- read_html(paste0("https://time.com/search/?q=climate%20change&page=", page))

  urls <- website %>%
    html_nodes(".media-heading a") %>%
    html_attr("href")

  return(urls)

  Sys.sleep(2)
}

# run the function for pages 1-5, and then unlist, which is not necessary, but I prefer to have the result as one string vector.
all_urls <- lapply(1:5, get_urls) %>%
  unlist()

all_urls

#Task 4
#basically combinining task 2 and 3
# CSS selectors from task 2 dont actually work for all articles.
# when that happens, look at the pages that didn't work and find a different CSS selector that covers all the pages,
#or you have to use a variety of selectors as done below

# Write scraping function
get_all_articles <- function(url) {

  print(paste(url, all_urls[[url]]))

  website <- read_html(all_urls[[url]])

  article <- tibble(
    title = website %>%
      html_node("#article-header .self-baseline, .entry-title") %>%
      html_text(),

    byline = website %>%
      html_nodes(".inline-block a.font-bold, #article-body a.font-bold, .entry-byline a") %>%
      html_text() %>%
      paste(collapse = ";"),

    date = website %>%
      html_node("time, .entry-date") %>%
      html_text(),

    body = website %>%
      html_nodes("#article-body, p") %>%
      html_text() %>%
      paste(collapse = " "),

    url = all_urls[[url]]
  )

  return(article)

  Sys.sleep(2)
}

# Exectute the function for all URLs previously collected
all_articles <- lapply(seq_along(all_urls), get_all_articles)

# Transform lists to data frame
time_climate <- bind_rows(all_articles)

# Save as csv
write_csv(time_climate, "../data/time_climate.csv")
