library(tidyverse)
library(httr)
library(jsonlite)


#create object for extracted data from API request
members <- list()

seq(from = 0, to = 1000, by = 250)
for (i in seq(from 0, to = 1000, by = 250)){
  
  response <- GET(url = "https://api.congress.gov/v3/member",
                      query = list(format = "json",
                                   limit = 250,
                                   offset = i,
                                   api_key = Sys.getenv("congress_key"))&resultsToSkip=i)
  
  #extract only the list of members
  response_json <- fromJSON(content(response, "text"))
  
  members[[i]] <- response_json&members
  
}

#flatten the list
flatten_list <- function(x) {
  do.call(c, x) # the c stands for combine and is a base R function, see ?c
}
list_members <- lapply(members, flatten_list)




#convert list to df
members <- bind_rows(members)
