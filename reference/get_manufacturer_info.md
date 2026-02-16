# Get Manufacturer Info with Smart Matching

Search for a manufacturer by name and return performance statistics.
Uses fuzzy matching to handle partial names, typos, and case-insensitive
searches.

## Usage

``` r
get_manufacturer_info(
  manufacturer,
  series = "all",
  type = "summary",
  interactive = TRUE
)
```

## Arguments

- manufacturer:

  Character string of the manufacturer name to search for.

- series:

  Character string (`"cup"`, `"nxs"`, `"truck"`, `"all"`) or a
  pre-loaded data frame. Default is `"all"`.

- type:

  Character string specifying the return format:

  `"summary"`

  :   Career totals grouped by series (Seasons, Races, Wins, Best
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

A tibble of manufacturer statistics (format depends on `type`), or
`invisible(NULL)` if no match is found.

## See also

[`get_driver_info()`](https://www.kylegrealis.com/nascaR.data/reference/get_driver_info.md),
[`get_team_info()`](https://www.kylegrealis.com/nascaR.data/reference/get_team_info.md),
[`load_series()`](https://www.kylegrealis.com/nascaR.data/reference/load_series.md),
[series_data](https://www.kylegrealis.com/nascaR.data/reference/series_data.md)

## Examples

``` r
# \donttest{
# Career summary across all series
get_manufacturer_info("Toyota")
#> Manufacturer: Toyota
#> # A tibble: 3 × 8
#>   Series Seasons Races  Wins `Best Finish` `Avg Finish` `Laps Raced` `Laps Led`
#>   <chr>    <int> <int> <dbl>         <int>        <dbl>        <int>      <int>
#> 1 Cup         20  5935   204             1         21.3      1496985      61468
#> 2 NXS         20  5056   218             1         19         767375      41075
#> 3 Truck       23  5155   248             1         14.9       729239      35709

# Season-by-season Cup data
get_manufacturer_info(
  "Toyota",
  series = "cup",
  type = "season"
)
#> Manufacturer: Toyota
#> # A tibble: 20 × 8
#>    Series Season Races  Wins `Best Finish` `Avg Finish` `Laps Raced` `Laps Led`
#>    <chr>   <int> <int> <dbl>         <int>        <dbl>        <int>      <int>
#>  1 Cup      2007    36     0             3         29          42296        166
#>  2 Cup      2008    36    10             1         23         100817       3472
#>  3 Cup      2009    36    11             1         25.4       101875       2857
#>  4 Cup      2010    35    12             1         25.6       103628       2890
#>  5 Cup      2011    36     6             1         24.5        94997       2497
#>  6 Cup      2012    36    10             1         22.7        99544       4070
#>  7 Cup      2013    35    14             1         23.2       107019       4223
#>  8 Cup      2014    36     2             1         24.2        90007       1513
#>  9 Cup      2015    36    14             1         22.2        86597       2597
#> 10 Cup      2016    36    16             1         18.6        75247       5592
#> 11 Cup      2017    36    16             1         18.9        84271       5757
#> 12 Cup      2018    35    13             1         18.6        68520       2999
#> 13 Cup      2019    35    19             1         15.3        56729       4199
#> 14 Cup      2020    36     9             1         18.9        65671       2652
#> 15 Cup      2021    36    10             1         16.1        49026       2863
#> 16 Cup      2022    36     8             1         16.8        52427       2730
#> 17 Cup      2023    36    10             1         14.8        54220       3365
#> 18 Cup      2024    35     9             1         17.8        78058       3832
#> 19 Cup      2025    35    14             1         17.4        83862       3091
#> 20 Cup      2026     1     1             1         22.5         2174        103
# }
```
