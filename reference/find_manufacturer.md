# Find Manufacturer Matches

Find Manufacturer Matches

## Usage

``` r
find_manufacturer(
  search_term,
  data = NULL,
  max_results = 5,
  interactive = TRUE
)
```

## Arguments

- search_term:

  Character string to search for

- data:

  Tibble containing NASCAR race data or series specification

- max_results:

  Maximum number of matches to return

- interactive:

  Logical. Is the session interactive?

## Value

Character vector of matching manufacturer names

## Examples

``` r
# Find exact match
find_manufacturer("Toyota")
#> [1] "Toyota"

# Find with common alias
find_manufacturer("chevy")
#> [1] "Chevrolet"

# Non-interactive mode for scripts
find_manufacturer("ford", interactive = FALSE)
#> [1] "Ford"
```
