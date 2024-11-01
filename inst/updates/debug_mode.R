
# Debug mode:
# update_nascar_data(
#   debug = TRUE, 
#   target_year = 2024,
#   target_race = 15
# )

source("inst/updates/nascar_update.R")
current_month <- as.numeric(format(Sys.Date(), "%m"))

# Only run during race season (Feb-Nov)
if (current_month >= 2 && current_month <= 11) {
  update_nascar_data(
    debug = TRUE, 
    target_year = as.numeric(format(Sys.Date(), "%Y")),
    target_race = 1
  )
} else {
  message("Currently in off-season. No updates needed.")
  quit(status = 0)  # Exit successfully during off-season
}