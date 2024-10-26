#' Find closest matching owner name
#'
#' @param df A tibble containing NASCAR race data
#' @param the_owner Character string of owner name to search for
#' @return Character string of the matched owner name
#' @keywords internal
#' @noRd
find_owner <- function(df, the_owner) {
  # Create a list of owners
  owner_list <- df |> 
    mutate(owner = str_to_lower(owner)) |> 
    pull(owner)
 
  # Calculate distance of entered name and those in list of owneres
  entered_name <- str_to_lower(the_owner)
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

#' Filter race data for a specific owner
#'
#' @param race_data A tibble containing NASCAR race data
#' @param the_owner Character string of owner name
#' @return A tibble filtered for the specified owner with win column added
#' @keywords internal
#' @noRd
filter_owner_data <- function(race_data, the_owner) {
  race_results <- 
    race_data |>
    filter(owner == str_to_title(the_owner)) |>
    mutate(win = if_else(finish == 1, 1, 0))
  return(race_results)  
}

#' Get NASCAR owner statistics
#'
#' Retrieves and summarizes NASCAR race statistics for a specified owner across
#' different racing series. The function provides flexibility in viewing career
#' summaries, season-by-season breakdowns, or complete race-by-race data.
#'
#' @param owner Character string specifying an owner name (case-insensitive, fuzzy matching
#'   available)
#' @param series Character string specifying the racing series to analyze. Must be
#'   one of 'all' (default), 'cup', 'xfinity', or 'truck'
#' @param type Character string specifying the type of summary to return. Must be
#'   one of:
#'   * 'summary' (default): Career statistics grouped by series
#'   * 'season': Season-by-season statistics for each series
#'   * 'all': Complete race-by-race data
#'
#' @return A tibble containing owner statistics based on the specified type:
#'   * For type = 'summary': Career statistics grouped by series
#'   * For type = 'season': Season-by-season breakdown
#'   * For type = 'all': Complete race-by-race data
#'
#' @export
#'
#' @examples
#' # Get career summary for Joe Gibbs Racing across all series
#' get_owner_info("Joe Gibbs")
#'
#' # Get Cup series statistics only
#' get_owner_info("Joe Gibbs", series = "cup")
#'
#' # Get season-by-season breakdown for Truck series
#' get_owner_info("Kyle Busch", series = "truck", type = "season")

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