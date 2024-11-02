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
#' @importFrom dplyr bind_rows filter group_by if_else left_join mutate 
#' @importFrom dplyr n n_distinct pull rename select summarize
#' @importFrom glue glue
#' @importFrom purrr keep map_dfr pluck walk
#' @importFrom rlang abort
#' @importFrom rvest html_attr html_elements html_element html_table html_text2 read_html
#' @importFrom stringdist stringdist
#' @importFrom stringr str_detect str_remove str_split str_to_lower str_to_title
## usethis namespace: end
NULL