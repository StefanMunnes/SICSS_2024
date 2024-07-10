# SICSS Berlin - Day 2 - July 9, 2024
# API - Example
# also open: C:/Users/meierida/Documents/SICSS_2024/exercises/dm/1_2_api_exercise.qmd

library(tidyverse)
library(httr)
library(jsonlite)


# Google what you are looking for 

# Check out what they have on offer: https://api.congress.gov/


# Sign up for API-Key: https://api.congress.gov/sign-up/
# wcN7WbeNxIKNaXqIEytb6FadJwHRxll9D4eRtYrE

file.edit("~/.Renviron")
# Add "congress_key = [your key]" and save
# Restart R, then you can access the key via
Sys.getenv("congress_key")


# Look up the URL and the queries
https://api.congress.gov/v3/bill?api_key=[INSERT_KEY]

# offset is important because of the limit. Within your search criteria there might be
# more results, in that case you have to itterate through offset (offset = 0, offset = 250, offset = 500 etc.)
# This is important, because this is relevant for most APIs, but is solved differently.
# I tried it with xml, not json, but you can substitute every "xml" with "json"

# Now all we need is to 'build' the API call using httr
httr_members <- GET(url = "https://api.congress.gov/v3/member",
                  query = list(format = "json",
                          limit = 250,
                          offset = 0,
                           sort = "updateDate+desc",
                           api_key = Sys.getenv("congress_key")))

# Extract the contents as JSON/XML format/lists
members <- content(httr_members, type='application/json') 

# We extracted three elements, but we only need the members list
members <- content(httr_members, type='application/json')$members


# Since we mostly work with data frames, we turn this into one
# Problem: there is a list within our lists (latestAction), which would result
# in two rows for each bill in our data frame. So we want to flatten the lists first

# With purr package
library(purrr)
members <- map(members, flatten)


# Now we can easily turn the list of lists into a DF, with the dplyr function
# bind_rows
df_members <- bind_rows(members)

#save df_members in excel
install.packages("xlsx")
library(xlsx)

write.xlsx(df_members,"C:/Users/meierida/Documents/SICSS_2024/exercises/dm")

#looping?
offset <- 0
while(TRUE) {
  print(offset)
  
  httr_members <- GET(url = "https://api.congress.gov/v3/member",
                      query = list(format = "json",
                                   limit = 250,
                                   offset = 0,
                                   sort = "updateDate+desc",
                                   api_key = Sys.getenv("congress_key")))
  
    members <- content(httr_members, type='application/json') 
  
  
    members <- content(httr_members, type='application/json')$members
  
    members <- map(members, flatten)
  
    df_members_old <- bind_rows(members)
  
  length1 <- nrow(df_members)
  
  
  length2 <- nrow(df_members_old)
  
  if (length1 == length2) {
    break
  }
  
  offset <- offset+250
}                       