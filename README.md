# nascaR.data <a href="https://kylegrealis.github.io/nascaR.data/"><img src="man/figures/logo.svg" align="right" height="139" alt="nascaR.data website" /></a>


[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/kyleGrealis/nascaR.data/actions)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN status](https://www.r-pkg.org/badges/version/nascaR.data)](https://CRAN.R-project.org/package=nascaR.data)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/nascaR.data)](https://cran.r-project.org/package=nascaR.data)
[![NASCAR Data Update](https://github.com/kyleGrealis/nascaR.data/actions/workflows/weekly-nascar-update.yml/badge.svg)](https://github.com/kyleGrealis/nascaR.data/actions/workflows/weekly-nascar-update.yml)


----

> ⚠️ **Version Notice**: The version on CRAN contains race data through the 2024 season. This GitHub version includes automated weekly updates. The updated data is available every Monday during the race season (February through November) on the `weekly` branch. See below for details on installing and updating.

**nascaR.data** provides historical race results from NASCAR's top three series: Cup (1949-present), Xfinity (1982-present), and Trucks (1995-present). Explore driver, team, and manufacturer performance in a race-by-race, season, or career format. This data has been expertly curated and scraped with permission from [DriverAverages.com](https://www.driveraverages.com).

## Installation

Install the stable CRAN version (through 2024 season):
```r
install.packages('nascaR.data')
# or
remotes::install_cran('nascaR.data')
# or
remotes::install_github('kyleGrealis/nascaR.data')
```
Install the weekly updated version:

```r
remotes::install_github('kyleGrealis/nascaR.data@weekly')
```

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
get_driver_info("Kyle Busch")
```

```
Kyle Busch
# A tibble: 3 × 8
  Series  Seasons `Career Races`  Wins `Best Finish` `Avg Finish` `Laps Raced` `Laps Led`
  <chr>     <int>          <int> <dbl>         <int>        <dbl>        <int>      <int>
1 Cup          21            696    61             1         14         188962      18918
2 Truck        22            175    66             1          6.5        25233       8050
3 Xfinity      21            367   102             1          9          65550      20129
```

```r
# Season results across all series
get_driver_info("Kyle Busch", type = "season")
```

```
Kyle Busch
# A tibble: 64 × 8
# Groups:   Series [3]
   Series Season Races  Wins `Best Finish` `Avg Finish` `Laps Raced` `Laps Led`
   <chr>   <int> <int> <dbl>         <int>        <dbl>        <int>      <int>
 1 Cup      2004     6     0            24         35.2         1098          0
 2 Cup      2005    34     2             1         20.4         9590        365
 3 Cup      2006    34     1             1         14.9         9807        543
 4 Cup      2007    35     1             1         13.9        10014        636
 5 Cup      2008    35     8             1         12.3        10046       1673
 6 Cup      2009    35     4             1         15.6        10005       1156
 7 Cup      2010    34     3             1         13.5        10365       1270
 8 Cup      2011    34     4             1         12.7         9563       1439
 9 Cup      2012    35     1             1         13.5         9577       1245
10 Cup      2013    34     4             1         12.9         9803       1227
# ℹ 54 more rows
# ℹ Use `print(n = ...)` to see more rows
```

Or search by race team or manufacturer:

```r
get_team_info("Petty Enterprises")
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



