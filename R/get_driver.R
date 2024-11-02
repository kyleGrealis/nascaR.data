#' Find closest matching driver name
#'
#' @param df A tibble containing NASCAR race data
#' @param the_driver Character string of driver name to search for
#' @return Character string of the matched driver name
#' @keywords internal
#' @noRd
find_driver <- function(df, the_driver) {
  # Create a list of drivers
  driver_list <- df |> 
    mutate(Driver = str_to_lower(Driver)) |> 
    pull(Driver)

  # Calculate distance of entered name and those in list of driveres
  entered_name <- str_to_lower(the_driver)
  distances <- stringdist(entered_name, driver_list, method = 'lv')
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

#' Filter race data for a specific driver
#'
#' @param race_data A tibble containing NASCAR race data
#' @param the_driver Character string of driver name
#' @return A tibble filtered for the specified driver
#' @keywords internal
#' @noRd
filter_driver_data <- function(race_data, the_driver) {
  race_results <- 
    race_data |>
    filter(Driver == str_to_title(the_driver))
  return(race_results)  
}

#' Get NASCAR driver statistics
#'
#' Retrieves and summarizes NASCAR race statistics for a specified driver across
#' different racing series. The function provides flexibility in viewing career
#' summaries, season-by-season breakdowns, or complete race-by-race data.
#'
#' @param driver Character string of driver name (case-insensitive, fuzzy matching
#'   available)
#' @param series Character string specifying the racing series to analyze. Must be
#'   one of 'all' (default), 'cup', 'xfinity', or 'truck'
#' @param type Character string specifying the type of summary to return. Must be
#'   one of:
#'   * 'summary' (default): Career statistics grouped by series
#'   * 'season': Season-by-season statistics for each series
#'   * 'all': Complete race-by-race data
#'
#' @return A tibble containing driver statistics based on the specified type:
#'   * For type = 'summary': Career statistics grouped by series
#'   * For type = 'season': Season-by-season breakdown
#'   * For type = 'all': Complete race-by-race data
#'
#' @export
#'
#' @examples
#' # Get career summary for Kyle Busch across all series
#' get_driver_info("Kyle Busch")
#'
#' # Get Cup series statistics only
#' get_driver_info("Kyle Busch", series = "cup")
#'
#' # Get season-by-season breakdown for Truck series
#' get_driver_info("Kyle Busch", series = "truck", type = "season")
get_driver_info <- function(driver, series = 'all', type = 'summary') {

  # Filter all race data for selected series
  race_series <- selected_series_data(the_series = series)
  # Find driver name
  the_driver <- find_driver(df = race_series, the_driver = driver)
  # Get all driver's data
  race_results <- filter_driver_data(race_data = race_series, the_driver = the_driver)

  message(str_to_title(the_driver))

  if (type == 'season') {
    driver_table <- 
      race_results |>
      group_by(Series, Season) |>
      summarize(
        Races = n_distinct(Name),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish, na.rm = TRUE),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE)
      )
      return(driver_table)
  } else if (type == 'summary') {
    driver_table <- 
      race_results |>
      group_by(Series) |>
      summarize(
        Seasons = n_distinct(Season),
        `Career Races` = n(),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish, na.rm = TRUE),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE),
        # total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(driver_table)
  } else if (type == 'all') {  
    # table of career across all series
    return(race_results)
  } else {
    stop(paste('Unknown `type =', type, '` entered. Please try again.'))
  }
}