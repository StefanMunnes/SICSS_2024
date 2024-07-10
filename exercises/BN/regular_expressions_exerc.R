library(tidyverse)

text <- "   I hope you will have a great time during the 9 days of SICSS-Berlin.  Orange  \nIf you have any suggestions for impovemend, feel free to tell us in person or via sicss.2023@wzb.eu.    Orange "

#detect a line break
str_detect(text, "\\n")

#remove the line break
text <- str_replace(text, "\\n", "")

#loop to remove exactly 2 "Orange"
i <- 1
while(i < 3){
  text <- str_replace(text, "Orange", "")
  i <- i+1
}

#function to remove all the "Orange"
text <- str_replace_all(text, "Orange", "")

#remove the unnecessary whitespaces
text <- str_replace_all(text, "\\s\\s+", "")

#count the characters
str_count(text, "\\w")

#count the words
str_count(text, "\\s\\w+(\\s|\\[:punct:]")
