library(httr)
library(jsonlite)
library(tidyverse)
library(tibble)

# Replace with your actual API endpoint and API key
my_api_url <- "https://api.congress.gov/v3/member"
my_api_key <- "imX1xY4hmwiqocwflhL7s1f2vffGEebuVSb1BrjF"
max_responses <- 250
offset <- 0
all_members <- tibble()
delay_seconds <- 1  # Delay in seconds between requests

repeat {
  # Set up query parameters, including pagination using offset
  query_params <- list(
    format = "json",
    limit = max_responses,
    offset = offset,
    api_key = my_api_key
  )
  
  # Make the GET request
  response <- GET(url = my_api_url, query = query_params)
  

  
  # Check for successful request
  if (status_code(response) != 200) {
    stop("Failed to retrieve data: ", status_code(response))
  }
  
  # Extract the contents as JSON format/lists
  new_members <- fromJSON(content(response, 
                             as = "text", 
                             encoding = "UTF-8"), 
                     flatten = TRUE)$member
  
  all_members <- rbind(all_members, as.data.frame(new_members))

  
  print(new_members)
  
  # Check if we received any data
  if (length(new_members) == 0) {
    break
  } 
  else {
    all_data <- rbind(all_data, df_new_members)
    offset <- offset + max_responses
    Sys.sleep(delay_seconds)  # Add delay between requests
  }
}
