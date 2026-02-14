# nascaR.data <a href="https://www.kylegrealis.com/nascaR.data/"><img src="man/figures/logo.svg" align="right" height="139" alt="nascaR.data website" /></a>


[![R-CMD-check](https://github.com/kyleGrealis/nascaR.data/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/kyleGrealis/nascaR.data/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN status](https://www.r-pkg.org/badges/version/nascaR.data)](https://CRAN.R-project.org/package=nascaR.data)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/nascaR.data)](https://cran.r-project.org/package=nascaR.data)
[![NASCAR Data Update](https://github.com/kyleGrealis/nascaR.data/actions/workflows/weekly-nascar-update.yml/badge.svg)](https://github.com/kyleGrealis/nascaR.data/actions/workflows/weekly-nascar-update.yml)


----

**nascaR.data** provides historical race results from NASCAR's top three series: Cup (1949-present), NXS (1982-present), and Trucks (1995-present). Explore driver, team, and manufacturer performance in a race-by-race, season, or career format. This data has been expertly curated and scraped with permission from [DriverAverages.com](https://www.driveraverages.com).

> **Note for v3.0.0:** The second-tier series identifier has changed from
> `"xfinity"` to `"nxs"`. See `vignette("migrating-to-nxs")` for details.

## Installation

Install from CRAN:
```r
install.packages("nascaR.data")
```

Or install the development version from GitHub:
```r
remotes::install_github("kyleGrealis/nascaR.data")
```

**Note:** This package requires the `arrow` package for reading parquet data from cloud storage. It will be installed automatically.

## Loading Data

All data is served from cloud storage. Use `load_series()` to access race results:

```r
library(nascaR.data)

cup <- load_series("cup")
nxs <- load_series("nxs")
truck <- load_series("truck")
```

Data is cached locally after the first download for instant access. Use `refresh = TRUE` to force a fresh download, or `clear_cache()` to wipe the cache.

Data is updated automatically every Monday during the racing season (February through November).

---

## In the Pits

NASCAR is one of the top-tier racing sports in North America and competes against Formula-1 and IndyCar for the top viewership spot. Approximately 3.22 million people watch a race on any given weekend throughout the season. The nascaR.data package is the result of wanting to share a passion for the sport and provide an option to the typical go-to packages when learning new data cleaning & visualization tools.

## Data Structure

Three series are available via `load_series()`:

* `load_series("cup")`: NASCAR Cup Series race results (1949-present)
* `load_series("nxs")`: NASCAR NXS (second-tier) race results (1982-present)
* `load_series("truck")`: NASCAR Craftsman Truck Series results (1995-present)

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

### Driver, Team, & Manufacturer Data

Use the suite of `get_*_info()` functions to examine specific performance results on a race-by-race, season, or career level.

```r
# Career results across all series
get_driver_info("Christopher Bell")
```

```
Driver: Christopher Bell
# A tibble: 3 × 8
  Series Seasons `Career Races`  Wins `Best Finish` `Avg Finish` `Laps Raced` `Laps Led`
  <chr>    <int>          <int> <dbl>         <int>        <dbl>        <int>      <int>
1 Cup          6            216    13             1         14.5        54607       2717
2 NXS          7             81    19             1         10.3        13092       3272
3 Truck        7             58     7             1          8.4         8213       1246
```

```r
# Season results across all series
get_driver_info("Christopher Bell", type = "season")
```

```
Driver: Christopher Bell
# A tibble: 20 × 8
   Series Season Races  Wins `Best Finish` `Avg Finish` `Laps Raced` `Laps Led`
   <chr>   <int> <int> <dbl>         <int>        <dbl>        <int>      <int>
 1 Cup      2020    36     0             3         20.2         9428         18
 2 Cup      2021    36     1             1         15.8         8911        100
 3 Cup      2022    36     3             1         13.8         8816        573
 4 Cup      2023    36     2             1         12.9         8868        599
 5 Cup      2024    35     3             1         12.8         9298       1145
 6 Cup      2025    35     4             1         11.2         9286        282
 7 NXS      2017     8     1             1         11.5         1423        156
 8 NXS      2018    32     7             1         11.1         5112        759
 9 NXS      2019    31     8             1          9.1         5574       2005
10 NXS      2021     2     1             1          3.5          300        174
11 NXS      2022     1     0             7          7            147          0
12 NXS      2024     2     2             1          1            353        151
13 NXS      2025     2     0            25         32            183         27
14 Truck    2015     7     1             1         11.9         1018        111
15 Truck    2016    23     1             1          9.5         3237        197
16 Truck    2017    23     5             1          5.7         3247        875
17 Truck    2018     1     0            28         28            184         31
18 Truck    2023     2     0             4         10            312          0
19 Truck    2024     1     0             5          5            134          2
20 Truck    2025     1     0             4          4             81         30
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
| `load_series()` | Load race data from cloud storage (with caching) |
| `clear_cache()` | Clear cached data from memory and disk |
| `get_driver_info()` | Obtain race, season, or career performance results |
| `get_team_info()` | Team-specific race, season, or career results (i.e., Petty Enterprises) |
| `get_manufacturer_info()` | Ford, Chevy, Toyota, Dodge, even Studebaker |

## Contributing

We're open to suggestions! If you have ideas for new features, please open an issue on our GitHub repository.

----

## License

[GNU General Public License (Version 3)](https://choosealicense.com/licenses/gpl-3.0/)

---

Developed by [Kyle Grealis](https://github.com/kyleGrealis)
