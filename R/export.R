#' Export NASCAR Series Data
#'
#' Downloads or loads the specified NASCAR series data and writes it
#' to a file in either CSV or Parquet format.
#'
#' @param series Character. The series to export. One of `"cup"`,
#'   `"nxs"`, or `"truck"`.
#' @param path Character. Path to the output file (including extension).
#' @param format Character. Output format: `"csv"`, `"parquet"`, or `NULL`.
#'   If `NULL` (default), the format is guessed from the file extension of `path`.
#' @param ... Additional arguments passed to [utils::write.csv()] (for CSV) or
#'   [arrow::write_parquet()] (for Parquet).
#'
#' @return Invisibly returns the exported data.
#'
#' @examples
#' \dontrun{
#' # Export Cup Series data to CSV
#' export_series("cup", "cup_data.csv")
#'
#' # Export Truck Series data to Parquet
#' export_series("truck", "truck_data.parquet")
#' }
#'
#' @export
export_series <- function(
  series = c("cup", "nxs", "truck"),
  path,
  format = NULL,
  ...
) {
  series <- match.arg(series)

  if (missing(path) || !is.character(path) || length(path) != 1) {
    rlang::abort(
      "`path` must be a single character string specifying the file path."
    )
  }

  if (is.null(format)) {
    ext <- tolower(tools::file_ext(path))
    if (ext == "csv") {
      format <- "csv"
    } else if (ext == "parquet") {
      format <- "parquet"
    } else {
      rlang::abort(c(
        "Could not determine format from file extension.",
        i = paste(
          "Use a '.csv' or '.parquet' extension,",
          "or set the `format` argument explicitly."
        )
      ))
    }
  }

  format <- tolower(format)
  if (!format %in% c("csv", "parquet")) {
    rlang::abort("`format` must be either \"csv\" or \"parquet\".")
  }

  data <- load_series(series)

  if (format == "csv") {
    # Default row.names to FALSE for cleaner CSVs, but let ... override it
    args <- list(x = data, file = path, row.names = FALSE)
    user_args <- list(...)
    for (name in names(user_args)) {
      args[[name]] <- user_args[[name]]
    }
    do.call(utils::write.csv, args)
  } else {
    arrow::write_parquet(data, path, ...)
  }

  invisible(data)
}
