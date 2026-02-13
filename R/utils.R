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
  all_race_results <- bind_rows(
    load_series("cup") |> mutate(Series = "Cup"), # nolint
    load_series("xfinity") |> mutate(Series = "Xfinity"), # nolint
    load_series("truck") |> mutate(Series = "Truck") # nolint
  )

  selected <- str_to_title(the_series)

  if (selected == "All") {
    all_race_results
  } else if (selected %in% c("Cup", "Xfinity", "Truck")) {
    all_race_results |>
      filter(Series == selected)
  } else {
    rlang::abort(
      message = paste(str_to_title(the_series), "series does not exist."),
      class = "nascaR_invalid_series",
      series = the_series,
      valid_series = c("cup", "xfinity", "truck", "all")
    )
  }
}
