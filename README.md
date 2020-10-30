forecasting_workshop
===
# introduction
these are my notes from the nhs-r workshop on forecasting in r,  taught by [bahman rostami-tabar](https://twitter.com/bahman_R_T), as seen  [here](https://nhs-forecasting.netlify.app). the workshop follows the [excellent text by hyndman and athanasopoulos](https://otexts.com/fpp3/).

# session 1
learn about the forecasting process and how to identify what to forecast for a given decision.
also analyse key features of a time series and use time series graphics in :r: to detect systematic patterns in your data.

[see here](https://nhs-forecasting.netlify.app/post/01-week/).

- judgemental forecast (in the absence of time series or explanatory data)
- regression forecast (when all you have are are explanatory data, no time series)
- time series forecast (when you have time series)
- here focus in on tidy workflow
- prepare, visualize, specify model, estimate model, evaluate model, forecast
- (good) forecasting models capture the underlying patterns and relationships from the historical data, while ignoring anomalous past events.
- establish forecast horizon	
- an honest estimation of the future, based on information available at time of generation.
- there is a broken link on the pre session website. use [this](https://nhs-forecasting.netlify.app/slides/1.1-prepare_data_tsibble.pdf) instead.
- `tsibble` is a tidy form of time series data, that allows it to be used in `todyverse` packages just as if it were a `data.frame` or a `tibble`.
- the steps to preparing a `tsibble` for time series analysis are:
	+ deduplication
	+ gap-filling
	+ time step regularization
	+ verification by visualization
- `autoplot()`
# session 2
- trend
- seasonality (constant length) versus cyclic patterns (variable length)
- autocorrelation
- noise
- `gg_season()` and `gg_subseries()` to determine seasonality 
- `gg_lag` to find autocorrelation, plots: `y(t) vs y(t-k)` for various lags, k
- correlation measures strength of linear relationship between two variables
- autocorrelation measures strength of linear relationship between a variable at two times separated by specific lag
- `ACF() %>% autoplot()` plots correllogram
- `gg_tsdisplay()`
- workflow
- `fable` ("forecast table"): model functions like `NAIVE()`, `SNAIVE()`
- `model( mode1=MODELFUNC(), model2=MODEFUNC)`
```
my_mable <- my_data %>% model(
	choose_name1 = MODEL_1(response_variable ~ term1+...), 
	choose_name2 = MODEL_2(response_variable ~ term1+...), 
	choose_name3 = MODEL_3(response_variable ~ term1+...), 
	choose_name4 = MODEL_4(response_variable ~ term1+...)
)
```

- `mable`: "model table":
	+ one row per time series from `tsibble` object
	+ accepts `dplyr`, `data.frame`, `tibble`and other tidy operations.
- `report()`, `tidy()`, `glance()`, `augment()`, `forecast()`, `features()`
-  `fable` is a forecast table, with point forecasts and distributions
- `gg_tsresiduals()`

# session 3
- `ETS()`: error, trend, seasonality
	+ error: additive, multiplicative, none
	+ trend: additive, multiplicative, additive-damped, multiplicative damped, none
	+ seasonality: additive, multiplicative, additive-damped, multiplicative damped, none
- simple exponential smoothing, local level model, : `ETS(A,N,N)`, `ETS(M,N,N)`
	+ weighted moving average with exponentially decaying weights
	+ single parameter, initial weight
- holt's method: `ETS(A,A,N)`
- holt-winter: `ETS(A,A,A)`
# session 4
- 
-
- 
- 
# session 5
