# nascaR.data <img src="inst/images/hex-logo.png" alt="nascaR.data Logo" align="right" height="130"/>


[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/kyleGrealis/nascaR.data/actions)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![NASCAR Data Update](https://github.com/kyleGrealis/nascaR.data/actions/workflows/weekly-nascar-update.yml/badge.svg)](https://github.com/kyleGrealis/nascaR.data/actions/workflows/weekly-nascar-update.yml)
----

> ⚠️ **Version Notice**: The version on CRAN contains race data through the 2023 season. This GitHub version includes automated weekly updates for the 2024 season and will be synchronized with CRAN by December 1, 2024.

**nascaR.data** provides historical race results from NASCAR's top three series: Cup (1949-present), Xfinity (1982-present), and Trucks (1995-present). Data is automatically updated every Monday at midnight during race season.

## Installation

Install the stable CRAN version (through 2023 season):
```r
install.packages('nascaR.data')
# or
remotes::install_cran('nascaR.data')
```
Install the development version with weekly 2024 updates:

```
remotes::install_github('kyleGrealis/nascaR.data')
```

---

## In the Pits

NASCAR is one of the top-tier racing sports in North America and competes against F1 and IndyCar for the top viewership spot. Approximately 3.22 million people watch a race on any given weekend throughout the season. The nascaR.data package is the result of wanting to share a passion for the sport and provide an option to the typical go-to packages when learning new data visualization tools.

## Data Structure

The package provides three main datasets:

* `cup_series`: NASCAR Cup Series race results (1949-present)
* `xfinity_series`: NASCAR Xfinity Series race results (1982-present)
* `truck_series`: NASCAR Craftsman Truck Series results (1995-present)

Each dataset contains detailed race information including:

* Race details (Season, Race number, Track, Name)
* Results (Finish position, Start position)
* Performance metrics (Laps completed, Laps led, Points earned)
* Driver and team information

Data is sourced with permission from DriverAverages.com and is automatically updated every Monday at midnight during the racing season (February-November).

## Usage

Load the package:

```
library(nascaR.data)
```

View the dataset documentation:

```
?cup_series
?xfinity_series
?truck_series
```

## The Backstretch
This package provides rich historical data for:

* Analyzing race trends across series
* Comparing driver performances
* Creating visualizations of NASCAR statistics

### Helper Functions

The package includes convenient functions to find driver, team, and manufacturer results:

### Driver Information

Get race results for a specific driver:

```
get_driver_info("Kyle Larson") # or
get_driver_info("kyle larson")
```

or search by race team or manufacturer:

```
get_team_info("Petty Enterprises")
get_manufacturer_info("Toyota")
```