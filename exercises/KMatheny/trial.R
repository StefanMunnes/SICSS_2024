setwd("C:/Users/kayle/Dropbox/Resources/SICSS_2024/exercises/KMatheny")
credentials::set_github_pat("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")

install.packages("RSelenium")
install.packages("wdman")
install.packages("netstat")

library(RSelenium)
library(wdman)
library(netstat)

selenium()

selenium_object <- selenium(retcommand = T, check = F)

remote_driver <- rsDriver(browser = "chrome",
                          chromever = "126.0.6478.126",
                          verbose = FALSE,
                          port = free_port())
