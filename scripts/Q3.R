# Load required package
library(tidyverse)

# 1. Calculate average parameters for each artist
artist_stats <- music_clean %>%
  # Remove rows with missing data in our columns of interest
  drop_na(artist.name, song.hotttnesss, song.tempo, song.loudness, song.duration) %>%
  group_by(artist.name) %>%
  summarize(
    n_songs = n(),
    mean_pop = mean(song.hotttnesss),
    mean_tempo = mean(song.tempo),
    mean_loudness = mean(song.loudness),
    mean_duration = mean(song.duration)
  ) %>%
  # Only look at artists with at least 5 songs so we can plot a meaningful distribution
  filter(n_songs >= 5) 

# 2. Scale the features (Z-scores) so duration (large numbers) doesn't overpower loudness (small numbers)
scaled_features <- artist_stats %>%
  mutate(
    z_tempo = as.numeric(scale(mean_tempo)),
    z_loudness = as.numeric(scale(mean_loudness)),
    z_duration = as.numeric(scale(mean_duration))
  )

# 3. Find artists similar to a target artist
target_artist_name <- "Thrice" # You can change this to any artist in your dataset

# Extract the scaled parameters for our target artist
target_params <- scaled_features %>% 
  filter(artist.name == target_artist_name) %>% 
  select(z_tempo, z_loudness, z_duration)

# Calculate Euclidean distance between the target and all other artists
similar_artists_data <- scaled_features %>%
  mutate(
    distance = sqrt(
      (z_tempo - target_params$z_tempo)^2 + 
        (z_loudness - target_params$z_loudness)^2 + 
        (z_duration - target_params$z_duration)^2
    )
  ) %>%
  # Sort by closest distance (smallest number)
  arrange(distance) %>%
  # Grab the top 4 (which will include the target artist themselves at distance 0)
  slice(1:4)

# Get just the names of the closely matched artists
chosen_artists <- similar_artists_data$artist.name

# Optional: Print the stats to verify they are similar
print("Musical Parameters of Selected Artists:")
print(similar_artists_data %>% select(artist.name, mean_tempo, mean_loudness, mean_duration, mean_pop))

# 4. Plot their song popularity distributions
music_clean %>%
  filter(artist.name %in% chosen_artists) %>%
  drop_na(song.hotttnesss) %>%
  ggplot(aes(x = reorder(artist.name, song.hotttnesss, FUN = median), y = song.hotttnesss)) +
  geom_boxplot(fill = "lightcyan", outlier.shape = NA) +
  geom_jitter(color = "darkblue", alpha = 0.5, width = 0.15, height = 0) +
  labs(
    title = "Song Popularity for Artists with Highly Similar Sound Profiles",
    subtitle = "Comparing artists matched by average tempo, loudness, and duration",
    x = "Artist",
    y = "Song Popularity (hotttnesss)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(size = 11)
  )

# 1. Prepare the data (remove NAs)
music_model_data <- music_clean %>%
  filter(!is.na(song.hotttnesss) & !is.na(artist.name))

# 2. FIT THE MODEL (This creates the 'artist_model' object)
# Note: Because this is a Bayesian model with MCMC sampling, 
# it will take a little bit of time to run. Let it finish!
artist_model <- stan_glmer(
  song.hotttnesss ~ 1 + (1 | artist.name),
  data = music_model_data,
  family = gaussian(),
  prior_intercept = normal(0.5, 2.5, autoscale = TRUE),
  chains = 4, 
  iter = 2000, 
  seed = 115
)

# You can verify the model was created successfully by running:
summary(artist_model)

# Extract the variance components from the model posterior
variance_draws_long <- as.data.frame(artist_model) %>%
  select(
    `Within-Artist (sigma_y)` = sigma,
    `Between-Artist (sigma_mu)` = `Sigma[artist.name:(Intercept),(Intercept)]`
  ) %>%
  pivot_longer(
    cols = everything(), 
    names_to = "Variance_Type", 
    values_to = "Standard_Deviation"
  )

# Plot the overlapping densities
ggplot(variance_draws_long, aes(x = Standard_Deviation, fill = Variance_Type)) +
  geom_density(alpha = 0.6) +
  scale_fill_manual(values = c("darkorange", "darkblue")) +
  labs(
    title = "Where does the variation in song popularity come from?",
    subtitle = "Comparing Between-Artist vs. Within-Artist Standard Deviations",
    x = "Standard Deviation (Posterior Draws)",
    y = "Density",
    fill = "Source of Variation"
  ) +
  theme_minimal() +
  theme(legend.position = "top")
