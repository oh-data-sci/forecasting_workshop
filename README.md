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
- an honest estimation of the future, based on information available at time of generation.
- there is a broken link on the pre session website. use [this](https://nhs-forecasting.netlify.app/slides/1.1-prepare_data_tsibble.pdf) instead.
- `tsibble` is a tidy form of time series data, that allows it to be used in `todyverse` packages just as if it were a `data.frame` or a `tibble`.
# session 2
