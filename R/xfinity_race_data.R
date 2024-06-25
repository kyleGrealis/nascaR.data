#' @title NASCAR Xfinity Series Results
#' @description A collection of NASCAR's second-tier competitive race series results from the first race in 1982 through the completion of the 2023 season. The series has undergone several name changes, including the Budweiser Late Model Sportsman Series, the NASCAR Busch Grand National Series, and the current NASCAR Xfinity Series.
#' @format A data frame with 51,672 rows and 23 variables:
#' \describe{
#'   \item{season}{num: Racing season (1982-2023)}
#'   \item{race}{num: Chronological race number for that season (1-35)}
#'   \item{site}{chr: Location of the race (city)}
#'   \item{track}{chr: Race track name}
#'   \item{track_length}{num: Race track length, in miles}
#'   \item{track_type}{chr: Race track surface (dirt track, paved track, road course)}
#'   \item{finish}{num: Finish position in the race}
#'   \item{start}{num: Start position in the race}
#'   \item{driver}{chr: Driver's name}
#'   \item{manufacturer}{chr: Car manufacturer (e.g., "Chevrolet", "Ford", "Toyota")}
#'   \item{car_number}{chr: Car number}
#'   \item{owner}{chr: Car owner}
#'   \item{sponsor}{chr: Car sponsor}
#'   \item{win}{num: Indicator variable for win; `1` = win, `0` = did not win}
#'   \item{top_5}{num: Indicator variable for finish position in 5th place or better; `1` = yes, `0` = no}
#'   \item{top_10}{num: Indicator variable for finish position in 10th place or better; `1` = yes, `0` = no}
#'   \item{top_20}{num: Indicator variable for finish position in 20th place or better; `1` = yes, `0` = no}
#'   \item{laps}{num: Number of laps completed in the race}
#'   \item{laps_led}{num: Number of laps led in the race}
#'   \item{status}{chr: Status at the end of the race (e.g., "Running", "Accident")}
#'   \item{money}{num: Total race earning (in dollars) not including bonus money, if available. No available data beginning with the 2016 season.}
#'   \item{pts}{num: Points earned in the race}
#'   \item{playoff_pts}{num: Playoff points earned in the race. Available beginning with the 2017 season.}
#' }
#' @source \url{https://www.driveraverages.com/nascar_xfinityseries/}
#' @source \url{https://en.wikipedia.org/wiki/NASCAR_Xfinity_Series}
#' @examples
#' data(xfinity_race_data)
'xfinity_race_data'