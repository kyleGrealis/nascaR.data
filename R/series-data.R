#' NASCAR Series Data
#'
#' Historical race results from NASCAR's three major national series,
#' sourced with permission from
#' [DriverAverages.com](https://www.driveraverages.com). Data is hosted
#' on Cloudflare R2 and accessed via [load_series()].
#'
#' @section Cup Series (1949--present):
#' The NASCAR Cup Series is the sport's premier division. Originally
#' called the Strictly Stock Series in its inaugural 1949 season, it
#' has been known by several names tied to title sponsors: Grand
#' National (1950--1970), Winston Cup (1971--2003), Nextel Cup
#' (2004--2007), Sprint Cup (2008--2016), Monster Energy Cup
#' (2017--2019), and the NASCAR Cup Series (2020--present).
#'
#' ```
#' cup <- load_series("cup")
#' ```
#'
#' @section Xfinity / O'Reilly Auto Parts Series (1982--present):
#' NASCAR's second-tier national series, often considered a proving
#' ground for drivers aspiring to reach the Cup Series. It debuted
#' in 1982 as the Budweiser Late Model Sportsman Series and has
#' carried the names of several title sponsors: Busch Series
#' (1984--2007), Nationwide Series (2008--2014), Xfinity Series
#' (2015--2025), and the O'Reilly Auto Parts Series
#' (2026--present).
#'
#' ```
#' nxs <- load_series("nxs")
#' ```
#' The series identifier is \code{"nxs"}, NASCAR's own sponsor-neutral
#' abbreviation. This avoids tying the code to any single title sponsor.
#'
#' @section Truck Series (1995--present):
#' The NASCAR Craftsman Truck Series features modified pickup trucks
#' racing on a mix of ovals, short tracks, road courses, and dirt
#' tracks. It launched in 1995 as the SuperTruck Series and has been
#' sponsored under the names Craftsman Truck (1995--2008), Camping
#' World Truck (2009--2022), and Craftsman Truck again
#' (2023--present).
#'
#' ```
#' truck <- load_series("truck")
#' ```
#'
#' @section Variables:
#' All three series share the same column structure:
#'
#' \describe{
#'   \item{Season}{Integer. Year the race took place.}
#'   \item{Race}{Integer. Race number within the season.}
#'   \item{Track}{Character. Name of the track or venue.}
#'   \item{Name}{Character. Official race name (includes sponsor).}
#'   \item{Length}{Numeric. Track length in miles.}
#'   \item{Surface}{Character. Track surface type
#'     (e.g., `"Paved"`, `"Dirt"`).}
#'   \item{Finish}{Integer. Official finishing position.}
#'   \item{Start}{Integer. Starting grid position.}
#'   \item{Car}{Character. Car number.}
#'   \item{Driver}{Character. Driver's full name.}
#'   \item{Team}{Character. Team or car owner name.}
#'   \item{Make}{Character. Vehicle manufacturer
#'     (e.g., `"Chevrolet"`, `"Ford"`, `"Toyota"`).}
#'   \item{Pts}{Integer. Championship points earned.}
#'   \item{Laps}{Integer. Total laps completed.}
#'   \item{Led}{Integer. Number of laps led.}
#'   \item{Status}{Character. Race completion status
#'     (e.g., `"Running"`, `"Crash"`, `"Engine"`).}
#'   \item{S1}{Numeric. Stage 1 points (2017--present,
#'     `NA` for earlier seasons).}
#'   \item{S2}{Numeric. Stage 2 points (2017--present,
#'     `NA` for earlier seasons).}
#'   \item{S3}{Numeric. Stage 3 points. Cup Series only,
#'     2024--present (`NA` for NXS, Truck, and pre-2024 Cup).}
#'   \item{Rating}{Numeric. Driver/loop rating for the race
#'     (`NA` where unavailable).}
#'   \item{Win}{Integer. Win indicator (`1` = won, `0` = did not win).}
#' }
#'
#' @section Data Source:
#' All data is sourced with permission from
#' [DriverAverages.com](https://www.driveraverages.com) and updated
#' weekly via an automated pipeline. See [load_series()] for access
#' details and [clear_cache()] for cache management.
#'
#' @name series_data
#' @keywords datasets
NULL
