#' Internal utility functions for nascaR.data package
#'
#' @name nascaR.data-utils
#' @keywords internal
#' @noRd
NULL

#' Filter race data by series
#'
#' @param the_series A string specifying the race series. Must be one of
#'   'cup', 'nxs', 'truck', or 'all'.
#' @return A tibble containing race results for the specified series.
#' @keywords internal
#' @noRd
selected_series_data <- function(the_series) {
  series_key <- switch(str_to_lower(the_series),
    cup = "cup",
    nxs = "nxs",
    truck = "truck",
    all = "all",
    NULL
  )

  if (is.null(series_key)) {
    rlang::abort(
      message = paste(the_series, "series does not exist."),
      class = "nascaR_invalid_series",
      series = the_series,
      valid_series = c("cup", "nxs", "truck", "all")
    )
  }

  series_label_map <- c(cup = "Cup", nxs = "NXS", truck = "Truck")

  if (series_key == "all") {
    bind_rows(
      load_series("cup") |> mutate(Series = "Cup"),
      load_series("nxs") |> mutate(Series = "NXS"),
      load_series("truck") |> mutate(Series = "Truck")
    )
  } else {
    load_series(series_key) |>
      mutate(Series = series_label_map[[series_key]])
  }
}
