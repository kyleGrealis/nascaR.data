# Load NASCAR Series Data

Downloads NASCAR series data from Cloudflare R2 as a parquet file. Data
is cached in memory for the current R session so repeated calls are
instant. Each new R session downloads fresh data, ensuring you always
have the latest results.

## Usage

``` r
load_series(series = c("cup", "nxs", "truck"), refresh = FALSE)
```

## Arguments

- series:

  Character. The series to load. One of `"cup"`, `"nxs"`, or `"truck"`.

- refresh:

  Logical. If `TRUE`, bypass the in-memory cache and re-download from
  cloud storage. Default is `FALSE`.

## Value

A data frame with 21 columns of race results: Season, Race, Track, Name,
Length, Surface, Finish, Start, Car, Driver, Team, Make, Pts, Laps, Led,
Status, S1, S2, S3, Rating, and Win.

## Details

### Why "nxs"?

NASCAR's NXS uses the sponsor-neutral identifier `"nxs"` rather than a
sponsor name. The series has been sponsored by Busch (1984-2007),
Nationwide (2008-2014), Xfinity (2015-2025), and O'Reilly Auto Parts
(2026-present). Using `"nxs"` keeps the identifier stable across sponsor
changes.

### Caching

Data is cached in memory for the current R session. Repeated calls
return instantly without re-downloading. Starting a new R session always
fetches the latest data from R2.

Use `refresh = TRUE` to force a re-download within a session, or
[`clear_cache()`](https://www.kylegrealis.com/nascaR.data/reference/clear_cache.md)
to reset the in-memory cache.

## See also

[series_data](https://www.kylegrealis.com/nascaR.data/reference/series_data.md)
for column descriptions,
[`clear_cache()`](https://www.kylegrealis.com/nascaR.data/reference/clear_cache.md)
for cache management,
[`get_driver_info()`](https://www.kylegrealis.com/nascaR.data/reference/get_driver_info.md)
for driver statistics.

## Examples

``` r
# \donttest{
# Load Cup Series data (downloads on first call, cached after)
cup <- load_series("cup")

# Load NXS data
nxs <- load_series("nxs")

# Load Truck Series data
truck <- load_series("truck")

# Force re-download from cloud storage
cup <- load_series("cup", refresh = TRUE)
# }
```
