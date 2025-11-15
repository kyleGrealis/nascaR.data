# Find Team Matches

Find Team Matches

## Usage

``` r
find_team(search_term, data = NULL, max_results = 5, interactive = TRUE)
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

Character vector of matching team names

## Examples

``` r
# Find exact match
find_team("Joe Gibbs Racing")
#> [1] "Joe Gibbs Racing"

# Find partial matches
find_team("gibbs")
#> Found 4 teams matching 'gibbs':
#> To get specific team data, use exact name from:
#>   1 - Shorty Gibbs (Owner)
#>   2 - Don Gibbs Racing
#>   3 - Joe Gibbs Racing
#>   4 - Peter Gibbons (Owner)
#> 
#> [1] "Shorty Gibbs (Owner)"  "Don Gibbs Racing"      "Joe Gibbs Racing"     
#> [4] "Peter Gibbons (Owner)"

# Non-interactive mode for scripts
find_team("hendrick", interactive = FALSE)
#> Found 2 teams matching 'hendrick':
#> To get specific team data, use exact name from:
#>   1 - Hendrick Motorsports
#>   2 - Larry Hedrick Motorsports
#> 
#> [1] "Hendrick Motorsports"      "Larry Hedrick Motorsports"
```
