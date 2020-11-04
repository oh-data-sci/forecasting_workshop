# ---------Lab Session 9: regression-------------
# when doing time series forecasting, we need to have always one single tsibble containing all variables
se <- read_csv("data/se.csv")# read a dataset containing dummy variables
se <- se %>% mutate(date=lubridate::dmy(date))# observe the date variable in se:
#is it a date object? what is it format? why do we need to use dmy()?
ae_holiday <- inner_join(ae_daily,se, by="date")# join dummy variable data to the previous dataset

# we split the data into train and test as before
f_horizon <- 42
test <- ae_holiday %>% slice((n()-f_horizon-1):n())
tarin <- ae_holiday %>% slice(1:(n()-f_horizon))

# we train data using a regression model
# TSLM is a Time Series Linera Regression Model
# in the left hand side of TSLM(), we have the variable we want to forecast
# in the right hand side, we have all variable we use as predictor
# trend() is just a linear trend increasing with time, you may want to check trend(knots=)
fit <- tarin %>% 
  model(lr= TSLM(n_attendance ~ trend()+season(),
                 lr_se=TSLM(n_attendance ~ trend()+season()+ `Black Friday`+`Boxing Day`+`Christmas Day`+`Halloween Day`+`New Years Day`)
  )
  )
fit %>% select(lr_se) %>% report()# we can check the output of any regression model
# which predictor is significant?
# what are s0,s1, s2,...

# we pass mable to forecast(), attention: here you have to pass test set to new_data=test,
# try this and see what you get: fcast <- fit %>% forecast(h="42 days") 
fcast <- fit %>% forecast(new_data=test) 
# we calculate accuracy by model
fcast %>% accuracy(ae_holiday, by=".model") %>% 
  select(.model,RMSE,MAE)# we select RMSE,MAE for each model
fcast %>% autoplot(filter(ae_daily, year(date)>2015))# we can visualise forecast

## ----Time series cross validation with exogenious variables----
# how do we do TSCV when having exogenious variables? I provide the code without explaining it
# try to replicate and understand the code!
f_horizon <- 42
tarin_tr <- tarin %>% slice(1:(n()-f_horizon)) %>%
  stretch_tsibble(.init = 4*365, .step = 1)
m_date <- tarin %>% pull(date)
test_tr <- tarin %>% filter(date>m_date[4*365]) %>% 
  slide_tsibble(.size = f_horizon, .step = 1, .id = ".id")

fit_tr <- tarin_tr %>% 
  model(lr= TSLM(n_attendance ~ season(),
                 lr_se=TSLM(n_attendance ~ trend()+season()+ `Black Friday`+`Boxing Day`+`Christmas Day`+`Halloween Day`+`New Years Day`)
  )
  )
fcast_tr <- fit_tr %>% forecast(new_data=test_tr, h="42 days")
acc <- fcast_tr %>% accuracy(test_tr)