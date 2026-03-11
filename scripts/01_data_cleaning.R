# import necessary libraries
library(tidyverse)
library(dplyr)

# load music data set
music <- read_csv("data/music.csv")

# drop completely unknown columns as specified in the data set documentation
music <- music %>%
  select(-artist.location, -artist.similar, -release.name, -song.artist_mbtags)

# replace placeholder values (0 -> NA)
# columns with 0 as unknown: song.year and song.hotttnesss
music <- music %>% 
  mutate(
    song.year = ifelse(song.year == 0, NA, song.year),
    song.hotttnesss = ifelse(song.hotttnesss < 0, NA, song.hotttnesss)
    )

# convert columns to categories
music <- music %>%
  mutate(
    artist.id = factor(artist.id),
    artist.name = factor(artist.name),
    song.id = factor(song.id)
  )

# check missing values
colSums(is.na(music))

# save cleaned data set
write_csv(music, "data/music_clean.csv")
