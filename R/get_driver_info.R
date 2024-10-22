
selected_series_data <- function(series) {
  the_series <- str_to_lower(series)
  
  if (series == 'all') {
    all_race_results <- bind_rows(
      cup_series, 
      xfinity_series, 
      truck_series
    )
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


find_driver <- function(df, the_driver) {
  
  # Create a list of drivers
  driver_list <- df |> 
    mutate(driver = str_to_lower(driver)) |> 
    pull(driver)

  # Calculate distance of user-supplied name and those in list of driveres
  entered_name <- str_to_lower(the_driver)
  distances <- stringdist(entered_name, driver_list, method = 'lv')
  # Find the closest match by distance
  closest_match <- driver_list[which.min(distances)]

  # Get user input if the entered name does not match available drivers
  if (entered_name != str_to_lower(closest_match)) {
    entered_name <- str_to_title(entered_name)
    found_name <- str_to_title(closest_match)

    # Feedback prompt:
    answer <- str_to_lower(readline(
      glue(
        '\n\nI was unable to find "{entered_name}" but found {found_name}. \nIs this who you meant? [y/n] '
      )
    ))
    # User response:
    if (answer %in% c('y', 'yes', 'ye', 'yeah', 'yup')) {
      return(closest_match)
    } else {
      stop('\nPlease check the spelling & try your search function again.')
    }
  }
  return(closest_match)
}


filter_driver_data <- function(race_data, the_driver) {
  race_results <- 
    race_data |>
    filter(driver == str_to_title(the_driver)) |>
    mutate(win = if_else(finish == 1, 1, 0))
  return(race_results)  
}



get_driver_info <- function(driver, series = 'all', type = 'summary') {

  race_series <- selected_series_data(series = series)
  the_driver <- find_driver(df = race_series, driver = driver)
  race_results <- filter_driver_data(race_data = race_series, the_driver = the_driver)

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
