# Clear Cached NASCAR Data

Removes all cached NASCAR series data from both memory and disk. The
next call to
[`load_series()`](https://www.kylegrealis.com/nascaR.data/reference/load_series.md)
will re-download data from cloud storage.

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
# Clear all cached data
clear_cache()

# Force fresh download
cup <- load_series("cup")
} # }
```
