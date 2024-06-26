#' @title NASCAR Cup Series Manufacturer Overall Statistics
#' @description A collection of overall statistics for manufacturers in the NASCAR Cup Series. The data includes overall totals and averages for various performance metrics.
#' @format A data frame with 361 rows and 13 variables:
#' \describe{
#'   \item{manufacturer}{chr: Manufacturer name}
#'   \item{mfg_overall_races}{num: Total number of races for the manufacturer}
#'   \item{mfg_overall_wins}{num: Total number of wins for the manufacturer}
#'   \item{mfg_overall_win_pct}{num: Win percentage for the manufacturer}
#'   \item{mfg_overall_top_5}{num: Total number of top 5 finishes for the manufacturer}
#'   \item{mfg_overall_top_10}{num: Total number of top 10 finishes for the manufacturer}
#'   \item{mfg_overall_top_20}{num: Total number of top 20 finishes for the manufacturer}
#'   \item{mfg_overall_cars_raced}{num: Total number of cars raced by the manufacturer}
#'   \item{mfg_overall_car_win_pct}{num: Win percentage at the car level for the manufacturer}
#'   \item{mfg_overall_avg_start}{num: Average start position for the manufacturer}
#'   \item{mfg_overall_avg_finish}{num: Average finish position for the manufacturer}
#'   \item{mfg_overall_laps_led}{num: Total number of laps led by the manufacturer}
#'   \item{mfg_overall_avg_laps_led}{num: Average number of laps led per race for the manufacturer}
#' }
#' @examples
#' data(cup_mfg_overall)
#' @source \url{https://www.driveraverages.com/nascar/nascar-stats.php}
#' @source \url{https://en.wikipedia.org/wiki/NASCAR_Cup_Series}
'cup_mfg_overall'
