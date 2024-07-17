library(tidyverse)
library(stringr)

data <- read.csv("vox_abortion.csv")
data1 <- data

data1[data1 == ""] <- NA
data1 <- na.omit(data1)
