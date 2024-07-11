install.packages("RSelenium")
install.packages("wdman")
install.packages("netstat")

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


# close the server
remote_driver$server$stop()

# If you start it a few times, but never close the server there might be no empty port left.
# You can run the following to kill all java processes
system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
