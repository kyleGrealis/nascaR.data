# nascaR.data <a href="https://azimuth-project.tech/nascaR.data/"><img src="man/figures/logo.svg" align="right" height="139" alt="nascaR.data website" /></a>


[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/kyleGrealis/nascaR.data/actions)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN status](https://www.r-pkg.org/badges/version/nascaR.data)](https://CRAN.R-project.org/package=nascaR.data)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/nascaR.data)](https://cran.r-project.org/package=nascaR.data)
[![NASCAR Data Update](https://github.com/kyleGrealis/nascaR.data/actions/workflows/weekly-nascar-update.yml/badge.svg)](https://github.com/kyleGrealis/nascaR.data/actions/workflows/weekly-nascar-update.yml)


----

> ⚠️ **Version Notice**: The version on CRAN contains race data through the 2025 Nashville race (race number 14). This GitHub version includes automated weekly updates. The updated data is available every Monday during the race season (February through November) on the `main` branch. See below for details on installing and updating.

**nascaR.data** provides historical race results from NASCAR's top three series: Cup (1949-present), Xfinity (1982-present), and Trucks (1995-present). Explore driver, team, and manufacturer performance in a race-by-race, season, or career format. This data has been expertly curated and scraped with permission from [DriverAverages.com](https://www.driveraverages.com).

> ⚠️⚠️ **Deprecating `weekly` branch**: Beginning June 2025, please use the `main` branch for the weekly updates and no longer use the `weekly` branch. The GitHub Action that scrapes the results will push updates to `main`. The `weekly` branch will be removed at the end of the 2025 season. Thank you :)

## Installation

For the most up-to-date results, install the from the `main` branch. This branch will update every Monday:

```r
remotes::install_github('kyleGrealis/nascaR.data')
```

Install the stable CRAN version (through Nashville race of the 2025 season):
```r
install.packages('nascaR.data')
# or
remotes::install_cran('nascaR.data')
```

> Stable CRAN package updates are planned sporadically throughtout the season.

---

## In the Pits

NASCAR is one of the top-tier racing sports in North America and competes against Formula-1 and IndyCar for the top viewership spot. Approximately 3.22 million people watch a race on any given weekend throughout the season. The nascaR.data package is the result of wanting to share a passion for the sport and provide an option to the typical go-to packages when learning new data cleaning & visualization tools.

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

Data is sourced with permission from DriverAverages.com and is automatically updated every Monday at 5AM EST during the racing season (February through November).

## Usage

Load the package:

```r
library(nascaR.data)
```

### Race Data

View the dataset documentation:

```r
?cup_series
?xfinity_series
?truck_series
```

### Driver, Team, & Manufacturer Data

Use the suite of `get_*_info()` functions to examine specific performace results on a race-by-race, season, or career level.

```r
# Career results across all series
get_driver_info("Christopher Bell")
```

```
Christopher Bell
# A tibble: 3 × 8
  Series  Seasons `Career Races`  Wins `Best Finish` `Avg Finish` `Laps Raced` `Laps Led`
  <chr>     <int>          <int> <dbl>         <int>        <dbl>        <int>      <int>
1 Cup           5            180     9             1         15.1        45321       2435
2 Truck         6             57     7             1          8.5         8132       1216
3 Xfinity       6             79    19             1          9.8        12909       3245
```

```r
# Season results across all series
get_driver_info("Christopher Bell", type = "season")
```

```
Christopher Bell
# A tibble: 17 × 8
# Groups:   Series [3]
   Series  Season Races  Wins `Best Finish` `Avg Finish` `Laps Raced` `Laps Led`
   <chr>    <int> <int> <dbl>         <int>        <dbl>        <int>      <int>
 1 Cup       2020    36     0             3         20.2         9428         18
 2 Cup       2021    36     1             1         15.8         8911        100
 3 Cup       2022    36     3             1         13.8         8816        573
 4 Cup       2023    36     2             1         12.9         8868        599
 5 Cup       2024    35     3             1         12.8         9298       1145
 6 Truck     2015     7     1             1         11.9         1018        111
 7 Truck     2016    23     1             1          9.5         3237        197
 8 Truck     2017    23     5             1          5.7         3247        875
 9 Truck     2018     1     0            28         28            184         31
10 Truck     2023     2     0             4         10            312          0
11 Truck     2024     1     0             5          5            134          2
12 Xfinity   2017     8     1             1         11.5         1423        156
13 Xfinity   2018    32     7             1         11.1         5112        759
14 Xfinity   2019    31     8             1          9.1         5574       2005
15 Xfinity   2021     2     1             1          3.5          300        174
16 Xfinity   2022     1     0             7          7            147          0
17 Xfinity   2024     2     2             1          1            353        151
```

Or search by race team or manufacturer:

```r
get_team_info("Joe Gibbs Racing")
get_manufacturer_info("Toyota")
```

## The Backstretch
This package provides rich historical data for:

* Analyzing race trends across series
* Comparing driver performances
* Creating visualizations of NASCAR statistics

### Functions Reference

| Function | Description |
|----------|-------------|
| `get_driver_info()` | Obtain race, season, or career performance results |
| `get_team_info()` | Team-specific race, season, or career results (i.e., Petty Enterprises) |
| `get_manufacturer_info()` | Ford, Chevy, Toyota, Dodge, even Studebaker |

### Dataset Reference

| Dataset |  |
|---------|--|
| `cup_series` | Across the many names from Winston Cup to Sprint Cup and more |
| `xfinity_series` | Using the current series name (as of Jan. 2025) |
| `truck_series` | Same as the others. Though names have changed, the passion remains |


## Contributing

We're open to suggestions! If you have ideas for new features, please open an issue on our GitHub repository.

----

## License

[GNU General Public License (Version 3)](https://choosealicense.com/licenses/gpl-3.0/)

---

Developed by [Kyle Grealis](https://github.com/kyleGrealis)



