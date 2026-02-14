#' Run All NASCAR Series Updates
#'
#' Orchestrator script that updates all three NASCAR series.
#' Called by GitHub Actions every Monday morning.

message("Starting NASCAR series updates...")
message(paste("Current time:", Sys.time()))

# Load all required libraries once
suppressPackageStartupMessages({
  library(arrow)
  library(dplyr)
  library(rvest)
  library(stringr)
  library(purrr)
  library(httr2)
  library(paws.storage)
})

# Source the R2 upload function and consolidated scraper
source("R/r2_upload.R")
source("inst/updates/scraper.R")

# Run all three series updates
message("\n", paste(rep("=", 50), collapse = ""))
message("STARTING ALL NASCAR SERIES UPDATES")
message(paste(rep("=", 50), collapse = ""))

errors <- character(0)

tryCatch(
  {
    update_nascar_series("cup")
  },
  error = function(e) {
    message("ERROR in Cup Series update: ", e$message)
    errors <<- c(errors, paste("Cup:", e$message))
  }
)

message("\n", paste(rep("=", 50), collapse = ""))

tryCatch(
  {
    update_nascar_series("nxs")
  },
  error = function(e) {
    message("ERROR in NXS update: ", e$message)
    errors <<- c(errors, paste("NXS:", e$message))
  }
)

message("\n", paste(rep("=", 50), collapse = ""))

tryCatch(
  {
    update_nascar_series("truck")
  },
  error = function(e) {
    message("ERROR in Truck Series update: ", e$message)
    errors <<- c(errors, paste("Truck:", e$message))
  }
)

message("\n", paste(rep("=", 50), collapse = ""))
message(paste("Finished at:", Sys.time()))

if (length(errors) > 0) {
  message("\nFAILED UPDATES:")
  for (err in errors) message("  - ", err)
  quit(status = 1)
} else {
  message("ALL NASCAR SERIES UPDATES COMPLETED SUCCESSFULLY!")
}
