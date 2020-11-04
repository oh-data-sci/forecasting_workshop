library(fpp3)
ae_uk_hourly <- readRDS(file='data/processed/ae_uk_hourly.RDS')
ae_uk_daily  <- readRDS(file='data/processed/ae_uk_daily.RDS')

# -------Lab Session 2------------
##-----time series graphics
# autoplot() works well for time series plots
ae_uk_daily %>% autoplot(n_attendance) # create a time plot of daily data
# add titles and labels
ae_uk_daily %>% 
  autoplot(n_attendance, col='pink') + 
  theme_minimal() +
  labs(y="number of visits", 
       x="date",
       title="daily number of visits to a&e (full date range)",
       subtitle="uk hospitals")
ggsave('graphs/ae_uk_autoplot_full.png')
# you can use filter_index or head() and tail() to plot a subset of data , 
ae_uk_daily %>% 
  tsibble::filter_index("2016" ~.) %>% 
  autoplot(n_attendance) + 
  theme_minimal() +
  labs(y="number of visits", 
       x="date",
       title="daily number of visits to a&e (full date range)",
       subtitle="uk hospitals")
ggsave('graphs/ae_uk_autoplot_2016.png')
# try ?filter_index
ae_uk_daily %>% 
  head(n=100) %>% 
  autoplot() +
  theme_minimal() +
  labs(y="number of visits", 
       x="date",
       title="daily number of visits to a&e (first 100 dates)",
       subtitle="UK hospitals")
ae_uk_daily %>% 
  tail(n=100) %>% 
  autoplot() +
  theme_minimal() +
  labs(y="number of visits", 
       x="date",
       title="daily number of visits to a&e (last 100 dates)",
       subtitle="UK hospitals")
ae_uk_hourly %>%
  autoplot(n_attendance) +
  theme_minimal() +
  labs(y="number of visits", 
       x="date",
       title="hourly number of visits to a&e",
       subtitle="UK hospitals")

#you can also plot monthly time series
ae_uk_monthly %>% 
  autoplot(n_attendance) +
  labs(y = "attendances", x="Month",
       title = "Monthly A&E attendance",
       subtitle = "UK hospital")


