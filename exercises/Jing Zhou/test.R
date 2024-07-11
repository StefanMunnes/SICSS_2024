install.packages(c("RSelenium", "netstat", "binman"))
install.packages("wdman")

library(RSelenium)
library(wdman)
library(binman)
library(netstat)

selenium()

selenium_object <- selenium(retcommand = TRUE,
                            check = FALSE)


binman::list_versions("chromedriver")



# The following command should open a browser window (you might need to adjust the version!)
remote_driver <- rsDriver(browser = "chrome",
                          chromever = "126.0.6478.126",
                          verbose = FALSE,
                          port = free_port())


# close the server
 

# If you start it a few times, but never close the server there might be no empty port left.
# You can run the following to kill all java processes
system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)