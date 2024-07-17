library(dplyr)
library(gender)

#Delete accidentally captured text
federalist1 <- federalist %>%
  mutate(final_text = sub(".*?Email", "", final_text, ignore.case = TRUE))

#separate authors into indiv columns
federalist1$author <- str_replace_all(federalist1$author, " and ", ",")
federalist2 <- federalist1 %>%
  separate_wider_delim(author,",",names_sep = "",too_few = "align_start")

#change names into last, first format
#test
# name <- c("First Last", "First F. Last", "First Letzte Last", "First de Last", "First Last-Letzte", "F. First Last", "F.G.H. Last")
# str_replace(name, 
#             "^(([:alpha:]\\.)?([:alpha:]\\.)?([:alpha:]\\.)?\\s*[:alpha:]+(\\s[:alpha:]\\.)?(?!,))\\s(.+(-.+)?)$", 
#             "\\4, \\1")
#implement
# regex <- "^(([:alpha:]\\.)?([:alpha:]\\.)?([:alpha:]\\.)?\\s*[:alpha:]+(\\s[:alpha:]\\.)?(?!,))\\s(.+(-.+)?)$"
# federalist3 <- federalist2 %>%
#   mutate_at(vars(starts_with("author")), ~ str_replace(.,  regex , "\\6, \\1"))

federalist3 <- federalist3 %>%
  separate_wider_delim(author1,",",names = c("Last_Name","Name"),too_few = "align_start")
federalist3 <- federalist3 %>%  mutate(Name = trimws(Name))


federalist3 <- federalist3 %>%
  separate_wider_delim(Name," ",names = c("Name","Middle Initial"), too_few="align_start")

#Make vector of unique first names
Federalist_FN <- c(federalist3$Name) %>%
  unique()%>%
  na.omit()

#Run gender  
Federalist_gen <- gender(Federalist_FN,years=2012, method="ssa")
colnames(Federalist_gen)[1]= "Name"

#lookup gen
federalist3_gen <- left_join(federalist3,Federalist_gen)

write.csv(federalist3_gen,"~/SICSS/SICSS_2024/projects/abortion laws/Federalist_article_data.csv")
