library(dplyr)
library(reticulate)

data_fox <- readRDS("data/FOX.Rds")
data_cnn <- readRDS("data/CNN.Rds")

data_news <- bind_rows(
  list("fox" = data_fox, "cnn" = data_cnn),
  .id = "source"
)

set.seed(161)

data_news <- slice_sample(data_news, n = 20)

library(here)
use_python("C:/Users/Lenovo/AppData/Local/Programs/Python/Python312/python.exe")

install_miniconda()

devtools::install_github("farach/huggingfaceR")
library(huggingfaceR)


sentence_transformers <- hf_load_pipeline(
  model_id = "sentence-transformers/all-MiniLM-L6-v2",
  task = ""
)