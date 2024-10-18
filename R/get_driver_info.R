





# Filter race data based on selected driver
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
