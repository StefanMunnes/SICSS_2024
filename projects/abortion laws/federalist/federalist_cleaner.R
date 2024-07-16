library(dplyr)

#Delete accidentally captured text
federalist1 <- federalist %>%
  mutate(final_text = sub(".*?Email", "", final_text, ignore.case = TRUE))

#separate authors into indiv columns
federalist1$author <- str_replace_all(federalist1$author, " and ", ",")
federalist2 <- federalist1 %>%
  separate_wider_delim(author,",",names_sep = "",too_few = "align_start")

#change names into last, first format
#test
name <- c("First Last", "First F. Last", "First Letzte Last", "First de Last", "First Last-Letzte", "F. First Last", "F.G.H. Last")
str_replace(name, 
            "^(([:alpha:]\\.)?([:alpha:]\\.)?([:alpha:]\\.)?\\s*[:alpha:]+(\\s[:alpha:]\\.)?(?!,))\\s(.+(-.+)?)$", 
            "\\4, \\1")
#implement
regex <- "^(([:alpha:]\\.)?([:alpha:]\\.)?([:alpha:]\\.)?\\s*[:alpha:]+(\\s[:alpha:]\\.)?(?!,))\\s(.+(-.+)?)$"
federalist3 <- federalist2 %>%
  mutate_at(vars(starts_with("author")), ~ str_replace(.,  regex , "\\6, \\1"))

#for people who only use first initials, this didn't reaarrange them, but oh well


