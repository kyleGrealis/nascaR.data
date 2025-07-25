#' Run All NASCAR Series Updates
#'
#' Orchestrator script that updates all three NASCAR series.
#' Called by GitHub Actions every Monday morning.

message("Starting NASCAR series updates...")
message(paste("Current time:", Sys.time()))

# Load all required libraries once
suppressPackageStartupMessages({
  library(dplyr)
  library(rvest)
  library(stringr)
  library(purrr)
})

# Run all three series updates
message("\n", paste(rep("=", 50), collapse = ""))
message("STARTING ALL NASCAR SERIES UPDATES")
message(paste(rep("=", 50), collapse = ""))

tryCatch(
  {
    source("inst/updates/update_cup.R")
  },
  error = function(e) {
    message("ERROR in Cup Series update: ", e$message)
  }
)

message("\n", paste(rep("=", 50), collapse = ""))

tryCatch(
  {
    source("inst/updates/update_xfinity.R")
  },
  error = function(e) {
    message("ERROR in Xfinity Series update: ", e$message)
  }
)

message("\n", paste(rep("=", 50), collapse = ""))

tryCatch(
  {
    source("inst/updates/update_truck.R")
  },
  error = function(e) {
    message("ERROR in Truck Series update: ", e$message)
  }
)

message("\n", paste(rep("=", 50), collapse = ""))
message("ALL NASCAR SERIES UPDATES COMPLETED!")
message(paste(rep("=", 50), collapse = ""))
message(paste("Finished at:", Sys.time()))
