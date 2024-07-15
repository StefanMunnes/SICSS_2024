
# Data wrangling. Variables needed:
# author (to create gender variable) 
# body 

library(tidyverse)
library(stringr)

data <- read.csv("~/SICSS_2024/projects/abortion laws/abortion_zeitonline.csv")

str(data)
head(data)


# title, summary and body 
zeit_clean <- data |>
  mutate(body = str_to_lower(str_squish(body)),
         summary = str_to_lower(str_squish(summary)),
         author = str_to_lower(str_squish(author)),
         title = str_to_lower(str_squish(title))) # yep, that's it

View(zeit_clean)

# 1. cleaning of "author" 

# Function to clean author names
clean_author <- function(name){
  # Remove leading whitespace and colons
  name <- str_trim(name)
  name <- str_replace(name, "^[:\\s]+", "")
  
  # Remove leading titles and their following colons
  name <- str_replace(name, "^[^:]*: ", "")
  
  # Remove leading whitespace again if any
  name <- str_trim(name)
  
  # Remove 'von' or 'Von' if it's the last word
  #name <- str_replace(name, "(\\s+von|\\s+Von)$", "")
  name <- str_replace(name, "(.*\\b[Vv]on\\s+)", "")
  
  # Remove anything after a comma
  name <- str_replace(name, ",.*$", "")
  
  # Trim again in case of any leading/trailing whitespaces
  name <- str_trim(name)
  
  return(name)
}

# Apply the function to the author column
zeit_clean$author <- sapply(zeit_clean$author, clean_author)






# 2. create new variable that includes gender of author
