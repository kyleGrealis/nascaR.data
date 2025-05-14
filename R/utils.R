#' Internal utility functions for nascaR.data package
#'
#' @name nascaR.data-utils
#' @keywords internal
#' @noRd
NULL

#' Filter race data by series
#'
#' @param the_series A string specifying the race series. Must be one of
#'   'cup', 'xfinity', 'truck', or 'all'.
#' @return A tibble containing race results for the specified series.
#' @keywords internal
selected_series_data <- function(the_series) {
  # Ensure data is loaded even when using :: notation
  cup_series <- NULL
  xfinity_series <- NULL
  truck_series <- NULL

  # Use data() to explicitly load the datasets
  data("cup_series", package = "nascaR.data", envir = environment())
  data("xfinity_series", package = "nascaR.data", envir = environment())
  data("truck_series", package = "nascaR.data", envir = environment())

  # Series type is needed for get_* functions to filter properly
  all_race_results <- bind_rows(
    cup_series <- cup_series |> mutate(Series = 'Cup'),
    xfinity_series <- xfinity_series |> mutate(Series = 'Xfinity'),
    truck_series <- truck_series |> mutate(Series = 'Truck')
  )

  selected <- str_to_title(the_series)

  if (selected == 'All') {
    return(all_race_results)
  } else if (selected %in% c('Cup', 'Xfinity', 'Truck')) {
    filtered <- all_race_results |>
      filter(Series == selected)
    return(filtered)
  } else {
    rlang::abort(
      message = paste(str_to_title(the_series), "series does not exist."),
      class = "nascaR_invalid_series",
      series = the_series,
      valid_series = c("cup", "xfinity", "truck", "all")
    )
  }
}
