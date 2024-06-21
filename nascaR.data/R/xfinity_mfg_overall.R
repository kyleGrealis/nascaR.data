#' @title NASCAR Xfinity Series Manufacturer Overall Statistics
#' @description A collection of overall statistics for manufacturers in the NASCAR Xfinity Series. The data includes overall totals and averages for various performance metrics.
#' @format A data frame with 9 rows and 13 variables:
#' \describe{
#'   \item{manufacturer}{chr: Manufacturer name}
#'   \item{mfg_overall_races}{num: Total number of races for the manufacturer}
#'   \item{mfg_overall_wins}{num: Total number of wins for the manufacturer}
#'   \item{mfg_overall_win_pct}{num: Win percentage for the manufacturer}
#'   \item{mfg_overall_top_5}{num: Total number of top 5 finishes for the manufacturer}
#'   \item{mfg_overall_top_10}{num: Total number of top 10 finishes for the manufacturer}
#'   \item{mfg_overall_top_20}{num: Total number of top 20 finishes for the manufacturer}
#'   \item{mfg_overall_trucks_raced}{num: Total number of trucks raced by the manufacturer}
#'   \item{mfg_overall_truck_win_pct}{num: Win percentage at the truck level for the manufacturer}
#'   \item{mfg_overall_avg_start}{num: Average start position for the manufacturer}
#'   \item{mfg_overall_avg_finish}{num: Average finish position for the manufacturer}
#'   \item{mfg_overall_laps_led}{num: Total number of laps led by the manufacturer}
#'   \item{mfg_overall_avg_laps_led}{num: Average number of laps led per race for the manufacturer}
#' }
#' @examples
#' data(xfinity_mfg_overall)
#' @source \url{https://www.nascar.com/news/nascar-xfinity-series/}
#' @source \url{https://www.driveraverages.com/nascar_xfinityseries/}
#' @source \url{https://www.racing-reference.info/nascar-xfinity-series-stats/}
#' @source \url{https://en.wikipedia.org/wiki/NASCAR_Xfinity_Series}
'xfinity_mfg_overall'
