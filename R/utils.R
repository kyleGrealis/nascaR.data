#' Internal utility functions for nascaR.data package
#'
#' @name nascaR.data-utils
#' @keywords internal
#' @noRd
NULL

#' Filter race data by series
#'
#' @param series A string specifying the race series. Must be one of 
#'   'cup', 'xfinity', 'truck', or 'all'.
#' @return A tibble containing race results for the specified series.
#' @keywords internal
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
    rlang::abort(
      message = paste(str_to_title(series), "series does not exist."),
      class = "nascaR_invalid_series",
      series = series,
      valid_series = c("cup", "xfinity", "truck", "all")
    )
  }
}
