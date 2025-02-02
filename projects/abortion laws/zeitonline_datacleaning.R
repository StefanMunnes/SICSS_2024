
# Data wrangling. Variables needed:
# author (to create gender variable) 
# body 

library(tidyverse)
library(tidyr)
library(stringr)
library(dplyr)

library(gender)

data <- read.csv("~/SICSS_2024/projects/abortion laws/abortion_zeitonline.csv")

str(data)
head(data)


# title, summary and body 
zeit_clean <- data |>
  mutate(body = str_to_lower(str_squish(body)),
         summary = str_to_lower(str_squish(summary)),
         author = str_to_lower(str_squish(author)),
         title = str_to_lower(str_squish(title))) 

View(zeit_clean)


# clean "body" variable 

zeit_clean$body_clean <- zeit_clean$body |>
  str_replace_all("ä", "ae") |>
  str_replace_all("ö", "oe") |>
  str_replace_all("ü", "ue") |>
  str_replace_all("ß", "ss") |>
  # Remove text within curly brackets {} and angle brackets <>
  str_replace_all("\\{.*?\\}", "") |>
  str_replace_all("<.*?>", "") |>
  # Remove curly brackets {} and angle brackets <>
  str_replace_all("[{}<>]", "")

#print(zeit_clean$body_clean)

# cleaning of "author"
# Remove titles from the author column
zeit_clean$author_clean <- str_replace_all(zeit_clean$author, "\\b(Dr\\. dr\\. dr med\\. med\\.|Dr\\.|Prof\\.)\\s*", "")


# separate into single variables if more than one author

zeit_clean <- zeit_clean |>
  separate(author_clean, into = paste0("author", 1:13), sep = ";", fill = "right")

#zeit_clean
#print(zeit_clean$author13)

# get first names only to later use as a proxy for gender 

# Function to extract first names
extract_first_name <- function(full_name) {
  str_extract(full_name, "^[A-Za-z]+")
}

# Apply function to each column
#for (i in 1:ncol(zeit_clean)) {
 # col <- paste0("firstname", i)
  #zeit_clean[[col]] <- sapply(zeit_clean[[col]], extract_first_name)
# }

# write first names into separate columns
zeit_clean$firstname1 <- sapply(zeit_clean$author1, extract_first_name)
zeit_clean$firstname2 <- sapply(zeit_clean$author2, extract_first_name)
zeit_clean$firstname3 <- sapply(zeit_clean$author3, extract_first_name)
zeit_clean$firstname4 <- sapply(zeit_clean$author4, extract_first_name)
zeit_clean$firstname5 <- sapply(zeit_clean$author5, extract_first_name)
zeit_clean$firstname6 <- sapply(zeit_clean$author6, extract_first_name)
zeit_clean$firstname7 <- sapply(zeit_clean$author7, extract_first_name)
zeit_clean$firstname8 <- sapply(zeit_clean$author8, extract_first_name)
zeit_clean$firstname9 <- sapply(zeit_clean$author9, extract_first_name)
zeit_clean$firstname10 <- sapply(zeit_clean$author10, extract_first_name)
zeit_clean$firstname11 <- sapply(zeit_clean$author11, extract_first_name)
zeit_clean$firstname12 <- sapply(zeit_clean$author12, extract_first_name)
zeit_clean$firstname13 <- sapply(zeit_clean$author13, extract_first_name)


# determine gender (proxy) using first author name only
# Convert first_name column to character vector and handle missing values
zeit_clean$firstname1 <- as.character(zeit_clean$firstname1)
valid_indices <- !is.na(zeit_clean$firstname1)

# Use gender() function to determine genders
results <- gender(zeit_clean$firstname1[valid_indices], method = "ssa")

# save results
results <- as.data.frame(results)

# getting rid of duplicates, keeping name and gender

results_unique <- results |> 
  distinct(name, .keep_all = TRUE) |>
  select(name, gender)

results_unique

# merge results_unique dataframe with data_clean

merged_df <- zeit_clean |>
  left_join(results_unique, by = c("firstname1" = "name"))

merged_df

# save as csv
write_csv(merged_df, "~/SICSS_2024/projects/abortion laws/zeit_abortion_merged.csv")



















