library(tidyverse)
library(httr)
library(jsonlite)


#create object for extracted data from API request
httr_members <- NULL

i <- 0
while(i<1000){
  httr_members <- GET(url = "https://api.congress.gov/v3/member",
                      query = list(format = "json",
                                   limit = 250,
                                   offset = i,
                                   currentMember = 0,
                                   api_key = Sys.getenv("congress_key")))
  
}



#extract only the list of members
members <- content(httr_members, type='application/json')$members

#flatten the list
flatten_list <- function(x) {
  do.call(c, x) # the c stands for combine and is a base R function, see ?c
}
members <- lapply(members, flatten_list)

#convert list to df
df_members <- bind_rows(members)
