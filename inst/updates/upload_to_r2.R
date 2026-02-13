#' Seed / Manual Upload NASCAR Data to Cloudflare R2
#'
#' Converts local rda files to parquet and uploads to R2.
#' Used for initial seeding or manual re-uploads. The weekly
#' GitHub Actions workflow does NOT use this script -- the
#' scraper (scraper.R) handles R2 uploads directly.
#'
#' Usage:
#'   Rscript inst/updates/upload_to_r2.R
#'   Rscript inst/updates/upload_to_r2.R --dry-run

args <- commandArgs(trailingOnly = TRUE)
dry_run <- "--dry-run" %in% args

message("Starting R2 upload process...")
message("Mode: ", if (dry_run) "DRY RUN (no upload)" else "PRODUCTION")
message("Time: ", Sys.time())

suppressPackageStartupMessages({
  library(arrow)
  library(jsonlite)
  if (!dry_run) library(paws.storage)
})

# Source the upload function
source("R/r2_upload.R")

# Validate R2 credentials (unless dry run)
if (!dry_run) {
  required_vars <- c(
    "R2_ACCOUNT_ID", "R2_ACCESS_KEY_ID", "R2_SECRET_ACCESS_KEY"
  )
  missing_vars <- required_vars[
    !vapply(required_vars, function(v) nzchar(Sys.getenv(v)), logical(1))
  ]
  if (length(missing_vars) > 0) {
    stop("Missing R2 credentials: ", paste(missing_vars, collapse = ", "))
  }
}

# Checksum file for change detection
checksum_file <- ".checksums.json"

if (file.exists(checksum_file)) {
  checksums <- jsonlite::fromJSON(checksum_file)
} else {
  checksums <- list()
}

series_list <- list(
  list(name = "cup_series", file = "data/cup_series.rda"),
  list(name = "xfinity_series", file = "data/xfinity_series.rda"),
  list(name = "truck_series", file = "data/truck_series.rda")
)

uploads <- 0L
changed <- 0L

for (s in series_list) {
  if (!file.exists(s$file)) {
    message("  ", s$name, ": SKIP (file not found)")
    next
  }

  # Compute MD5 of the rda file
  current_hash <- tools::md5sum(s$file)[[1]]
  previous_hash <- checksums[[s$name]]

  if (!is.null(previous_hash) && identical(current_hash, previous_hash)) {
    message("  ", s$name, ": unchanged")
    next
  }

  changed <- changed + 1L

  # Load the data to show stats
  load(s$file)
  data <- get(s$name)
  message(
    "  ", s$name, ": CHANGED (",
    format(nrow(data), big.mark = ","), " rows, ",
    length(unique(data$Season)), " seasons)"
  )

  if (dry_run) {
    message("    -> would upload ", s$name, ".parquet to R2")
    next
  }

  # Upload to R2
  tryCatch(
    {
      nascar_r2_upload(data, s$name)
      checksums[[s$name]] <- current_hash
      uploads <- uploads + 1L
      message("    -> uploaded")
    },
    error = function(e) {
      message("    -> ERROR: ", conditionMessage(e))
    }
  )
}

# Save updated checksums (even in dry run, don't update)
if (!dry_run) {
  jsonlite::write_json(checksums, checksum_file, auto_unbox = TRUE)
  message("\nUpdated ", checksum_file)
}

message("\nSummary: ", changed, " changed, ", uploads, " uploaded")
if (dry_run) message("(Dry run - no files were uploaded or checksums updated)")
message("Finished at: ", Sys.time())
