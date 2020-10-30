# found here: https://www.business-science.io/code-tools/2020/10/22/visualize-timeseries.html
# Load libraries
library(fpp2)         # An older forecasting framework
library(fpp3)         # A newer tidy forecasting framework
library(timetk)       # An even newer tidy forecasting framework
library(tidyverse)    # Collection of data manipulation tools
library(tidyquant)    # Business Science ggplot theme
library(cowplot)      # A ggplot add-on for arranging plots
# Quarterly Australian production data as tibble
aus <- tsibbledata::aus_production %>% as_tibble()
# Check structure
aus %>% str()

# Convert tibble to time series object
aus_prod_ts <- ts(aus[, 2:7],  # Choose columns
                  start = c(1956, 1),  # Choose start date
                  end = c(2010, 2),    # Choose end date
                  frequency = 4)       # Choose frequency per yr
# Check it out
aus_prod_ts %>% tail()

# Convert ts to tsibble and keep wide format
aus_prod_tbl_wide <- aus_prod_ts %>%    # TS object
  as_tsibble(index = "index",           # Set index column
             pivot_longer = FALSE)      # Wide format

# Convert ts to tsibble and pivot to long format
aus_prod_tbl_long <- aus_prod_ts %>%    # TS object
  as_tsibble(index = "index",           # Set index column
             pivot_longer = TRUE)       # Long format

# Convert tsibble to tibble, keep wide format
aus <- tsibbledata::aus_production %>% 
  tk_tbl() %>%
  mutate(Quarter = as_date(as.POSIXct.Date(Quarter)))


# Quarterly Australian production data to long format
aus_long <- aus %>% 
  rename(date = Quarter) %>%
  pivot_longer(
    cols = c("Beer","Tobacco","Bricks",
             "Cement","Electricity","Gas"))

# Using fpp2
aus_prod_ts %>%               # TS object
  autoplot(facets=FALSE)      # No facetting

# Using fpp2
aus_prod_ts %>%               # TS object
  autoplot(facets=FALSE)      # No facetting


# Using fpp3
aus_prod_tbl_long %>%    # Data in long format
  autoplot(value) 


# Using ggplot
aus_long %>%
  ggplot(aes(date, value, group = name, color = name)) +
  geom_line()


# Using fpp2
aus_prod_ts %>%  
  autoplot(facets=TRUE)   # With facetting


# Using fpp3
aus_prod_tbl_long %>%
  ggplot(aes(x = index, y = value, group = key)) + 
  geom_line() + 
  facet_grid(vars(key), scales = "free_y")   # With facetting


# Using timetk
aus_long %>% 
  plot_time_series(
    .date_var = date,
    .value = value,
    .facet_vars = c(name), # Group by these columns
    .color_var = name, 
    .interactive = FALSE,
    .legend_show = FALSE
  )


# Monthly plot of anti-diabetic scripts in Australia 
a1 <- a10 %>%
  autoplot() 
# Seasonal plot
a2 <- a10 %>% 
  ggseasonplot(year.labels.left = TRUE,   # Add labels
               year.labels = TRUE) 
# Arrangement of plots
plot_grid(a1, a2, ncol=1, rel_heights = c(1, 1.5))


# Monthly plot of anti-diabetic scripts in Australia
a1 <- a10 %>%
  as_tsibble() %>%
  autoplot(value)
# Seasonal plot
a2 <- a10 %>%
  as_tsibble() %>%
  gg_season(value, labels="both")   # Add labels
# Arrangement of plots
plot_grid(a1, a2, ncol=1, rel_heights = c(1, 1.5))


# Convert ts to tibble
a10_tbl <- fpp2::a10 %>%
  tk_tbl()
# Monthly plot of anti-diabetic scripts in Australia 
a1 <- a10_tbl %>% 
  plot_time_series(
    .date_var = index,
    .value    = value,
    .smooth   = TRUE,
    .interactive = FALSE,
    .title = "Monthly anti-diabetic scripts in Australia"
  )
# New time-based features to group by
a10_tbl_add <- a10_tbl %>% 
  mutate( 
    month = factor(month(index, label = TRUE)),  # Plot this
    year = factor(year(index))  # Grouped on y-axis
  )
# Seasonal plot
a2 <- a10_tbl_add %>%
  ggplot(aes(x = month, y = value, 
             group = year, color = year)) + 
  geom_line() + 
  geom_text(
    data = a10_tbl_add %>% filter(month == min(month)),
    aes(label = year, x = month, y = value),
    nudge_x = -0.3) + 
  geom_text(
    data = a10_tbl_add %>% filter(month == max(month)),
    aes(label = year, x = month, y = value),
    nudge_x = 0.3) + 
  guides(color = FALSE)
# Arrangement of plots
plot_grid(a1, a2, ncol=1, rel_heights = c(1, 1.5))


# Monthly beer production in Australia 1992 and after
beer_fpp2 <- fpp2::ausbeer %>%
  window(start = 1992)    
# Time series plot
b1 <- beer_fpp2 %>% 
  autoplot() 
# Subseries plot
b2 <- beer_fpp2 %>% 
  ggsubseriesplot() 
# Plot it
plot_grid(b1, b2, ncol=1, rel_heights = c(1, 1.5))


# Monthly beer production in Australia 1992 and after
beer_fpp3 <- fpp2::ausbeer %>%
  as_tsibble() %>%
  filter(lubridate::year(index) >= 1992)
# Time series plot
b3 <- beer_fpp3 %>% 
  autoplot(value) 
# Subseries plot
b4 <- beer_fpp3 %>%
  gg_subseries(value) 
# Plot it
plot_grid(b3, b4, ncol=1, rel_heights = c(1, 1.5))




# Monthly beer production in Australia 1992 and after
ausbeer_tbl <- fpp2::ausbeer %>%
  tk_tbl() %>%
  filter(year(index) >= 1992) %>%
  mutate(index = as_date(index))
# Time series plot
b1 <- ausbeer_tbl %>%
  plot_time_series(
    .date_var = index,
    .value    = value,
    .interactive = FALSE
  )
# Subseries plot
b2 <- ausbeer_tbl %>%
  mutate(
    quarter = str_c("Quarter ", as.character(quarter(index)))
  ) %>%
  plot_time_series(
    .date_var = index,
    .value = value,
    .facet_vars = quarter,
    .facet_ncol = 4, 
    .color_var = quarter, 
    .facet_scales = "fixed",
    .interactive = FALSE,
    .legend_show = FALSE
  )
# Plot it
plot_grid(b1, b2, ncol=1, rel_heights = c(1, 1.5))



# Plot of non-seasonal oil production in Saudi Arabia
o1 <- fpp2::oil %>%
  autoplot()
# Lag plot of non-seasonal oil production
o2 <- gglagplot(oil, do.lines = FALSE)
# Plot both
plot_grid(o1, o2, ncol=1, rel_heights = c(1,2))


# Plot of non-seasonal oil production
o1 <- oil %>%
  as_tsibble() %>%
  autoplot(value)
# Lag plot of non-seasonal oil production
o2 <- oil %>%
  as_tsibble() %>%
  gg_lag(y=value, geom = "point") 
# Plot it
plot_grid(o1, o2, ncol=1, rel_heights = c(1,2))




# Convert to tibble and create lag columns
oil_lag_long <- oil %>%
  tk_tbl(rename_index = "year") %>%
  tk_augment_lags(      # Add 9 lag columns of data
    .value = value, 
    .names = "auto", 
    .lags = 1:9) %>%
  pivot_longer(         # Pivot from wide to long
    names_to = "lag_id", 
    values_to = "lag_value", 
    cols = value_lag1:value_lag9)  # Exclude year & value


# Time series plot
o1 <- oil %>%
  tk_tbl(rename_index = "year") %>%  
  mutate(year = ymd(year, truncated = 2L)) %>%  
  plot_time_series(
    .date_var = year, 
    .value = value,
    .interactive = FALSE)
# timetk Method: Plot Multiple Lags
o2 <- oil_lag_long %>%
  plot_time_series(
    .date_var = value,     # Use value instead of date
    .value = lag_value,    # Use lag value to plot against
    .facet_vars = lag_id,  # Facet by lag number
    .facet_ncol = 3,
    .interactive = FALSE, 
    .smooth = FALSE,
    .line_alpha = 0,      
    .legend_show = FALSE,
    .facet_scales = "fixed"
  ) + 
  geom_point(aes(colour = lag_id)) + 
  geom_abline(colour = "gray", linetype = "dashed") 
# Plot it
plot_grid(o1, o2, ncol=1, rel_heights = c(1,2))


# ACF plot 
o1 <- ggAcf(oil, lag.max = 20)
# PACF plot
o2 <- ggPacf(oil, lag.max = 20)
# Plot both
plot_grid(o1, o2, ncol = 1)


# Convert to tsibble
oil_tsbl <- oil %>% as_tsibble()
# ACF Plot
o1 <- oil_tsbl %>%
  ACF(lag_max = 20) %>%
  autoplot()
# PACF Plot
o2 <- oil_tsbl %>%
  PACF(lag_max = 20) %>%
  autoplot() 
# Plot both
plot_grid(o1, o2, ncol = 1)



# Using timetk
oil %>%
  tk_tbl(rename_index = "year") %>%
  plot_acf_diagnostics(
    .date_var = year,
    .value    = value,
    .lags     = 20,
    .show_white_noise_bars = TRUE, 
    .interactive = FALSE
  )

# 8. Summary
# As with all things in life, there are good and bad sides to using any of these three forecasting frameworks for visualizing time series. All three have similar functionality as it relates to visualizations.
# 
# 8.1 fpp2
# Code requires minimal parameters
# Uses basets format
# Uses ggplot for visualizations
# Mostly incompatible with tidyverse for data manipulation
# No longer maintained except for bug fixes
# 8.2 fpp3
# Code requires minimal parameters
# Uses proprietary tsibble format with special indexing tools
# Uses ggplot for visualizations
# Mostly compatible with tidyverse for data manipulation; tsibble may cause issues
# Currently maintained
# 8.3 timetk
# Code requires multiple parameters but provides more granularity
# Uses standard tibble format
# Uses ggplot and plotly for visualizations
# Fully compatible with tidyverse for data manipulation
# Currently maintained
# 

