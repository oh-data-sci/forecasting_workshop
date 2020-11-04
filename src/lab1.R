# -------Lab Session 2------------
# time plot
# create a daily series to work with a single time series, in tsibble you can work many time series, go to lab session 12 for more information

#this will give you total number of attendance each day
ae_daily <- ae_hourly %>% 
  index_by(year_day=as_date(arrival_1h)) %>% 
  summarise(n_attendance=sum(n_attendance))

#if you want to play with different timeseries, try the following too

#this will give you daily attendance for each combination of gender and type_injury
ae_daily_key <- ae_hourly %>% group_by(gender, type_injury) %>% 
  index_by(year_day=as_date(arrival_1h)) %>% 
  summarise(n_attendance=sum(n_attendance))

# this gives you total monthly attendance for each combination of gender and type_injury
ae_monthly_key <- ae_hourly %>% group_by(gender, type_injury) %>% 
  index_by(month=yearmonth(arrival_1h)) %>% 
  summarise(n_attendance=sum(n_attendance))

# this gives you total monthly attendance for each date
ae_monthly <- ae_hourly %>% 
  index_by(month=yearmonth(arrival_1h)) %>% 
  summarise(n_attendance=sum(n_attendance))

# this gives you total monthly attendance for each quarter
ae_quarterly <- ae_hourly %>% 
  index_by(quarter=yearquarter(arrival_1h)) %>% 
  summarise(n_attendance=sum(n_attendance))

##-----time series graphics
ae_daily %>% autoplot(n_attendance) # create a time plot of daily data
# you can use filter_index or head() and tail() to plot a subset of data , try ?filter_index
ae_daily %>% tsibble::filter_index("2016-02") %>% autoplot(n_attendance)
ae_daily %>% head(n=100) %>% autoplot()
ae_daily %>% tail(n=100) %>% autoplot()
ae_hourly %>% autoplot(n_attendance) # create a time plot of hourly data

#you can also plot monthly time series
  ae_monthly %>% 
  autoplot(n_attendance) +
  labs(y = "attendances", x="Month",
       title = "Monthly A&E attendance",
       subtitle = "UK hospital")

#---- Lab Session 3--------
# use seasonal and subseries plots to check wether series contain seasonality 
ae_daily %>% gg_season(n_attendance) 
ae_daily %>% gg_subseries(n_attendance)

ae_hourly %>% gg_season(n_attendance) 
ae_hourly %>% gg_season(n_attendance,period = "day")# change period to period = "week"
ae_hourly %>% gg_subseries(n_attendance)

# How do you create a seasonal plot for the monthly and quartely series series
ae_hourly %>% index_by(year_month=yearmonth(arrival_1h)) %>%
  summarise(n_attendance=sum(n_attendance)) %>% 
  gg_season()# replace gg_season with gg_subseries()

#Question: is there any seasonality in the daily time series? what about hourly and monthly?
# -------------------------Lab Session 4-------------------------

ae_daily %>% gg_lag(n_attendance, lags = c(1:14), geom = "point")# create lag plots for 14 lags, from 1 to 14
ae_daily %>% ACF(lag_max = 14)# compute autocorrelation fucntion
ae_daily %>% ACF(n_attendance, lag_max = 14) %>% autoplot()# plot acf

ae_daily %>% gg_tsdisplay()# plot time plot, acf and season plot, check ?gg_tsdisplay

ae_daily %>% features(n_attendance, ljung_box, dof=0)# use ljung box to test wether ACF is significant, if p-value is amll, << 0.05 them there is a significant autocorrelation 

# what autocorrelation will tell us? whu=ich key features could be highlighted by ACF?

## ----make any graph using ggplot2 ----
#You can create any graph that helps you to better understand data!
# I recommed you to try geom_box() which is helpful to better understand the variations

# here I tried to seee if attendance of female is different over the weekend comparing to the weekday
weekend_an_weekday <- ae_hourly %>% group_by(gender) %>% 
  summarise(n_attendance=sum(n_attendance)) %>% 
  mutate(
    Date=lubridate::as_date(arrival_1h),
    hour=lubridate::hour(arrival_1h),
    Day = lubridate::wday(arrival_1h, label = TRUE),
    Weekend = (Day %in% c("Sun", "Sat"))) %>% 
  filter(gender=="female") 
weekend_an_weekday %>% ggplot(aes(x = hour, y = n_attendance)) +
  geom_line(aes(group=Date)) +
  facet_grid(Weekend ~., scales="free_y")
