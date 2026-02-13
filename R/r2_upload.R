#' Upload a dataset to Cloudflare R2 bucket
#'
#' Uploads an R data frame to the nascaR.data R2 bucket as a parquet file.
#'
#' @details
#' Authentication requires three environment variables:
#' \itemize{
#'   \item `R2_ACCOUNT_ID`: Your Cloudflare account ID.
#'   \item `R2_ACCESS_KEY_ID`: Your R2 access key ID.
#'   \item `R2_SECRET_ACCESS_KEY`: Your R2 secret access key.
#' }
#'
#' Files are uploaded to the bucket root, creating URLs like:
#' `https://nascar.kylegrealis.com/cup_series.parquet`.
#'
#' @param x The data frame to upload.
#' @param name The file name (without extension). Saved as
#'   `{name}.parquet` in the bucket root.
#' @param bucket The R2 bucket name.
#'
#' @return Invisibly returns NULL after successful upload.
#'
#' @keywords internal
#' @noRd
nascar_r2_upload <- function(x, name, bucket = "nascar-data") {
  rlang::check_installed(
    "arrow",
    reason = "to write parquet files for R2 upload."
  )

  rlang::check_installed(
    "paws.storage",
    reason = "to upload files to Cloudflare R2."
  )

  # Check for required environment variables
  required_vars <- c(
    "R2_ACCOUNT_ID",
    "R2_ACCESS_KEY_ID",
    "R2_SECRET_ACCESS_KEY"
  )
  missing_vars <- required_vars[
    !vapply(
      required_vars,
      function(v) nzchar(Sys.getenv(v)),
      logical(1)
    )
  ]

  if (length(missing_vars) > 0) {
    rlang::abort(c(
      "Missing R2 environment variables.",
      x = paste(missing_vars, collapse = ", "),
      i = "Set these in .Renviron or as GitHub Secrets."
    ))
  }

  # Write to temp parquet file
  temp_file <- tempfile(fileext = ".parquet")
  on.exit(unlink(temp_file), add = TRUE)
  arrow::write_parquet(x, temp_file)

  # Configure S3 client for R2
  s3 <- paws.storage::s3(
    config = list(
      credentials = list(
        creds = list(
          access_key_id = Sys.getenv("R2_ACCESS_KEY_ID"),
          secret_access_key = Sys.getenv("R2_SECRET_ACCESS_KEY")
        )
      ),
      endpoint = sprintf(
        "https://%s.r2.cloudflarestorage.com",
        Sys.getenv("R2_ACCOUNT_ID")
      ),
      region = "auto"
    )
  )

  # Upload to bucket root
  key_name <- paste0(name, ".parquet")

  tryCatch(
    {
      s3$put_object(
        Bucket = bucket,
        Key = key_name,
        Body = temp_file
      )
      message("Uploaded ", key_name, " to ", bucket)
    },
    error = function(e) {
      rlang::abort(c(
        paste0("Failed to upload ", key_name, " to R2."),
        x = conditionMessage(e)
      ))
    }
  )

  invisible(NULL)
}
