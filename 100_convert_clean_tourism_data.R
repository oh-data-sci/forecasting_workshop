library(tibble)
library(tidyr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(tsibble)
library(tsibbledata)
library(feasts)
library(fable)
library(readr)
# ---
tourism <- readxl::read_excel("data/tourism.xlsx")
tourisnd <- tourism %>% duplicated() 
sum(tourisnd)
tourism <- tourism %>%
  mutate(Quarter = yearquarter(Quarter))
tourism <- tourism %>% as_tsibble(
  index = Quarter,
  key = c(Region, State, Purpose) ) # Trips is automatically the measure
tourism
tourism %>% has_gaps() %>% select('.gaps') %>% summarise(sum)
tourism %>% count_gaps() 
tourism %>% scan_gaps()
tourism %>% fill_gaps(Trips=0L)
