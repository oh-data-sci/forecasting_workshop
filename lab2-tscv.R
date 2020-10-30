# -------------------------Lab Session 6 Time series cross validation-------------------------

# what is your forecast horizon?
f_horizon <- 42# forecast horizon

# split datainto test and the rest/train(initial training plus validation)
test <- ae_daily %>% slice((n()-(f_horizon-1)):n())# create test set equal to forecast horizon
train <- ae_daily %>% slice(1:(n()-f_horizon))# craete train set
nrow(ae_daily)==(nrow(test)+nrow(train))# check if split is correct, the result should be TRUE

# using time series cross validation(TSCV)/ rolling forecast
# why do we use TSCV?
# how do we do TSCV in R? 
#1. create different .id/time series using stretch_tsibble(), what is .init and .step?
#2. model/train each .id/time series and each model, 
#3. forecast for each .id and each model and given forecast horizon

#1. Create different timeseries using stretch_tsibble
train_tr <- train %>% # split data into folds with increasing size
  slice(1:(n()-42)) %>%
  stretch_tsibble(.init = 4*365, .step = 1)
# .init is the size of initial time series, .step is the increment step >=1
# what is the purpose of using slice(1:(n()-42))?
# how many time series/fold we create with this process? what is te new variable .id?
# 2. train models for each time series and each .id
ae_mode_tr <- train_tr %>%
  model(
    mean = MEAN(n_attendance),
    naive = NAIVE(n_attendance),
    drift = RW(n_attendance ~ drift()),
    snaive = SNAIVE(n_attendance)
  )
ae_mode_tr# observe mable
# Produce forecast for h=42 or 42 days for each .id and each model
ae_fc_tr <- ae_mode_tr %>% forecast(h=42)
ae_fc_tr#observe fable


# calculate forecast accuracy both point forecast and prediction interval using accuracy()
# accuracy() need both the forecast object/fable and all data in train
# what happens if you use train_tr, instead of train in the following code
fc_accuracy <- ae_fc_tr %>% accuracy(train,measures = list(
  point_accuracy_measures,
  interval_accuracy_measures
)) 
# you can specify which accuracy measure you want using measures = list()
# if use  ae_fc %>% accuracy(train), it calculates only point forecast

fc_accuracy %>% select(.model,RMSE, MAE,winkler)

# we can report the forecast accuracy using RMSE, MAE and winkler
# the accuracy measure is calculated for each .id/time series and then averaged across all foled(using mean())
# this will give us an average accuracy measure across all .id for each model


# you can plot forecasts
ae_model <- train %>% model(MEAN(n_attendance))# specify and train MEAN method on all train data
ae_model %>% forecast(test) %>% # forecast and visualise it, you can provide the test set when using forecast() instead of h=42
  autoplot(filter_index(ae_daily,"2016"))

#-----residual diagnostic------

# results sghow that mean method has the lowes error among 4 methods we compared , we can check wether 
#this method captured adequate information/systematic patterns in the time series
ae_fit %>% filter(.model=="mean") %>% gg_tsresiduals()# check residual for the fitted/trained model, do they look like white noise/random?
ae_fit %>% filter(.model=="mean") %>% 
  augment() %>% features(.resid, ljung_box, lag=14,dof=0)

#what do you conclude?

##-aditional excercise-------------
#somnetime it might be useful to track the accuracy of the model across each period of the forecast horizon
#from h=1,2,3,4,...,42. to get that you need to follow the followign steps

View(ae_fc_tr[1:43,])# in ae_fc_tr( a fable object) each .id is representing the forecast for each fold/ series creates
# if you want to get the forecast generated for each .id/series, each model and across all forecast horizon, then
#group_by() ,id and ,model first and then create a new variable called h using row_number() for forecast horizon
# check ?row_number
ae_fc <- ae_fc_tr %>% 
  group_by(.id,.model) %>% 
  mutate(h=row_number()) %>% ungroup()
View(ae_fc[1:43,])# view the first 43 rows of ae_fc toobserve h

# calculate forecast accuracy both point forecast and prediction interval using accuracy()
# accuracy() need both the forecast object/fable and all data in training test
# what happens if you use train_tr, instead of train in the following code
fc_accuracy <- ae_fc %>% accuracy(train,measures = list(
  point_accuracy_measures,
  interval_accuracy_measures
)) 
# you can specify which accuracy measure you want using measures = list()
# if use  ae_fc %>% accuracy(train), it calculates only point forecast
fc_accuracy %>% group_by(.model) %>% 
  summarise(RMSE=mean(RMSE),
            MAE=mean(MAE),
            winkler=mean(winkler))
# we can report the forecast accuracy using RMSE, MAE and winkler
# the accuracy measure is calculated for each fold/series create and then we average across all foled(using mean())
# this will give us an average accuracy measure across all folds

