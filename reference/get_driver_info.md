# Get Driver Info with Smart Matching

Search for a driver by name and return career statistics. Supports
partial names, typos, and case-insensitive input via the built-in fuzzy
matching engine.

## Usage

``` r
get_driver_info(driver, series = "all", type = "summary", interactive = TRUE)
```

## Arguments

- driver:

  Character string of the driver name to search for. Supports partial
  names and common misspellings (e.g., `"earnhart"` finds Earnhardt).

- series:

  Character string (`"cup"`, `"nxs"`, `"truck"`, `"all"`) or a
  pre-loaded data frame. Default is `"all"`.

- type:

  Character string specifying the return format:

  `"summary"`

  :   Career totals grouped by series (Seasons, Career Races, Wins, Best
      Finish, Avg Finish, Laps Raced, Laps Led).

  `"season"`

  :   Season-by-season breakdown (Races, Wins, Best Finish, Avg Finish,
      Laps Raced, Laps Led).

  `"all"`

  :   Complete race-by-race results.

- interactive:

  Logical. When `TRUE` (default) and the R session is interactive,
  prompts the user to select from multiple matches. When `FALSE`,
  silently uses the first match.

## Value

A tibble of driver statistics (format depends on `type`), or
`invisible(NULL)` if no match is found.

## See also

[`get_team_info()`](https://www.kylegrealis.com/nascaR.data/reference/get_team_info.md),
[`get_manufacturer_info()`](https://www.kylegrealis.com/nascaR.data/reference/get_manufacturer_info.md),
[`load_series()`](https://www.kylegrealis.com/nascaR.data/reference/load_series.md),
[series_data](https://www.kylegrealis.com/nascaR.data/reference/series_data.md)

## Examples

``` r
# \donttest{
# Career summary across all series
get_driver_info("Christopher Bell")
#> Driver: Christopher Bell
#> # A tibble: 3 × 8
#>   Series Seasons `Career Races`  Wins `Best Finish` `Avg Finish` `Laps Raced`
#>   <chr>    <int>          <int> <dbl>         <int>        <dbl>        <int>
#> 1 Cup          7            217    13             1         14.6        54798
#> 2 NXS          7             81    19             1         10.3        13092
#> 3 Truck        7             58     7             1          8.4         8213
#> # ℹ 1 more variable: `Laps Led` <int>

# Season-by-season Cup data
get_driver_info(
  "Christopher Bell",
  series = "cup",
  type = "season"
)
#> Driver: Christopher Bell
#> # A tibble: 7 × 8
#>   Series Season Races  Wins `Best Finish` `Avg Finish` `Laps Raced` `Laps Led`
#>   <chr>   <int> <int> <dbl>         <int>        <dbl>        <int>      <int>
#> 1 Cup      2020    36     0             3         20.2         9428         18
#> 2 Cup      2021    36     1             1         15.8         8911        100
#> 3 Cup      2022    36     3             1         13.8         8816        573
#> 4 Cup      2023    36     2             1         12.9         8868        599
#> 5 Cup      2024    35     3             1         12.8         9298       1145
#> 6 Cup      2025    35     4             1         11.2         9286        282
#> 7 Cup      2026     1     0            35         35            191          9
# }
```
