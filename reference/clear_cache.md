# Clear Cached NASCAR Data

Clears the in-memory cache so the next call to
[`load_series()`](https://www.kylegrealis.com/nascaR.data/reference/load_series.md)
will re-download from cloud storage. Also removes any leftover disk
cache from previous package versions.

## Usage

``` r
clear_cache()
```

## Value

Invisibly returns `NULL`.

## See also

[`load_series()`](https://www.kylegrealis.com/nascaR.data/reference/load_series.md)
for data access.

## Examples

``` r
if (FALSE) { # \dontrun{
# Clear in-memory cache
clear_cache()

# Next call downloads fresh data
cup <- load_series("cup")
} # }
```
