library(tidyverse)

# Filter all data into the user's selected race series: Cup, Xfinity, Truck, or all
selected_series_data <- function(series) {
  the_series <- str_to_lower(series)
  all_race_results <- rbind(cup_series, xfinity_series, truck_series)
  if (series == 'all') {
    return(all_race_results)
  } else if (the_series %in% c('cup', 'xfinity', 'truck')) {
    filtered <- all_race_results |> 
      mutate(series = str_to_lower(series)) |>
      filter(series == the_series)
    return(filtered)
  } else {
    stop(paste(str_to_title(series), 'series does not exist.'))
  }
}

# Fuzzy find a driver.
# Example: "Jimmy Johnson" or "Jimmi Jahnsen" would get "Jimmie Johnson"
find_driver <- function(df, driver) {
  
  # Create a list of drivers
  driver_list <- df |> 
    mutate(driver = str_to_lower(driver)) |> 
    pull(driver)

  # Calculate distance of entered name and those in list of driveres
  entered_name <- str_to_lower(driver)
  distances <- stringdist::stringdist(entered_name, driver_list, method = 'lv')
  closest_match <- driver_list[which.min(distances)]

  if (entered_name != str_to_lower(closest_match)) {
    # Get user input if the entered name does not match available drivers
    entered_name <- str_to_title(entered_name)
    found_name <- str_to_title(closest_match)
    answer <- str_to_lower(readline(
      glue::glue(
        '\n\nI was unable to find "{entered_name}" but found {found_name}. \nIs this who you meant? [y/n] '
      )
    ))
    if (answer %in% c('y', 'yes', 'ye', 'yeah', 'yup')) {
      return(closest_match)
    } else {
      stop('\nPlease check the spelling & try your search function again.')
    }
  }
  return(closest_match)
}



# Filter race data based on selected driver
filter_data <- function(race_data, the_driver) {
  race_results <- 
    race_data |>
    filter(driver == str_to_title(the_driver)) |>
    mutate(win = if_else(finish == 1, 1, 0))
  return(race_results)  
}




get_driver_info <- function(driver, series = 'all', type = 'summary') {

  race_series <- selected_series_data(series = series)
  the_driver <- find_driver(df = race_series, driver = driver)
  race_results <- filter_data(race_data = race_series, the_driver = the_driver)

  message(str_to_title(the_driver))

  if (type == 'season') {
    driver_table <- 
      race_results |>
      group_by(series, season) |>
      summarize(
        season_races = n_distinct(race_name),
        wins = sum(win, na.rm = TRUE),
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
        wins = sum(win, na.rm = TRUE),
        best_finish = min(finish),
        average_finish = round(mean(finish, na.rm = TRUE), 1),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(driver_table)
  } else if (type == 'all') {  
    # table of career across all series
    return(race_results)
  } else {
    stop(paste('Unknown `type =', type, '` entered. Please try again.'))
  }
}
