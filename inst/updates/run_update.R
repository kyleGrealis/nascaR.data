# Load required packages
library(purrr)      # for walk, map_dfr, keep
library(rvest)      # for read_html, html_elements, html_table
library(dplyr)      # for mutate, select, left_join, rename
library(stringr)    # for str_detect, str_remove, str_split

# Load existing datasets
load("data/cup_series.rda")
load("data/xfinity_series.rda")
load("data/truck_series.rda")

source("inst/updates/nascar_update.R")
current_month <- as.numeric(format(Sys.Date(), "%m"))

# Only run during race season (Feb-Nov)
if (current_month >= 2 && current_month <= 11) {
  update_nascar_data(debug = FALSE)
} else {
  message("Currently in off-season. No updates needed.")
  quit(status = 0)  # Exit successfully during off-season
}