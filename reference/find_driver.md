# Find Driver Matches

Find Driver Matches

## Usage

``` r
find_driver(search_term, data = NULL, max_results = 5, interactive = TRUE)
```

## Arguments

- search_term:

  Character string to search for

- data:

  Tibble containing NASCAR race data

- max_results:

  Maximum number of matches to return

- interactive:

  Logical. Is the session interactive?

## Value

Character vector of matching driver names

## Examples

``` r
# Find exact match
find_driver("Christopher Bell")
#> [1] "Christopher Bell"

# Find partial matches
find_driver("bell")
#> Found 5 drivers matching 'bell':
#> To get specific driver data, use exact name from:
#>   1 - Wally Campbell
#>   2 - Joe Bellinato
#>   3 - Phillips Bell
#>   4 - Joe Bell
#>   5 - Gordon Campbell
#> 
#> [1] "Wally Campbell"  "Joe Bellinato"   "Phillips Bell"   "Joe Bell"       
#> [5] "Gordon Campbell"

# Non-interactive mode for scripts
find_driver("kyle", interactive = FALSE)
#> Found 5 drivers matching 'kyle':
#> To get specific driver data, use exact name from:
#>   1 - Kyle Petty
#>   2 - Kyle Busch
#>   3 - Kyle Larson
#>   4 - Kyle Fowler
#>   5 - Kyle Weatherman
#> 
#> [1] "Kyle Petty"      "Kyle Busch"      "Kyle Larson"     "Kyle Fowler"    
#> [5] "Kyle Weatherman"
```
