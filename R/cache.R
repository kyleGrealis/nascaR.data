#' Cache infrastructure for nascaR.data
#'
#' Two-tier caching: in-memory (per R session) and on-disk
#' (persists across sessions) using the CRAN-approved
#' `tools::R_user_dir()` location.
#'
#' @name nascaR.data-cache
#' @keywords internal
#' @noRd
NULL

# Package-level in-memory cache (resets each R session)
.nascar_cache <- new.env(parent = emptyenv())

#' Get the disk cache directory path
#'
#' Uses `tools::R_user_dir()` for CRAN-compliant storage.
#'
#' @return Character string with the cache directory path.
#' @keywords internal
#' @noRd
cache_dir <- function() {
  tools::R_user_dir("nascaR.data", which = "cache")
}

#' Clear Cached NASCAR Data
#'
#' Removes all cached NASCAR series data from both memory and
#' disk. The next call to [load_series()] will re-download
#' data from cloud storage.
#'
#' @return Invisibly returns `NULL`.
#'
#' @examples
#' \dontrun{
#' # Clear all cached data
#' clear_cache()
#'
#' # Force fresh download
#' cup <- load_series("cup")
#' }
#'
#' @export
clear_cache <- function() {
  rm(list = ls(.nascar_cache), envir = .nascar_cache)

  dir <- cache_dir()
  if (dir.exists(dir)) {
    unlink(dir, recursive = TRUE)
  }

  message("nascaR.data cache cleared.")
  invisible(NULL)
}
