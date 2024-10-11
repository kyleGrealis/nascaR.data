library(tidyverse)

# First write a function to fuzzy find a driver.
# Example: "Jimmy Johnson" or "Jimmi Jahnsen" would get "Jimmie Johnson"
find_similar_driver <- function(name) {
  name <- str_to_lower(name)
  driver_list <- cup_series |> 
    mutate(driver = str_to_lower(driver)) |> 
    pull(driver)
  distances <- stringdist::stringdist(name, driver_list, method = 'lv')
  closest_match <- driver_list[which.min(distances)]
  return(str_to_title(closest_match))
}

return_selected_series <- function(series = 'all') {
  if (series == 'all') {
    # Return combined datasets that can be filtered in driver info
    return(rbind(cup_series, xfinity_series, truck_series))
  } else {
    series_name <- paste0(series, '_series')
    if (exists(series_name)) {
      return(get(series_name))
    }
    else{
      stop(paste(series, 'series does not exist.'))
    }
  }
}

# Aggregate driver information
# type: career, season, summary
filter_driver_info <- function(the_driver, race_series, type) {

  # Return race series information:
  # 'all': search across all series
  # 'cup', 'xfinity', 'truck': search respective series only
  race_data <- return_selected_series(race_series)

  # Filter race data based on selected driver
  race_results <- 
    race_data |>
    filter(driver == the_driver)

  # Return 
  if (type == 'season') {
    driver_table <- 
      race_results |>
      group_by(series, season) |>
      summarize(
        season_races = n_distinct(race_name),
        best_finish = min(finish),
        average_finish = round(mean(finish, na.rm = TRUE), 1),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(driver_table)
  } else if (type == 'summary') {
    driver_table <- 
      race_results |>
      group_by(series) |>
      summarize(
        number_of_seasons = n_distinct(season),
        career_races = n(),
        best_finish = min(finish),
        average_finish = round(mean(finish, na.rm = TRUE), 1),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(driver_table)
  } else {  
    # type == 'all'
    # table of career across all series
    return(race_results)
  }
}

get_driver_info <- function(name, race_series = 'all', type = 'summary') {
  name <- str_to_title(name)
  if (find_similar_driver(name) != name) {
    # Get user input if the entered name does not match available drivers
    answer <- readline(
      glue::glue(
        '\n\nI was unable to find "{name}" but found {find_similar_driver(name)}. \nIs this who you meant? [y/n] '
      )
    )
    if (str_to_lower(answer) %in% c('y', 'yes', 'ye', 'yeah', 'yup')) {
      name <- find_similar_driver(name)
      message(name)
      filter_driver_info(name, race_series = race_series, type = type)
    } else {
      message('\nPlease check the spelling & try your search function again.')
    }
  } else {
    # this will return the list of the driver information
    message(name)
    filter_driver_info(name, race_series = race_series, type = type)
  }
}
