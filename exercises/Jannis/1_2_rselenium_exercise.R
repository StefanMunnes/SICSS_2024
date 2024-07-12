# SICSS Berlin - Day 2 - July 10, 2024
# Web scraping - Exercise

library(tidyverse)
library(RSelenium)
library(rvest)
library(wdman)
library(netstat)
library(binman)

# 1.	Install RSelenium using the guide
# 2.	Use RSelenium to collect the URLs of 200 articles that mention "Black Lives Matter".

# NOTE: The result should be a dataframe with five columns (title, author, date, body, url). 
# NOTE: Tomorrow we will learn how to clean the text data.
# NOTE: Don't forget to include a time delay between each request to the server! 


# Task 1 ------------------------------------------------------------------
# Install RSelenium
# You can use any guide you want, this one worked perfectly for me:
# https://www.youtube.com/watch?v=GnpJujF9dBw

selenium()

# Identify the path, go to the path, and delete all LICENSE.chromedriver files in all of the chromedriver folders
selenium_object <- selenium(retcommand = T,
                            check = F) 

binman::list_versions("chromedriver") 


# Task 2 ------------------------------------------------------------------
# Use RSelenium to collect the URLs of 200 articles mentioning “Black Lives Matter”
# Start a remote driver
remote_driver <- rsDriver(browser = "chrome", 
                          chromever = "114.0.5735.90",
                          verbose = FALSE,
                          port = free_port(random = TRUE)) # close this window

# select and open only the client 
# the remote driver consists of a server and a client, but we are only using the client
remDr <- remote_driver$client

