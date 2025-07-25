#' @keywords internal
"_PACKAGE"

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
#' NASCAR Cup Series Race Data
#'
#' Historical race results for NASCAR Cup Series races from 1949-present. Includes finishing position,
#' driver and car information, track details, and performance metrics for each entry.
#'
#' @format A data frame with rows representing each car/driver entry and 19 columns:
#' \describe{
#'   \item{Season}{Race season year}
#'   \item{Race}{Race number within the season}
#'   \item{Track}{Name of the racetrack}
#'   \item{Name}{Official race name}
#'   \item{Length}{Track length in miles}
#'   \item{Surface}{Track surface type (e.g., "road", "oval")}
#'   \item{Finish}{Finishing position}
#'   \item{Start}{Starting position}
#'   \item{Car}{Car number}
#'   \item{Driver}{Driver name}
#'   \item{Team}{Racing team name}
#'   \item{Make}{Car manufacturer}
#'   \item{Pts}{Championship points earned}
#'   \item{Laps}{Number of laps completed}
#'   \item{Led}{Number of laps led}
#'   \item{Status}{Race completion status (e.g., "running", "crash")}
#'   \item{S1}{Segment 1 finish position}
#'   \item{S2}{Segment 2 finish position}
#'   \item{Seg Points}{Segment points -- deprecated}
#'   \item{Rating}{Driver rating for the race}
#'   \item{Win}{Binary indicator if driver won the race (1 = yes, 0 = no)}
#' }
#' @source Data scraped from Driver Averages (https://www.driveraverages.com)
"cup_series"

#' NASCAR Xfinity Series Race Data
#'
#' Historical race results for NASCAR Xfinity Series races from 1982-present. Includes finishing position,
#' driver and car information, track details, and performance metrics for each entry.
#'
#' @format A data frame with rows representing each car/driver entry and 19 columns:
#' \describe{
#'   \item{Season}{Race season year}
#'   \item{Race}{Race number within the season}
#'   \item{Track}{Name of the racetrack}
#'   \item{Name}{Official race name}
#'   \item{Length}{Track length in miles}
#'   \item{Surface}{Track surface type (e.g., "road", "oval")}
#'   \item{Finish}{Finishing position}
#'   \item{Start}{Starting position}
#'   \item{Car}{Car number}
#'   \item{Driver}{Driver name}
#'   \item{Team}{Racing team name}
#'   \item{Make}{Car manufacturer}
#'   \item{Pts}{Championship points earned}
#'   \item{Laps}{Number of laps completed}
#'   \item{Led}{Number of laps led}
#'   \item{Status}{Race completion status (e.g., "running", "crash")}
#'   \item{S1}{Segment 1 finish position}
#'   \item{S2}{Segment 2 finish position}
#'   \item{Seg Points}{Segment points -- deprecated}
#'   \item{Rating}{Driver rating for the race}
#'   \item{Win}{Binary indicator if driver won the race (1 = yes, 0 = no)}
#' }
#' @source Data scraped from Driver Averages (https://www.driveraverages.com)
"xfinity_series"

#' NASCAR Truck Series Race Data
#'
#' Historical race results for NASCAR Truck Series races from 1995-present. Includes finishing position,
#' driver and car information, track details, and performance metrics for each entry.
#'
#' @format A data frame with rows representing each car/driver entry and 19 columns:
#' \describe{
#'   \item{Season}{Race season year}
#'   \item{Race}{Race number within the season}
#'   \item{Track}{Name of the racetrack}
#'   \item{Name}{Official race name}
#'   \item{Length}{Track length in miles}
#'   \item{Surface}{Track surface type (e.g., "road", "oval")}
#'   \item{Finish}{Finishing position}
#'   \item{Start}{Starting position}
#'   \item{Car}{Car number}
#'   \item{Driver}{Driver name}
#'   \item{Team}{Racing team name}
#'   \item{Make}{Car manufacturer}
#'   \item{Pts}{Championship points earned}
#'   \item{Laps}{Number of laps completed}
#'   \item{Led}{Number of laps led}
#'   \item{Status}{Race completion status (e.g., "running", "crash")}
#'   \item{S1}{Segment 1 finish position}
#'   \item{S2}{Segment 2 finish position}
#'   \item{Seg Points}{Segment points -- deprecated}
#'   \item{Rating}{Driver rating for the race}
#'   \item{Win}{Binary indicator if driver won the race (1 = yes, 0 = no)}
#' }
#' @source Data scraped from Driver Averages (https://www.driveraverages.com)
"truck_series"
