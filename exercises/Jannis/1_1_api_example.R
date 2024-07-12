# SICSS Berlin - Day 2 - July 9, 2024
# API - Example

library(tidyverse)
library(httr)


# Google what you are looking for 

# Check out what they have on offer: https://api.congress.gov/


# Sign up for API-Key: https://api.congress.gov/sign-up/
# wv4LpOddq9Ed4RqZwfnIsJZCrgAldCAacdshmMsO

file.edit("~/.Renviron")
# Add "congress_key = [your key]" and save
# Restart R, then you can access the key via
Sys.getenv("congress_key")


# Look up the URL and the queries
https://api.congress.gov/v3/bill?api_key=[INSERT_KEY]

# offset is important because of the limit. Within your search criteria there might be
# more results, in that case you have to itterate through offset (offset = 0, offset = 250, offset = 500 etc.)
# This is important, because this is relevant for most APIs, but is solved differently.


# Now all we need is to 'build' the API call using httr
httr_bills <- GET(url = "https://api.congress.gov/v3/bill",
                  query = list(format = "json",
                          limit = 250,
                          offset = 0,
                           sort = "updateDate+desc",
                           api_key = Sys.getenv("congress_key")))

# Extract the contents as JSON format/lists
bills <- content(httr_bills, type='application/json') 

# We extracted three elements, but we only need the bills list
bills <- content(httr_bills, type='application/json')$bills




# Since we mostly work with data frames, we turn this into one
# Problem: there is a list within our lists (latestAction), which would result
# in two rows for each bill in our data frame. So we want to flatten the lists first

# With purr package
library(purrr)
bills <- map(bills, flatten)

# With base R
flatten_list <- function(x) {
  do.call(c, x) # the c stands for combine and is a base R function, see ?c
}
bills <- lapply(bills, flatten_list)

# Now we can easily turn the list of lists into a DF, with the dplyr function
# bind_rows
df_bills <- bind_rows(bills)
