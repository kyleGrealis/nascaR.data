#' In-memory cache for nascaR.data
#'
#' Caches downloaded series data for the current R session to
#' avoid redundant downloads when `load_series()` is called
#' multiple times. Resets automatically when the session ends.
#'
#' @name nascaR.data-cache
#' @keywords internal
#' @noRd
NULL

# Package-level in-memory cache (resets each R session)
.nascar_cache <- new.env(parent = emptyenv())

#' Clear Cached NASCAR Data
#'
#' Clears the in-memory cache so the next call to
#' [load_series()] will re-download from cloud storage.
#' Also removes any leftover disk cache from previous
#' package versions.
#'
#' @return Invisibly returns `NULL`.
#'
#' @seealso [load_series()] for data access.
#'
#' @examples
#' \dontrun{
#' # Clear in-memory cache
#' clear_cache()
#'
#' # Next call downloads fresh data
#' cup <- load_series("cup")
#' }
#'
#' @export
clear_cache <- function() {
  rm(list = ls(.nascar_cache), envir = .nascar_cache)

  # Clean up disk cache from v3.0.0 if it exists
  dir <- tools::R_user_dir("nascaR.data", which = "cache")
  if (dir.exists(dir)) {
    unlink(dir, recursive = TRUE)
    message(
      "nascaR.data cache cleared ",
      "(legacy disk cache removed)."
    )
  } else {
    message("nascaR.data cache cleared.")
  }

  invisible(NULL)
}
