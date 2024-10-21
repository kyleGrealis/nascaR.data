
library(tidyverse)
library(rvest)

doParallel::registerDoParallel(cores = parallel::detectCores() - 1)

# TEST: time counter
start <- Sys.time()
# TESTING:
seasons <- c(1949)

# xfinity race: https://www.driveraverages.com/nascar_xfinityseries/race.php?sked_id=2024501
# truck race: https://www.driveraverages.com/nascar_truckseries/race.php?sked_id=2024701


base_url <- 'https://www.driveraverages.com/nascar/'
season_url <- 'year.php?yr_id='
seasons <- 1949:2024

# 1. set empty dataframe
results <- NULL
# 2. iterate through season & save race links
for (season in seasons) {

  # console output for debugging
  message(paste('\nSeason:', season))

  # 1. set empty list
  links <- NULL

  # 2. get page information
  new_links <- read_html(paste0(base_url, season_url, season)) |> 
    html_elements('div#Div2Nav') |> 
    html_elements('ul') |> 
    html_elements('a') |> 
    html_attr('href') |> 
    keep(~str_detect(., 'race.php?'))

  links <- c(links, new_links)

  # get race results:
  # 3. iterate over links and build results
  for (i in 1:length(links)) {

    page <- read_html(paste0(base_url, links[i]))

    # get race name & location
    details <- page |> 
      html_element('td.td-left span.td-bold') |> 
      html_text2()

    # separate the details
    parts <- str_split(details, '\n')[[1]]
    race_name  <- parts[1]
    track_name <- parts[2]

    # console output
    message(paste0('\tRace ', i, ': ', race_name))

    # select race table
    race <- page |> 
      html_table(header = TRUE) |> 
      pluck(3)

    # modify race table
    result <- race |> 
      rename(Car = `#`) |> 
      mutate(Car = str_remove(Car, '#')) |> 
      # mutate(across(everything(), ~replace_na(., 0))) |> ## consider after processing
      mutate(
        Season = season,
        Race = i, 
        Track = track_name,
        Name = race_name,
        .before = 'Finish'
      ) |> 
      mutate(`Seg Points` = S1 + S2, .after = 'Team') |> 
      mutate(Win = if_else(Finish == 1, 1, 0)) |> 
      select(-S1, -S2, -S3)

    results <- bind_rows(results, result)

  }

  
}

beepr::beep(5)

doParallel::stopImplicitCluster()

message(paste('\nScraping time:', round(Sys.time() - start, 2)))


###### merge old cup data with new table
# 1. reduce the original data to season, race number, length, & surface
load('data/cup_series.rda')
reduced_cup <- cup_series |>
  select(season, race_number, track_surface, track_length) |>
  distinct(season, race_number, .keep_all = TRUE)
# 2. join selected variables to newly scraped data
cup <- results |>
  left_join(reduced_cup, by = c('Season' = 'season', 'Race' = 'race_number')) |>
  relocate(c(track_length, track_surface), .after = 'Name') |>
  rename(Length = track_length, Surface = track_surface)
# 3. create data of track, length, & surface for future merging
# to consider: track length & surface may have changed throughout the years, so
# it will be necessary to store the data with the year as well




message(paste('\nTotal process time:', round(Sys.time() - start, 2)))













# save(cup_series, file = 'data/rvest/cup_series.rda')
