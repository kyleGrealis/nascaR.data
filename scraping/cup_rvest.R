
library(tidyverse)
library(rvest)
library(glue)
library(janitor)

doParallel::registerDoParallel(cores = parallel::detectCores() - 1)

# TEST: time counter
start <- Sys.time()
# TESTING:
# season <- c(1949, 1951)

season <- 1949:2024

cup_series <- NULL

for (season in season) {

  base_url <- 'https://www.racing-reference.info/season-stats/{season}/W/'

  # Add a user agent potentially bypass webscraping blockers
  user_agent <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

  print(glue::glue('Season: {season}'))

  the_season_page <- read_html(
    httr::GET(
      glue::glue(base_url),
      httr::user_agent(user_agent)
    )
  )

  # Season information
  the_race_links <- the_season_page |> 
    html_elements('div.race-number') |>
    html_elements('a') |>
    html_attr('href')

  the_race_names <- the_season_page |> 
    html_elements('div.race-number') |>
    html_elements('a') |>
    html_attr('title')

  the_track_names <- the_season_page |>
    html_elements('div.track.W') |>
    html_elements('a') |>
    html_attr('title')

  the_surfaces <- the_season_page |>
    html_elements('div.sfc.no-mobile') |>
    html_text() |>
    tail(-1)      # remove the column header

  track_length <- the_season_page |>
    html_elements('div.len') |>
    html_text() |>
    tail(-1) |>   # remove the column header
    as.numeric()

  total_race_mileage <- the_season_page |>
    html_elements('div.miles') |>
    html_text() |>
    tail(-1) |>   # remove the column header
    as.numeric()


  # Race results


  # Create empty season table that will be built as the loop iterates through each race
  season_table <- NULL
  

  # Create a race loop:
  for (i in 1:length(the_race_links)) {
  # for (i in 1:10) {

    # Debugging feedback
    print(glue::glue('Race: {i}'))

    # Race page
    the_race <- read_html(
        httr::GET(
          the_race_links[i],
          httr::user_agent(user_agent)
        )
      )

    # Race details: time, average speed, cautions, etc.
    # the_race |>
    #   html_elements('table.rDetailsTbl') |>
    #   html_table()

    # Get all the p elements
    the_ps <- the_race |>
      html_elements('p')

    # ------------------------------------------------------------
    # p 12 has Race details: time, average speed, cautions, etc.:
    # NASCAR Cup Series race number 1 of 36
    # Monday, February 19, 2024 at Daytona International Speedway, Daytona Beach, FL
    # 200 laps on a 2.500 mile paved track (500.000 miles)

    # Time of race: 3:10:52
    # Average speed: 157.178 mph
    # Pole speed: 181.947 mph	Cautions: 5 for 20 laps
    # Margin of victory: under caution
    # Attendance: n/a
    # Lead changes: 41
    planned_laps <- tryCatch(
      {
        # First attempt with the_ps[12] -- most pages use this
        the_ps[12] |>
          html_text() |>
          str_extract('(\\d+)(?=\\s*laps)') |>
          as.numeric()
      },
      error = function(e) {
        # If an error occurs, try with the_ps[9] -- first needed for 1951 race 9
        the_ps[9] |>
          html_text() |>
          str_extract('(\\d+)(?=\\s*laps)') |>
          as.numeric()
      }
    )
    # ------------------------------------------------------------

    # There are 14 tables on the page
    # the_race_table <- the_race |>
    #   html_element('table.tb.race-results-tbl') |>
    #   html_table()

    # The driver-related race results:
    the_result_table <- the_race |>
      html_element('table.tb.race-results-tbl') |>
      html_table() |>
      # Add the season year and race number as the first columns
      mutate(season = season, race_number = i, .before = 1) |>
      # Add the race name, track name, track length & track surface
      mutate(
        track = the_track_names[i],
        race_name = the_race_names[i],
        track_length = track_length[i],
        track_surface = the_surfaces[i],
        .after = 'race_number'
      ) |>
      # Add the planned number of laps & total race miles after car make
      mutate(
        planned_laps = planned_laps, 
        total_miles = total_race_mileage[i],
        .after = 'Car'
      ) |>
      # Create new columns for the Sponsor and the car Owner
      mutate(
        # Remove all text in & including the parentheses
        # \\s+: Matches one or more whitespace characters before the parentheses
        # \\(: Matches the opening parenthesis
        # [^)]*: Matches any characters that are not a closing parenthesis, 
        #        zero or more times
        # \\): Matches the closing parenthesis
        # $: Ensures that this pattern occurs at the end of the string
        sponsor = str_trim(str_remove(`Sponsor / Owner`, "\\s+\\([^)]*\\)$")),

        # Extract all text within the parentheses but don't include parentheses
        # (?<=\\(): This is a positive lookbehind assertion. It ensures that what precedes 
        #           the match is an opening parenthesis, but doesn't include the 
        #           parenthesis in the match.
        # .*: This matches any character (except newline) zero or more times.
        # (?=\\)): This is a positive lookahead assertion. It ensures that what follows the 
        #          match is a closing parenthesis, but doesn't include the parenthesis in 
        #          the match.
        owner = str_trim(str_extract(`Sponsor / Owner`, '(?<=\\().*(?=\\))')),
        .after = "Driver"
      ) |>
      # Remove Sponsor / Owner variable
      select(-`Sponsor / Owner`) |>
      # Create tidy names
      janitor::clean_names() |>
      # Rename variables
      rename(
        finish = pos,
        start = st,
        car_number = number,
        manufacturer = car,
        # playoff_pts = p_pts
      ) |>
      # Move car_number after the Driver name
      relocate(car_number, .after = 'driver') |>
      # Set variable types
      mutate(
        season = as.integer(season),
        race_number = as.integer(race_number),
        start = as.integer(start),
        car_number = as.character(car_number),  # some are alphanumeric like "1-A" or "A-1"
        laps = as.integer(laps),
        planned_laps = as.integer(planned_laps),
        led = as.integer(led),
        track_surface = case_when(
          track_surface == 'D' ~ 'dirt',
          track_surface == 'P' ~ 'paved',
          track_surface == 'R' ~ 'road',
          track_surface == 'S' ~ 'street'
        )
      ) |>
      # Fix where the Owner is listed as a Sponsor. This affects the earlier years.
      mutate(
        owner = if_else(is.na(owner), sponsor, owner),
        sponsor = if_else(owner == sponsor, '–', sponsor)
      )
    
    season_table <- bind_rows(season_table, the_result_table)

  }

  cup_series <- bind_rows(cup_series, season_table)

}

doParallel::stopImplicitCluster()

# Print time calculation
print(round(Sys.time() - start, 2))
# Set audible complete alert
beepr::beep(5)

save(cup_series, file = 'data/rvest/cup_series.rda')
