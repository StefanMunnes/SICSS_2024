#scrape
#filter dates

scrape_article <- function(url) {
  article_page <- read_html(url)

  Sys.sleep(1)
  print(url)

  title <- article_page %>%
    #html_node("h1.headline") %>%
    html_node(".bWszMR") %>%
    html_text(trim = TRUE)

  author <- article_page %>%
    html_node(".hhBctz") %>%
    html_text(trim = TRUE)
  # Remove "By " and trailing comma from author name
  author <- gsub("By\\s+|,$", "", author)

  date_string <- article_page %>%
    html_node(".WPunI") %>%
    html_text(trim = TRUE)
  # Format date_str into appropriate form
  if (grepl("days ago", date_string) || grepl("day ago", date_string)) {
    # Handle relative date like "1 day ago", "2 days ago"...
    days_ago <- as.numeric(gsub("\\D", "", date_string))
    date <- Sys.Date() - days_ago  # Calculate the date
  } else if (grepl("hrs ago", date_string) || grepl("hr ago", date_string)) {
    # Handle relative date like "1 hour ago", "2 hours ago"...
    hours_ago <- as.numeric(gsub("\\D", "", date_string))
    date <- Sys.time() - hours(1) * hours_ago
  } else {
    # Handle date string like "25 June 2024"
    date <- dmy(date_string)  # Convert to Date object using lubridate
  }

  body <- article_page %>%
    html_nodes(".fYAfXe") %>%
    html_text(trim = TRUE) %>%
    paste(collapse = " ")

  article <- tibble(
    title = title,
    author = author,
    date = date,
    body = body,
    url = url)

  return(article)
}

all_articles <- lapply(news_urls, scrape_article)

all_articles <- bind_rows(all_articles)
test_article <- scrape_article("https://www.bbc.com/news/articles/crge8vjg8y3o")

write.csv(all_articles, "bbc_df.csv", row.names = FALSE)

#Preprocessing

#time cut # 23 June 2024
class(all_articles$date)

cutoff_date <- as.Date('2023-06-01')

# Filter the dataframe
filtered_bbc <- all_articles %>%
  filter(date >= cutoff_date)

filtered_bbc

#remove urls that contain "https://www.bbc.com/news/video"

filtered_bbc2 <- filtered_bbc %>%
  filter(!str_detect(url, "https://www.bbc.com/news/video"))

filtered_bbc2

#dummy to classify if "Just Stop Oil" and others without as benchmark
#Add a dummy that contains a column which indicates whether the body of the article contains "Just Stop Oil"

filtered_bbc3 <- filtered_bbc2 %>%
  mutate(just_stop_oil = ifelse(str_detect(body, "Just Stop Oil"), 1, 0))

hist(filtered_bbc3$just_stop_oil)

#other protests

write.csv(filtered_bbc3, "pp_bbc_df.csv", row.names = FALSE)
