#' @title NASCAR Xfinity Series Driver Career Statistics
#' @description A collection of career statistics for drivers in the NASCAR Xfinity Series. The data includes career averages and totals for various performance metrics.
#' @format A data frame with 1,308 rows and 23 variables:
#' \describe{
#'   \item{driver}{chr: Driver's name}
#'   \item{career_races}{num: Total number of races driven in their career}
#'   \item{career_wins}{num: Total number of wins in their career}
#'   \item{career_win_pct}{num: Win percentage for their career}
#'   \item{career_top_5}{num: Total number of top 5 finishes in their career}
#'   \item{career_top_5_pct}{num: Percentage of top 5 finishes in their career}
#'   \item{career_top_10}{num: Total number of top 10 finishes in their career}
#'   \item{career_top_10_pct}{num: Percentage of top 10 finishes in their career}
#'   \item{career_top_20}{num: Total number of top 20 finishes in their career}
#'   \item{career_top_20_pct}{num: Percentage of top 20 finishes in their career}
#'   \item{career_avg_start}{num: Average start position for their career}
#'   \item{career_best_start}{num: Best start position in their career}
#'   \item{career_worst_start}{num: Worst start position in their career}
#'   \item{career_avg_finish}{num: Average finish position for their career}
#'   \item{career_best_finish}{num: Best finish position in their career}
#'   \item{career_worst_finish}{num: Worst finish position in their career}
#'   \item{career_avg_laps_led}{num: Average number of laps led per race in their career}
#'   \item{career_total_laps_led}{num: Total number of laps led in their career}
#'   \item{career_most_laps_led}{num: Most laps led in a single race in their career}
#'   \item{career_total_money}{num: Total earnings for their career (in dollars)}
#'   \item{career_avg_money}{num: Average earnings per race for their career (in dollars)}
#'   \item{career_max_race_money}{num: Highest earnings in a single race for their career (in dollars)}
#'   \item{career_min_race_money}{num: Lowest earnings in a single race for their career (in dollars)}
#' }
#' @source \url{https://www.driveraverages.com/nascar_xfinityseries/}
#' @source \url{https://en.wikipedia.org/wiki/NASCAR_Xfinity_Series}
#' @examples
#' data(xfinity_driver_career)
'xfinity_driver_career'
