# setting up RSelenium

install.packages("RSelenium")
install.packages("wdman")
install.packages("netstat")

library(RSelenium)
library(wdman)
library(netstat)

selenium()

selenium_object <- selenium(retcommand = TRUE, 
                            check = FALSE)


binman:: list_versions("chromedriver")

remote_driver <- rsDriver(browser = "chrome",
                          chromever = "126.0.6478.126", 
                          verbose = FALSE, 
                          port = free_port(random = TRUE))