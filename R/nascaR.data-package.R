#' NASCAR Race Statistics Package
#'
#' @description
#' Provides tools for analyzing NASCAR race data across the three major series:
#' NASCAR Cup Series, NASCAR Xfinity Series, and NASCAR Craftsman Truck Series.
#' Functions allow retrieval and analysis of statistics for drivers, team owners,
#' and manufacturers.
#'
#' @keywords internal
#' @noRd
"_PACKAGE"

## usethis namespace: start
#' @importFrom dplyr bind_rows filter if_else mutate pull
#' @importFrom glue glue
#' @importFrom purrr pluck
#' @importFrom rlang abort
#' @importFrom rvest html_attr html_elements html_table html_text2 read_html
#' @importFrom stringdist stringdist
#' @importFrom stringr str_detect str_remove str_split str_to_lower str_to_title
## usethis namespace: end
NULL