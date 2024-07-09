# SICSS Berlin - Day 2 - July 9, 2024
# Web Scraping - Example

library(tidyverse)
library(rvest)


# Basic scraping ----------------------------------------------------------
# Let's stay on https://en.wikipedia.org/wiki/Computational_social_science

# First scrape the full page into R
website <- read_html("https://en.wikipedia.org/wiki/Computational_social_science")

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

# that's it
title <- website %>%
  html_node(".mw-page-title-main") %>%
  html_text()
# Paste collapses separate strings into one
text <- website %>%
  html_nodes("ul:nth-child(9) li , p") %>%
  html_text() %>%
  paste(collapse = "")

url <- website %>%
  html_node(".navigation-not-searchable .mw-redirect") %>%
  html_attr("href")

# Lastly, it is very easy to combine this into a data frame right away, using tibble()
css_wiki <- tibble(
  title = website %>%
    html_node(".mw-page-title-main") %>%
    html_text(),
  
  text = website %>%
    html_nodes("ul:nth-child(9) li , p") %>%
    html_text() %>%
    paste(collapse = ""),
  
  url = website %>%
    html_node(".navigation-not-searchable .mw-redirect") %>%
    html_attr("href")
)

