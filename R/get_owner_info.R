

# Fuzzy find a owner.
find_owner <- function(df, owner) {
  
  # Create a list of owners
  owner_list <- df |> 
    mutate(owner = str_to_lower(owner)) |> 
    pull(owner)

  # Calculate distance of entered name and those in list of owneres
  entered_name <- str_to_lower(owner)
  distances <- stringdist::stringdist(entered_name, owner_list, method = 'lv')
  closest_match <- owner_list[which.min(distances)]

  if (entered_name != str_to_lower(closest_match)) {
    # Get user input if the entered name does not match available owners
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



# Filter race data based on selected owner
filter_owner_data <- function(race_data, the_owner) {
  race_results <- 
    race_data |>
    filter(owner == str_to_title(the_owner)) |>
    mutate(win = if_else(finish == 1, 1, 0))
  return(race_results)  
}




get_owner_info <- function(owner, series = 'all', type = 'summary') {

  race_series <- selected_series_data(series = series)
  the_owner <- find_owner(df = race_series, owner = owner)
  race_results <- filter_owner_data(race_data = race_series, the_owner = the_owner)

  message(str_to_title(the_owner))

  if (type == 'season') {
    owner_table <- 
      race_results |>
      group_by(series, season) |>
      summarize(
        season_races = n_distinct(race_name),
        number_of_drivers = n_distinct(driver),
        wins = sum(win, na.rm = TRUE),
        best_finish = min(finish),
        average_finish = round(mean(finish, na.rm = TRUE), 1),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(owner_table)
  } else if (type == 'summary') {
    owner_table <- 
      race_results |>
      group_by(series) |>
      summarize(
        number_of_seasons = n_distinct(season),
        career_races = n(),
        number_of_drivers = n_distinct(driver),
        wins = sum(win, na.rm = TRUE),
        best_finish = min(finish),
        average_finish = round(mean(finish, na.rm = TRUE), 1),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(owner_table)
  } else if (type == 'all') {  
    # table of career across all series
    return(race_results)
  } else {
    stop(paste('Unknown `type =', type, '` entered. Please try again.'))
  }
}
