#' @title NASCAR Cup Series Driver Season Statistics
#' @description A collection of NASCAR Cup Series driver season statistics from 1949 through the completion of the 2023 season. This dataset includes various performance metrics for each driver over each season.
#' @format A data frame with 9,665 rows and 26 variables:
#' \describe{
#'   \item{season}{num: Racing season (1949-2023)}
#'   \item{driver}{chr: Driver's name}
#'   \item{season_races}{num: Number of races participated in that season}
#'   \item{season_wins}{num: Number of wins in that season}
#'   \item{season_win_pct}{num: Win percentage in that season}
#'   \item{season_top_5}{num: Number of top 5 finishes in that season}
#'   \item{season_top_5_pct}{num: Top 5 percentage in that season}
#'   \item{season_top_10}{num: Number of top 10 finishes in that season}
#'   \item{season_top_10_pct}{num: Top 10 percentage in that season}
#'   \item{season_top_20}{num: Number of top 20 finishes in that season}
#'   \item{season_top_20_pct}{num: Top 20 percentage in that season}
#'   \item{season_avg_start}{num: Average start position in that season}
#'   \item{season_best_start}{num: Best start position in that season}
#'   \item{season_worst_start}{num: Worst start position in that season}
#'   \item{season_avg_finish}{num: Average finish position in that season}
#'   \item{season_best_finish}{num: Best finish position in that season}
#'   \item{season_worst_finish}{num: Worst finish position in that season}
#'   \item{season_avg_laps_led}{num: Average number of laps led per race in that season}
#'   \item{season_total_laps_led}{num: Total number of laps led in that season}
#'   \item{season_most_laps_led}{num: Most laps led in a single race in that season}
#'   \item{season_avg_points}{num: Average points earned per race in that season}
#'   \item{season_avg_playoff_pts}{num: Average playoff points earned per race in that season}
#'   \item{season_total_money}{num: Total earnings in that season (in dollars)}
#'   \item{season_avg_money}{num: Average earnings per race in that season (in dollars)}
#'   \item{season_max_race_money}{num: Maximum earnings in a single race in that season (in dollars)}
#'   \item{season_min_race_money}{num: Minimum earnings in a single race in that season (in dollars)}
#' }
#' @source \url{https://www.nascar.com/news/nascar-cup-series/}
#' @source \url{https://www.driveraverages.com/nascar/nascar-stats.php}
#' @source \url{https://www.racing-reference.info/nascar-cup-series-stats/}
#' @source \url{https://en.wikipedia.org/wiki/NASCAR_Cup_Series}
#' @examples
#' data(cup_driver_season)
'cup_driver_season'
