# Declare global variables used in dplyr/tidyr operations
utils::globalVariables(c(
  "Driver",
  "Finish",
  "Laps",
  "Led",
  "Make",
  "Name",
  "Season",
  "Series",
  "Team",
  "Win"
))

#' Load NASCAR Series Data
#'
#' Downloads NASCAR series data from Cloudflare R2 as a parquet
#' file. Data is cached in memory for the current R session so
#' repeated calls are instant. Each new R session downloads
#' fresh data, ensuring you always have the latest results.
#'
#' @param series Character. The series to load. One of `"cup"`,
#'   `"nxs"`, or `"truck"`.
#' @param refresh Logical. If `TRUE`, bypass the in-memory cache
#'   and re-download from cloud storage. Default is `FALSE`.
#'
#' @return A data frame with 21 columns of race results:
#'   Season, Race, Track, Name, Length, Surface, Finish, Start,
#'   Car, Driver, Team, Make, Pts, Laps, Led, Status, S1, S2,
#'   S3, Rating, and Win.
#'
#' @details
#' ## Why "nxs"?
#'
#' NASCAR's NXS uses the sponsor-neutral identifier `"nxs"`
#' rather than a sponsor name. The series has been sponsored by
#' Busch (1984-2007), Nationwide (2008-2014), Xfinity
#' (2015-2025), and O'Reilly Auto Parts (2026-present). Using
#' `"nxs"` keeps the identifier stable across sponsor changes.
#'
#' ## Caching
#'
#' Data is cached in memory for the current R session. Repeated
#' calls return instantly without re-downloading. Starting a new
#' R session always fetches the latest data from R2.
#'
#' Use `refresh = TRUE` to force a re-download within a session,
#' or [clear_cache()] to reset the in-memory cache.
#'
#' @seealso [series_data] for column descriptions,
#'   [clear_cache()] for cache management,
#'   [get_driver_info()] for driver statistics.
#'
#' @examples
#' \donttest{
#' # Load Cup Series data (downloads on first call, cached after)
#' cup <- load_series("cup")
#'
#' # Load NXS data
#' nxs <- load_series("nxs")
#'
#' # Load Truck Series data
#' truck <- load_series("truck")
#'
#' # Force re-download from cloud storage
#' cup <- load_series("cup", refresh = TRUE)
#' }
#'
#' @export
load_series <- function(series = c("cup", "nxs", "truck"),
                        refresh = FALSE) {
  # Validate refresh
  if (!is.logical(refresh) || length(refresh) != 1) {
    rlang::abort("`refresh` must be TRUE or FALSE.")
  }

  # Help users migrating from v2
  if (
    is.character(series) &&
      length(series) == 1 &&
      tolower(series) == "xfinity"
  ) {
    rlang::abort(c(
      paste0(
        "\"xfinity\" was renamed to \"nxs\" ",
        "in nascaR.data v3.0.0."
      ),
      i = "Use `load_series(\"nxs\")` instead.",
      i = "See `vignette(\"migrating-to-nxs\")` for details."
    ))
  }

  series <- match.arg(series)
  cache_key <- paste0(series, "_series")

  # Memory cache (instant, within session)
  if (!refresh && exists(cache_key, envir = .nascar_cache)) {
    return(get(cache_key, envir = .nascar_cache))
  }

  # Download from R2
  url <- glue(
    "https://nascar.kylegrealis.com/{cache_key}.parquet"
  )

  data <- tryCatch(
    arrow::read_parquet(url),
    error = function(e) {
      rlang::abort(c(
        glue("Failed to load {series} series data."),
        i = glue("URL: {url}"),
        i = "Check your internet connection."
      ))
    }
  )

  # Save to memory cache
  assign(cache_key, data, envir = .nascar_cache)

  data
}
