% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cup_owner_season.R
\docType{data}
\name{cup_owner_season}
\alias{cup_owner_season}
\title{NASCAR Cup Series Owner Season Statistics}
\format{
A data frame with 6560 rows and 14 variables:
\describe{
\item{owner}{chr: Owner name}
\item{season}{num: Racing season (1949-2023)}
\item{owner_season_races}{num: Total number of races for the owner in the season}
\item{owner_season_wins}{num: Total number of wins for the owner in the season}
\item{owner_season_top_5}{num: Total number of top 5 finishes for the owner in the season}
\item{owner_season_top_10}{num: Total number of top 10 finishes for the owner in the season}
\item{owner_season_top_20}{num: Total number of top 20 finishes for the owner in the season}
\item{owner_season_win_pct}{num: Win percentage for the owner in the season}
\item{owner_season_cars_raced}{num: Total number of cars raced by the owner in the season}
\item{owner_season_car_win_pct}{num: Win percentage at the car level for the owner in the season}
\item{owner_season_avg_start}{num: Average start position for the owner in the season}
\item{owner_season_avg_finish}{num: Average finish position for the owner in the season}
\item{owner_season_avg_laps_led}{num: Average number of laps led per race for the owner in the season}
\item{owner_season_laps_led}{num: Total number of laps led by the owner in the season}
}
}
\source{
\url{https://www.driveraverages.com/nascar/nascar-stats.php}

\url{https://en.wikipedia.org/wiki/NASCAR_Cup_Series}
}
\usage{
cup_owner_season
}
\description{
A collection of season statistics for owners in the NASCAR Cup Series. The data includes season totals and averages for various performance metrics.
}
\examples{
data(cup_owner_season)
}
\keyword{datasets}
