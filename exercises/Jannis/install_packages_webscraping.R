#install.packages("tidyverse")
#install.packages("wdman")
#install.packages("netstat")
#install.packages("rvest")
#install.packages("RSelenium")

library(tidyverse)
library(wdman)
library(rvest)
library(netstat)
library(RSelenium)

selenium()

selenium_object <- selenium(retcommand = TRUE,
                            check = FALSE)
binman::list_versions("chromedriver")

remote_driver <- rsDriver(browser = "chrome",
                          chromever = "126.0.6478.126",
                          verbose = FALSE,
                          port = free_port(random = TRUE))

#remote_driver <- rsDriver(browser = "chrome",chromever = "126.0.6478.127",verbose = FALSE,port = free_port(random = TRUE))

