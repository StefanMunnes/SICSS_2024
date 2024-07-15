library(tidyverse)


# CNN ---------------------------------------------------------------------
# Trump CNN -----------------------------------
cnn_trump <- readRDS("data/CNN_trump.Rds")

cnn_trump_e <- cnn_trump %>%
  mutate(date = 
           as.Date(
             str_sub(
               str_extract(timestamp, "(?<=,).*")
               , 6)
             , format = "%B %d, %Y"), # extract everything after the first comma
         title = str_squish(title),
         authors = str_squish(authors),
         authors = str_remove_all(authors, c("Opinion by|By|Analysis by|, CNN")),
         authors = str_replace_all(authors, " and |, | ;", ";"),
         authors = sapply(str_split(str_squish(authors), ";"), function(names) {
           paste(unique(names), collapse = ";")}), # This line splits the authors along the ;, and then only pastes together unique authors.. thereby removing the duplicates
         body = str_squish(body),
         search_term = "trump") %>%
  select(title, authors, body, url, article_length, date, search_term)

# Biden CNN -----------------------------------
cnn_biden <- readRDS("data/CNN_biden.Rds")

cnn_biden_e <- cnn_biden %>%
  mutate(date = 
           as.Date(
             str_sub(
               str_extract(timestamp, "(?<=,).*")
               , 6)
             , format = "%B %d, %Y"), # extract everything after the first comma
         title = str_squish(title),
         authors = str_squish(authors),
         authors = str_remove_all(authors, c("Opinion by|By|Analysis by|, CNN")),
         authors = str_replace_all(authors, " and |, | ;", ";"),
         authors = sapply(str_split(str_squish(authors), ";"), function(names) {
           paste(unique(names), collapse = ";")}), # This line splits the authors along the ;, and then only pastes together unique authors.. thereby removing the duplicates
         body = str_squish(body),
         search_term = "biden") %>%
  select(title, authors, body, url, article_length, date, search_term)

# Combine CNN -------------------------------------------------
cnn <- rbind(cnn_trump_e, cnn_biden_e)

write_rds(cnn, "data/CNN.Rds")

###########################################################################
# FOX ---------------------------------------------------------------------
# Trump FOX -----------------------------------
fox_trump <- readRDS("data/FOX_trump.Rds") %>%
  distinct(url, title, .keep_all = TRUE)

fox_trump_e <- fox_trump %>%
  mutate(date = str_replace(str_squish(timestamp), "^(\\w+\\s\\d+,\\s\\d{4}).*", "\\1"),
         date = as.Date(date, format = "%B %d, %Y"),
         title = str_squish(title),
         body = str_squish(body),
         authors = str_remove_all(authors, ";Fox News"),
         search_term = "trump") %>%
  select(title, authors, body, url, article_length, date, search_term)
  
# Biden FOX -----------------------------------
fox_biden <- readRDS("data/FOX_biden.Rds") %>%
  distinct(url, title, .keep_all = TRUE)

fox_biden_e <- fox_biden %>%
  mutate(date = str_replace(str_squish(timestamp), "^(\\w+\\s\\d+,\\s\\d{4}).*", "\\1"),
         date = as.Date(date, format = "%B %d, %Y"),
         title = str_squish(title),
         body = str_squish(body),
         authors = str_remove_all(authors, ";Fox News"),
         search_term = "biden") %>%
  select(title, authors, body, url, article_length, date, search_term)


# Combine FOX -------------------------------------------------
fox <- rbind(fox_trump_e, fox_biden_e)

write_rds(fox, "data/FOX.Rds")


