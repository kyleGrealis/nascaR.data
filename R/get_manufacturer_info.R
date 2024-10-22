

# Fuzzy find a manufacturer.
find_manufacturer <- function(df, manufacturer) {
  if (manufacturer %in% c('Chevy', 'chevy')) {
    manufacturer <- 'chevrolet'
  }
  
  # Create a list of manufacturers
  manufacturer_list <- df |> 
    mutate(manufacturer = str_to_lower(manufacturer)) |> 
    pull(manufacturer)

  # Calculate distance of entered name and those in list of manufacturers
  entered_name <- str_to_lower(manufacturer)
  distances <- stringdist::stringdist(entered_name, manufacturer_list, method = 'lv')
  closest_match <- manufacturer_list[which.min(distances)]

  if (entered_name != str_to_lower(closest_match)) {
    # Get user input if the entered name does not match available manufacturers
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



# Filter race data based on selected manufacturer
filter_manufacturer_data <- function(race_data, the_manufacturer) {
  race_results <- 
    race_data |>
    filter(manufacturer == str_to_title(the_manufacturer)) |>
    mutate(win = if_else(finish == 1, 1, 0))
  return(race_results)  
}




get_manufacturer_info <- function(manufacturer, series = 'all', type = 'summary') {

  race_series <- selected_series_data(series = series)
  the_manufacturer <- find_manufacturer(df = race_series, manufacturer = manufacturer)
  race_results <- filter_manufacturer_data(race_data = race_series, the_manufacturer = the_manufacturer)

  message(str_to_title(the_manufacturer))

  if (type == 'season') {
    manufacturer_table <- 
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
      return(manufacturer_table)
  } else if (type == 'summary') {
    manufacturer_table <- 
      race_results |>
      group_by(series) |>
      summarize(
        number_of_seasons = n_distinct(season),
        manufacturer_races = n(),
        wins = sum(win, na.rm = TRUE),
        best_finish = min(finish),
        average_finish = round(mean(finish, na.rm = TRUE), 1),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(manufacturer_table)
  } else if (type == 'all') {  
    # table of manufacturer across all series
    return(race_results)
  } else {
    stop(paste('Unknown `type =', type, '` entered. Please try again.'))
  }
}
