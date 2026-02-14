# Get Team Info with Smart Matching

Search for a team by name and return performance statistics. Supports
partial names, typos, and case-insensitive input via the built-in fuzzy
matching engine.

## Usage

``` r
get_team_info(team, series = "all", type = "summary", interactive = TRUE)
```

## Arguments

- team:

  Character string of the team name to search for. Supports partial
  names and common misspellings (e.g., `"gibbs"` finds Joe Gibbs
  Racing).

- series:

  Character string (`"cup"`, `"nxs"`, `"truck"`, `"all"`) or a
  pre-loaded data frame. Default is `"all"`.

- type:

  Character string specifying the return format:

  `"summary"`

  :   Career totals grouped by series (Seasons, Career Races, \# of
      Drivers, Wins, Best Finish, Avg Finish, Laps Raced, Laps Led).

  `"season"`

  :   Season-by-season breakdown (Races, \# of Drivers, Wins, Best
      Finish, Avg Finish, Laps Raced, Laps Led).

  `"all"`

  :   Complete race-by-race results.

- interactive:

  Logical. When `TRUE` (default) and the R session is interactive,
  prompts the user to select from multiple matches. When `FALSE`,
  silently uses the first match.

## Value

A tibble of team statistics (format depends on `type`), or
`invisible(NULL)` if no match is found.

## See also

[`get_driver_info()`](https://www.kylegrealis.com/nascaR.data/reference/get_driver_info.md),
[`get_manufacturer_info()`](https://www.kylegrealis.com/nascaR.data/reference/get_manufacturer_info.md),
[`load_series()`](https://www.kylegrealis.com/nascaR.data/reference/load_series.md),
[series_data](https://www.kylegrealis.com/nascaR.data/reference/series_data.md)

## Examples

``` r
# \donttest{
# Career summary across all series
get_team_info("Joe Gibbs Racing")
#> Team: Joe Gibbs Racing
#> # A tibble: 3 × 9
#>   Series Seasons `Career Races` `# of Drivers`  Wins `Best Finish` `Avg Finish`
#>   <chr>    <int>          <int>          <int> <dbl>         <int>        <dbl>
#> 1 Cup         34           3315             29   227             1         14.4
#> 2 NXS         29           2340             78   221             1         12.8
#> 3 Truck        4             66              3     0             2         16.5
#> # ℹ 2 more variables: `Laps Raced` <int>, `Laps Led` <int>

# Season-by-season Cup data
get_team_info(
  "Joe Gibbs Racing",
  series = "cup",
  type = "season"
)
#> Team: Joe Gibbs Racing
#> # A tibble: 34 × 9
#>    Series Season Races `# of Drivers`  Wins `Best Finish` `Avg Finish`
#>    <chr>   <int> <int>          <int> <dbl>         <int>        <dbl>
#>  1 Cup      1992    28              1     0             2         17.8
#>  2 Cup      1993    29              1     1             1         12.4
#>  3 Cup      1994    28              1     1             1         18.7
#>  4 Cup      1995    28              1     3             1         16.3
#>  5 Cup      1996    27              1     1             1         17.4
#>  6 Cup      1997    31              1     1             1         13.7
#>  7 Cup      1998    32              1     2             1         14.2
#>  8 Cup      1999    34              2     8             1          9.6
#>  9 Cup      2000    34              2    10             1          9.9
#> 10 Cup      2001    36              2     5             1         13.3
#> # ℹ 24 more rows
#> # ℹ 2 more variables: `Laps Raced` <int>, `Laps Led` <int>
# }
```
