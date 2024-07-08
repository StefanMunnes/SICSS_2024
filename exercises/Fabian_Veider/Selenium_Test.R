# install.packages(c("RSelenium", "wdman", "netstat", "binman"))

library(RSelenium)
library(wdman)
library(netstat)
library(binman)
selenium()
# Show were licences are
# wdman::selenium(retcommand = TRUE, check = FALSE)
selenium_object <- selenium(retcommand = TRUE,
                            check = FALSE)
# Check for free port
free_port()
binman::list_versions("chromedriver")

# The following command should open a browser window (you might need to adjust the version!)
remote_driver <- rsDriver(browser = "chrome",
                          chromever = "126.0.6478.126",
                          verbose = FALSE,
                          port = free_port())
#remote_driver <- rsDriver(browser = "chrome",
#                          chromever = "114.0.5735.90",
#                          verbose = FALSE,
#                          port = free_port())

# close the server
remote_driver$server$stop()

# If you start it a few times, but never close the server there might be no empty port left.
# You can run the following to kill all java processes
system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)
