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
#' Downloads NASCAR series data from Cloudflare R2 as a parquet file.
#' Uses two-tier caching (memory + disk) for performance. On first
#' call, data is downloaded and cached locally. Subsequent calls
#' return cached data instantly.
#'
#' @param series Character. The series to load. One of `"cup"`,
#'   `"xfinity"`, or `"truck"`.
#' @param refresh Logical. If `TRUE`, bypass the cache and
#'   re-download from cloud storage. Default is `FALSE`.
#'
#' @return A data frame with race results containing columns:
#'   Season, Race, Track, Name, Length, Surface, Finish, Start,
#'   Car, Driver, Team, Make, Pts, Laps, Led, Status, S1, S2,
#'   Rating, and Win.
#'
#' @details
#' Requires the `arrow` package to read parquet files. If `arrow`
#' is not installed, you will be prompted to install it.
#'
#' ## Caching
#'
#' Data is cached in two tiers:
#' \itemize{
#'   \item **Memory**: Instant access within the current R session.
#'   \item **Disk**: Persists across sessions at the CRAN-approved
#'     location returned by
#'     `tools::R_user_dir("nascaR.data", which = "cache")`.
#' }
#'
#' Use `refresh = TRUE` to force a fresh download, or
#' [clear_cache()] to remove all cached data.
#'
#' @examples
#' \dontrun{
#' # Load Cup Series data (downloads on first call, cached after)
#' cup <- load_series("cup")
#'
#' # Load Xfinity Series data
#' xfinity <- load_series("xfinity")
#'
#' # Load Truck Series data
#' truck <- load_series("truck")
#'
#' # Force re-download from cloud storage
#' cup <- load_series("cup", refresh = TRUE)
#' }
#'
#' @export
load_series <- function(series = c("cup", "xfinity", "truck"),
                        refresh = FALSE) {
  series <- match.arg(series)
  cache_key <- paste0(series, "_series")

  # 1. Memory cache (instant, within session)
  if (!refresh && exists(cache_key, envir = .nascar_cache)) { # nolint
    return(get(cache_key, envir = .nascar_cache)) # nolint
  }

  rlang::check_installed("arrow", reason = "to load NASCAR data")

  # 2. Disk cache (persists across sessions)
  disk_path <- file.path(
    cache_dir(), # nolint
    paste0(cache_key, ".parquet")
  )

  if (!refresh && file.exists(disk_path)) {
    data <- arrow::read_parquet(disk_path)
    assign(cache_key, data, envir = .nascar_cache) # nolint
    return(data)
  }

  # 3. Download from R2
  url <- glue(
    "https://nascar.kylegrealis.com/{cache_key}.parquet"
  )

  data <- tryCatch(
    arrow::read_parquet(url),
    error = function(e) {
      rlang::abort(c(
        glue("Failed to load {series} series data."),
        i = glue("URL: {url}"),
        i = "Check your internet connection.",
        i = "If cached data exists, use load_series(refresh = FALSE)."
      ))
    }
  )

  # Save to disk cache
  dir.create(cache_dir(), recursive = TRUE, showWarnings = FALSE) # nolint
  arrow::write_parquet(data, disk_path)

  # Save to memory cache
  assign(cache_key, data, envir = .nascar_cache) # nolint

  data
}
