#' Find closest matching manufacturer name
#'
#' @param df A tibble containing NASCAR race data
#' @param manufacturer Character string of manufacturer name to search for
#' @return Character string of the matched manufacturer name
#' @keywords internal
#' @noRd
find_manufacturer <- function(df, manufacturer) {
  if (manufacturer %in% c('Chevy', 'chevy')) {
    manufacturer <- 'chevrolet'
  }
  
  # Create a list of manufacturers
  manufacturer_list <- df |> 
    mutate(Make = str_to_lower(Make)) |> 
    pull(Make)
 
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
 
#' Filter race data for a specific manufacturer
#'
#' @param race_data A tibble containing NASCAR race data
#' @param the_manufacturer Character string of manufacturer name
#' @return A tibble filtered for the specified manufacturer 
#' @keywords internal
#' @noRd
filter_manufacturer_data <- function(race_data, the_manufacturer) {
  race_results <- 
    race_data |>
    filter(Make == str_to_title(the_manufacturer))
  return(race_results)  
}
 
#' Get NASCAR manufacturer statistics
#'
#' Retrieves and summarizes NASCAR race statistics for a specified manufacturer across
#' different racing series. The function provides flexibility in viewing career
#' summaries, season-by-season breakdowns, or complete race-by-race data.
#'
#' @param manufacturer Character string specifying a manufacturer name (case-insensitive, fuzzy matching
#'   available)
#' @param series Character string specifying the racing series to analyze. Must be
#'   one of 'all' (default), 'cup', 'xfinity', or 'truck'
#' @param type Character string specifying the type of summary to return. Must be
#'   one of:
#'   * 'summary' (default): Career statistics grouped by series
#'   * 'season': Season-by-season statistics for each series
#'   * 'all': Complete race-by-race data
#'
#' @return A tibble containing manufacturer statistics based on the specified type:
#'   * For type = 'summary': Career statistics grouped by series
#'   * For type = 'season': Season-by-season breakdown
#'   * For type = 'all': Complete race-by-race data
#'
#' @export
#'
#' @examples
#' # Get career summary for Toyota across all series
#' get_manufacturer_info("Toyota")
#'
#' # Get Cup series statistics only
#' get_manufacturer_info("Ford", series = "cup")
#'
#' # Get season-by-season breakdown for Truck series
#' get_manufacturer_info("Chevrolet", series = "truck", type = "season")

get_manufacturer_info <- function(manufacturer, series = 'all', type = 'summary') {
  race_series <- selected_series_data(the_series = series)
  the_manufacturer <- find_manufacturer(df = race_series, manufacturer = manufacturer)
  race_results <- filter_manufacturer_data(race_data = race_series, the_manufacturer = the_manufacturer)
 
  message(str_to_title(the_manufacturer))
 
  if (type == 'season') {
    manufacturer_table <- 
      race_results |>
      group_by(Series, Season) |>
      summarize(
        Races = n_distinct(race_name),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE)
      )
      return(manufacturer_table)
  } else if (type == 'summary') {
    manufacturer_table <- 
      race_results |>
      group_by(Series) |>
      summarize(
        Seasons = n_distinct(Season),
        Races = n(),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish, na.rm = TRUE),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE)
      )
      return(manufacturer_table)
  } else if (type == 'all') {  
    # table of manufacturer across all series
    return(race_results)
  } else {
    stop(paste('Unknown `type =', type, '` entered. Please try again.'))
  }
}