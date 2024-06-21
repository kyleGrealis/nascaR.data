#' @title NASCAR Cup Series Manufacturer Season Statistics
#' @description A collection of season statistics for manufacturers in the NASCAR Cup Series. The data includes season totals and averages for various performance metrics.
#' @format A data frame with 1,109 rows and 14 variables:
#' \describe{
#'   \item{manufacturer}{chr: Manufacturer name}
#'   \item{season}{num: Racing season}
#'   \item{mfg_season_races}{num: Total number of races for the manufacturer in the season}
#'   \item{mfg_season_wins}{num: Total number of wins for the manufacturer in the season}
#'   \item{mfg_season_top_5}{num: Total number of top 5 finishes for the manufacturer in the season}
#'   \item{mfg_season_top_10}{num: Total number of top 10 finishes for the manufacturer in the season}
#'   \item{mfg_season_top_20}{num: Total number of top 20 finishes for the manufacturer in the season}
#'   \item{mfg_season_win_pct}{num: Win percentage for the manufacturer in the season}
#'   \item{mfg_season_cars_raced}{num: Total number of cars raced by the manufacturer in the season}
#'   \item{mfg_season_car_win_pct}{num: Win percentage at the car level for the manufacturer in the season}
#'   \item{mfg_season_avg_start}{num: Average start position for the manufacturer in the season}
#'   \item{mfg_season_avg_finish}{num: Average finish position for the manufacturer in the season}
#'   \item{mfg_season_avg_laps_led}{num: Average number of laps led per race for the manufacturer in the season}
#'   \item{mfg_season_laps_led}{num: Total number of laps led by the manufacturer in the season}
#' }
#' @source \url{https://www.nascar.com/news/nascar-cup-series/}
#' @source \url{https://www.driveraverages.com/nascar/nascar-stats.php}
#' @source \url{https://www.racing-reference.info/nascar-cup-series-stats/}
#' @source \url{https://en.wikipedia.org/wiki/NASCAR_Cup_Series}
#' @examples
#' data(cup_mfg_season)
'cup_mfg_season'
