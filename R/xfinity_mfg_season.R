#' @title NASCAR Xfinity Series Manufacturer Season Statistics
#' @description A collection of season statistics for manufacturers in the NASCAR Xfinity Series. The data includes season totals and averages for various performance metrics.
#' @format A data frame with 179 rows and 14 variables:
#' \describe{
#'   \item{manufacturer}{chr: Manufacturer name}
#'   \item{season}{num: Racing season (1982-2023)}
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
#' @source \url{https://www.driveraverages.com/nascar_xfinityseries/}
#' @source \url{https://en.wikipedia.org/wiki/NASCAR_Xfinity_Series}
#' @examples
#' data(xfinity_mfg_season)
'xfinity_mfg_season'
