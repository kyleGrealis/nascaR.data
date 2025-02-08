library(dplyr)
library(stringr)
library(glue)

full_series <- NULL
series <- 'cup'
# series <- 'xfinity'
# series <- 'truck'

for (season in 1949:2024) {
# for (season in 1982:2024) {
# for (season in 1995:2024) {
  # set the names and pathways
  the_season <- glue('cup_season_{season}')
  incoming_path <- glue('data/cup/{the_season}.rda')
  outgoing_path <- glue('data/by-year/cup/{the_season}.rda')

  # load dataset and assign it a new name. the data enters as "results"
  load(incoming_path)
  by_year <- results |> 
    filter(Season == season)
  # object "results" now will be given a name like "cup_season_2024"
  # and saved properly in the environment
  assign(the_season, get('by_year'))
  rm(results)

  # save the dataset with the original name, but now with only the values for that year
  message(glue('Fixing season: {season}'))
  save(the_season, file = outgoing_path)

  # combine all by-year results for the main package dataset
  full_series <- bind_rows(full_series, by_year)
  rm(by_year)
  
}

full_series_name <- 'cup_series'
assign(full_series_name, get('full_series'))
# save dataset to data/joined/cup/cup_series.rda
save(cup_series, file = glue('data/joined/cup_series.rda'))
