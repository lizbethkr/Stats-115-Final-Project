################################################
# 1. Load packages
################################################

library(tidyverse)
library(rstanarm)
library(bayesplot)
library(tidybayes)
library(modelr)

options(mc.cores = parallel::detectCores())


################################################
# 2. Load dataset
################################################

music <- read.csv("/Users/shruthileon/Downloads/music.csv")


################################################
# 3. Data cleaning and feature engineering
################################################

music_clean <- music %>%
  filter(song.year > 0,
         song.hotttnesss > -1) %>%     # remove missing values
  mutate(
    year_centered = song.year - mean(song.year),
    loudness_centered = song.loudness - mean(song.loudness)
  )


################################################
# 4. Fit Bayesian regression model
################################################

model_loudness_year <- stan_glm(
  song.hotttnesss ~ loudness_centered * year_centered,
  data = music_clean,
  family = gaussian(),
  chains = 4,
  iter = 4000,
  seed = 123
)


################################################
# 5. Posterior summary
################################################

print(model_loudness_year, digits = 4)


################################################
# 6. Posterior interval plot
################################################

mcmc_intervals(
  as.matrix(model_loudness_year),
  pars = c(
    "loudness_centered",
    "year_centered",
    "loudness_centered:year_centered"
  )
) +
  ggtitle("Posterior Credible Intervals for Model Coefficients")


################################################
# 7. Posterior predictive check
################################################

pp_check(model_loudness_year)


################################################
# 8. Create prediction grid for interaction plot
################################################

pred_grid <- music_clean %>%
  data_grid(
    loudness_centered = seq_range(loudness_centered, 50),
    year_centered = c(-20, 0, 20)
  ) %>%
  add_epred_draws(model_loudness_year)


################################################
# 9. Plot predicted interaction
################################################

pred_grid %>%
  ggplot(aes(x = loudness_centered,
             y = .epred,
             color = factor(year_centered))) +
  stat_lineribbon(alpha = 0.25) +
  labs(
    x = "Song Loudness (centered)",
    y = "Predicted Song Popularity",
    color = "Year Level",
    title = "Predicted Relationship Between Loudness and Popularity Across Time"
  ) +
  theme_minimal()


################################################
# 10. Visualize interaction (posterior predictions)
################################################
  
pred_grid <- music_clean %>%
  data_grid(
    loudness_centered = seq_range(loudness_centered, 50),
    year_centered = c(-20, 0, 20)  # early / average / recent years
  ) %>%
  add_epred_draws(model_loudness_year)

pred_grid %>%
  ggplot(aes(x = loudness_centered,
             y = .epred,
             color = factor(year_centered))) +
  stat_lineribbon(alpha = 0.25) +
  labs(
    x = "Song Loudness (centered)",
    y = "Predicted Song Popularity",
    color = "Year (relative to mean)",
    title = "Predicted Relationship Between Loudness and Popularity Across Time"
  ) +
  theme_minimal()

