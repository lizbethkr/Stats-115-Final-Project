# Exploratory data analysis

#load libraries
library(tidyverse)

# a look at the data set
music <- read_csv("data/music_clean.csv")

# missing data
music %>%
  summarise(across(everything(), ~ mean(is.na(.)))) %>%
  pivot_longer(everything(),
               names_to = "variable",
               values_to = "percent_missing") %>%
  arrange(desc(percent_missing))

# Song popularity (song.hotttnesss) distribution
ggplot(music, aes(song.hotttnesss)) +
  geom_histogram(bins = 40) +
  labs(
    title = "Distribution of Song Popularity",
    x = "Song Hotttnesss",
    y = "Count"
  )

# Potential Predictors

## DISTRIBUTIONS
ggplot(music, aes(song.tempo)) +
  geom_histogram(bins = 40) +
  labs(title = "Distribution of Song Tempo", x = "Tempo (BPM)")

ggplot(music, aes(song.duration)) +
  geom_histogram(bins = 40) +
  labs(title = "Distribution of Song Duration", x = "Duration (seconds)")

ggplot(music, aes(song.loudness)) +
  geom_histogram(bins = 40) +
  labs(title = "Distribution of Song Loudness")

ggplot(music, aes(artist.familiarity)) +
  geom_histogram(bins = 40) +
  labs(title = "Distribution of Artist Familiarity")

ggplot(music, aes(artist.hotttnesss)) +
  geom_histogram(bins = 40) +
  labs(title = "Distribution of Artist Popularity")

## HISTOGRAMS

ggplot(music, aes(song.tempo, song.hotttnesss)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm") +
  labs(title = "Tempo vs Song Popularity")

ggplot(music, aes(song.duration, song.hotttnesss)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm") +
  labs(title = "Duration vs Song Popularity")

ggplot(music, aes(song.loudness, song.hotttnesss)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm") +
  labs(title = "Loudness vs Song Popularity")

ggplot(music, aes(artist.familiarity, song.hotttnesss)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm") +
  labs(title = "Artist Familiarity vs Song Popularity")

ggplot(music, aes(artist.hotttnesss, song.hotttnesss)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm") +
  labs(title = "Artist Popularity vs Song Popularity")