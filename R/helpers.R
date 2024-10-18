#' Utility functions for nascaR.data package
#'
#' @description
#' This file contains various internal helper functions used throughout
#' the package. These functions are not exported and are intended for 
#' internal use only.
#'
#' @name nascaR.data-utils
#' @keywords internal
#' @noRd
NULL



#' Filter race data by series
#'
#' Internal helper function to filter race data based on the specified series.
#'
#' @name selected_series_data
#' @keywords internal
#' @param series A string specifying the race series ('cup', 'xfinity', 'truck', 
#' or 'all').
#' @return A filtered data frame of `class()` "tbl_df" containing race results 
#' for the specified series.

selected_series_data <- function(series) {
  the_series <- str_to_lower(series)
  all_race_results <- bind_rows(cup_series, xfinity_series, truck_series)
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
NULL



#' Fuzzy find a driver
#'
#' This function attempts to find a driver's name using fuzzy matching.
#' If an exact match is not found, it prompts the user for confirmation.
#'
#' @name find_driver
#' @keywords internal
#' @param df A data frame containing driver information.
#' @param driver A string containing the driver's name to search for.
#' @return The closest matching driver name as a string.
#' @examples
#' \dontrun{
#' # Example: "Jimmy Johnson" or "Jimmi Jahnsen" would get "Jimmie Johnson"
#' find_driver(driver_data, "Jimmy Johnson")
#' # I was unable to find "Jimmy Johnson" but found Jimmie Johnson. 
#' # Is this who you meant? [y/n] 
#' }

find_driver <- function(df, driver) {
  
  # Create a list of drivers
  driver_list <- df |> 
    mutate(driver = str_to_lower(driver)) |> 
    pull(driver)

  # Calculate distance of user-supplied name and those in list of driveres
  entered_name <- str_to_lower(driver)
  distances <- stringdist(entered_name, driver_list, method = 'lv')
  # Find the closest match by distance
  closest_match <- driver_list[which.min(distances)]

  if (entered_name != str_to_lower(closest_match)) {
    # Get user input if the entered name does not match available drivers
    entered_name <- str_to_title(entered_name)
    found_name <- str_to_title(closest_match)
    answer <- str_to_lower(readline(
      glue(
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
NULL