
# Normal update mode:
# update_nascar_data()

source("inst/updates/nascar_update.R")
current_month <- as.numeric(format(Sys.Date(), "%m"))

# Only run during race season (Feb-Nov)
if (current_month >= 2 && current_month <= 11) {
  update_nascar_data(debug = FALSE)
} else {
  message("Currently in off-season. No updates needed.")
  quit(status = 0)  # Exit successfully during off-season
}