library(tidyverse)
library(rvest)
library(stringi)


get_urls <- function(page) {
  website_search <- read_html(paste0("https://time.com/search/?q=abortion&page=", page))
  
  urls <- website_search %>%
    html_nodes(".media-heading a") %>%
    html_attr("href")
  
  Sys.sleep(5)
  return(urls)
}

all_urls <- lapply(1:11, get_urls) %>%
  unlist()

#url <- "https://time.com/6198062/rape-victim-10-abortion-indiana-ohio/"

get_all_articles <- function(url) {
  print(paste(url, all_urls[[url]]))
  website <- read_html(all_urls[[url]])
 
   article <- tibble(
    title = website %>%
      html_node("#article-header .self-baseline, .longform-headline") %>%
      html_text(),
    
    author = website %>%
      html_node(xpath='//*[@id="article-body"]//a[1]') %>%
      html_text(),
    
    tags = website %>%
      html_nodes("#article-header a") %>%
      html_text() %>%
      paste(collapse = ";"),
    
    date = website %>%
      html_node("time") %>%
      html_text(),
    
    body = website %>%
      html_nodes("#article-body p, p") %>%
      html_text() %>%
      paste(collapse = " "),
    
    url = all_urls[[url]]
  )
  return(article)   
  Sys.sleep(2)
}

# Exectute the function for all URLs previously collected
all_articles <- lapply(seq_along(all_urls), get_all_articles) 

# Transform lists to data frame
abortion <- bind_rows(all_articles)


#CLEAN-------------------------------------------------------------------------------
time_clean <- abortion
time_clean$author <-  str_replace_all(time_clean$author,c(
  " / Made by History"="",
  "Made by History / "="",
  " / AP"=""))
time_clean$author <-  str_replace(time_clean$author,"/.*","")
time_clean <- separate_wider_delim(time_clean,author,delim = " and ",names_sep = "", too_few = "align_start")
time_clean <- separate_wider_delim(time_clean,author1,delim = " ",names = c("name","rest_of_name"), too_many = "merge")
time_clean1 <- time_clean[!is.na(time_clean$title), ]

time_authors <- time_clean1$name %>%
  unique()

time_authors_gender <- gender(time_authors,years = 2012,method="ssa")


time_clean1_gender <- left_join(time_clean1,time_authors_gender)

time_clean1_gender$gender[time_clean1_gender$name == "Solcyré"] <- "female"
time_clean1_gender$gender[time_clean1_gender$name == "Simmone"] <- "female"
time_clean1_gender$gender[time_clean1_gender$name == "Kyung-eun"] <- "female"
time_clean1_gender$gender[time_clean1_gender$name == "Krystale"] <- "female"
time_clean1_gender$gender[time_clean1_gender$name == "Suyin"] <- "female"


time_clean1_gender <- time_clean1_gender[!is.na(time_clean1_gender$gender), ]

write.csv(time_clean1_gender,"~/SICSS/SICSS_2024/projects/abortion laws/time_abortion_MP.csv")

#TOKENIZING-----------------------------------------------------------------------------
corpus <- corpus(time_clean1_gender,text_field = "body")
head(summary(corpus))


#stopwords("en")

tokens_pp <- tokens(
  corpus,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_numbers = TRUE,
  remove_separators = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(words2remove, padding = FALSE) |> # show padding
  tokens_wordstem(language = "en")

dfm_pp <- dfm(tokens_pp) %>%
  dfm_remove("abort")
head(dfm_pp)
dim(dfm_pp)

textstat_frequency(dfm_pp, n = 20)
time_topfeat <- topfeatures(dfm_pp,n=15)
print(time_topfeat)

dfm_pp <- dfm_trim(dfm_pp, min_termfreq = 2, termfreq_type = "count")
dim(dfm_pp)

time_collocations <- textstat_collocations(tokens_pp) |>
  head(15)
write.csv(fed_collocations,"~/SICSS/SICSS_2024/projects/abortion laws/federalist/fed_collocations.csv")

#FEATURE-COOCCURENCE MATRIX
fcm_pp <- fcm(tokens_pp, context = "window", count = "frequency", window = 3)
# fcm_pp <- fcm(dfm_pp, context = "document", count = "frequency")
dim(fcm_pp)

fcm_pp_subset <- fcm_select(fcm_pp, names(topfeatures(dfm_pp, 20)))

textplot_network(fcm_pp_subset)