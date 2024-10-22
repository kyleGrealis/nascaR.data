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
NULL



#' Fuzzy find a driver
#'
#' This function attempts to find a driver's name using fuzzy matching.
#' If an exact match is not found, it prompts the user for confirmation.
#'
#' @name find_driver
#' @keywords internal
#' @param df A data frame containing driver information.
#' @param the_driver A string containing the driver's name to search for.
#' @return The closest matching driver name as a string.
#' @examples
#' \dontrun{
#' # Example: "Jimmy Johnson" or "Jimmi Jahnsen" would find "Jimmie Johnson"
#' find_driver(driver_data, "Jimmy Johnson")
#' # I was unable to find "Jimmy Johnson" but found Jimmie Johnson. 
#' # Is this who you meant? [y/n] 
#' }

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
NULL



#' Filter race data based on selected driver
#' 
#' Internal helper function to filter race data based on the selected driver.
#' 
#' @name filter_driver_data
#' @keywords internal
#' @param race_data The data frame returned from `selected_series_data()`.
#' @param the_driver The name of the driver returned from `find_driver()`.
#' @return A filtered data frame of `class()` "tbl_df" containing race results 
#' of the selected driver. A win column is added for summary statistics.
#' @examples
#' \dontrun{
#' filter_driver_data(cup_series, 'Jimmie Johnson')
#' }

filter_driver_data <- function(race_data, the_driver) {
  race_results <- 
    race_data |>
    filter(driver == str_to_title(the_driver)) |>
    mutate(win = if_else(finish == 1, 1, 0))
  return(race_results)  
}