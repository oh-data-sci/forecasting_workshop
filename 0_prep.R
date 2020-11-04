library(fpp3)
library(readr)

#------- prepare time series data used in this course ---------------
# the file 'ae_uk.csv' i expected to be found in the data/ folder. 
ae_filepath <- 'data/ae_uk.csv'

if(!file.exists(ae_filepath)){
  print(paste('file not found', ae_filepath))
  print(paste('searched from:',getwd()))
  print('please run fetch_files.sh first.')
  stop('manually forcing script to terminate before going on without data')
} else{
  # check the file format
  print(paste(ae_filepath, ':'))
  connect <- file(ae_filepath)
  cat(readLines(connect, n=3), sep="\n")
  close(connect)
}

# from examining the file snippet we conclude columns types and date types are american format
ae_uk <- readr::read_csv(ae_filepath,
                         col_types = cols(arrival_time=col_datetime(format = "%d/%m/%Y %H:%M"),
                                          gender=col_character(),
                                          type_injury=col_character()
                                          )
                         )

#------- check for duplicates ---------------
# count duplicate rows:
num_dupes <- ae_uk %>% duplicated() %>% sum() # count duplicates
if (num_dupes>0){
  ae_uk <- ae_uk %>% dplyr::distinct() # remove duplicates and get a distinct tibble
  print(paste('removed', num_dupes, 'duplicate rows')) # check the number of duplication if you want
}
ae_uk 

# now convert the tibble to tsibble, a time series object
# note that the time series index (the timestamps) are not regularly spaced,
# so need to  use `regular=FALSE` in as_tsibble()
ae_uk <- ae_uk %>% 
  as_tsibble(index=arrival_time, key=c(gender,type_injury), regular=FALSE)
# a single tsibble can contain many time series,lab session 12 has more information

# regularise an irregular index, create a new tsibble  
# can use `index_by()` and `summarise()` to regularize  an index. 
# in the current case, an hourly cadence is the smallest granularity likely to be needed
ae_uk_hourly <- ae_uk %>% 
  group_by(gender, type_injury) %>% # separate out each time series (4 in total)
  index_by(arrival_1h = lubridate::floor_date(arrival_time, "1 hour")) %>% 
  summarise(n_attendance=n()) %>% # count total number of visits in each series
  ungroup()
ae_uk_hourly
# hourly tsibble object, containing 4 time series, a total of 120k rows

#------- fill in gaps ---------------

# check each time series for gaps, missing values 
# which we interpret as entire hour block where no visit occurred in category
# where category = {male, female}, {major, minor}
has_gaps(ae_uk_hourly) # check for gaps
count_gaps(ae_uk_hourly) # count consecutive gaps
scan_gaps(ae_uk_hourly)  # show a sample of gaps

# interpret missing data as lack of visits, fill in the gaps with zero, 
print('summarise hourly')
ae_uk_hourly_key <- ae_uk %>% 
  group_by(gender, type_injury) %>% 
  index_by(arrival_1h = lubridate::floor_date(arrival_time, "1 hours")) %>% 
  summarise(n_attendance=n()) %>% # number of visits
  fill_gaps(n_attendance=0L) %>%  # fill in missing 
  ungroup()
# ae_uk_hourly is a tsibble with regular space of 1 hour, 
# you can change it to any interval. floor_date() understands e.g. 
#   "2 hours","3 hours", etc. 
# from the hourly series we can aggregate up to daily, weekly , etc

# either build a daily attendance for each combination of gender and type_injury
print('summarise daily')
ae_uk_daily_key <- ae_uk_hourly %>% 
  group_by(gender, type_injury) %>% 
  index_by(year_day=as_date(arrival_1h)) %>% 
  summarise(n_attendance=sum(n_attendance)) #  add all the hourly number of visitors
# or combine all time series into and aggregated daily series. 
ae_uk_daily <- ae_uk_hourly %>% 
  index_by(year_day=as_date(arrival_1h)) %>% 
  summarise(n_attendance=sum(n_attendance))

ae_uk_daily <- ae_uk_hourly %>% 
  index_by(year_day=as_date(arrival_1h)) %>% 
  summarise(n_attendance=sum(n_attendance)) %>% # for all injury_types, each gender
  summarise(n_attendance=sum(n_attendance))     # for all injury_types, both genders

# this gives you total monthly attendance for each combination of gender and type_injury
print('summarise monthly')
ae_uk_monthly_key <- ae_uk_hourly %>% 
  group_by(gender, type_injury) %>% 
  index_by(month=yearmonth(arrival_1h)) %>% 
  summarise(n_attendance=sum(n_attendance))
# this gives you total monthly attendance for each date
ae_uk_monthly <- ae_uk_hourly %>% 
  index_by(month=yearmonth(arrival_1h)) %>% 
  summarise(n_attendance=sum(n_attendance))

print('summarise quarterly')
# this gives you total quasterlyattendance
ae_uk_quarterly <- ae_uk_hourly %>% 
  index_by(quarter=yearquarter(arrival_1h)) %>% 
  summarise(n_attendance=sum(n_attendance))

#------- save processed progress ---------------
ae_uk_hourly    %>% write_csv('data/processed/ae_uk_hourly.csv')
ae_uk_daily     %>% write_csv('data/processed/ae_uk_daily.csv')
ae_uk_monthly   %>% write_csv('data/processed/ae_uk_monthly.csv')
ae_uk_quarterly %>% write_csv('data/processed/ae_uk_quarterly.csv')

# save tsibbles as serialised data for future labs
ae_uk_hourly    %>% saveRDS(file='data/processed/ae_uk_hourly.RDS')
ae_uk_daily     %>% saveRDS(file='data/processed/ae_uk_daily.RDS')
ae_uk_monthly   %>% saveRDS(file='data/processed/ae_uk_monthly.RDS')
ae_uk_quarterly %>% saveRDS(file='data/processed/ae_uk_quarterly.RDS')
# tidy up workspace to save memory
# rm(list=c("ae_uk", "ae_uk_daily_key", "ae_uk_monthly_key", "ae_uk_hourly","ae_uk_daily","ae_uk_monthly","ae_uk_quarterly"))


# nb add other public health data from public health england?
# fingerprints: interact with Public Health England’s Fingertips data tool.
# Fingertips is a major public repository of population and public health indicators for England. 
# if (!require(fingertipsR)) install.packages("fingertipsR", repos = "https://dev.ropensci.org")
