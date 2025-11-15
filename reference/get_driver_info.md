# Enhanced Get Driver Info with Smart Matching

Enhanced Get Driver Info with Smart Matching

## Usage

``` r
get_driver_info(driver, series = "all", type = "summary", interactive = TRUE)
```

## Arguments

- driver:

  Character string of driver name to search for

- series:

  Either character string ("cup", "xfinity", "truck", "all") or data
  frame

- type:

  Character string specifying return type ("summary", "season", "all")

- interactive:

  Logical. Is the session interactive?

## Value

Tibble with driver statistics or NULL if no exact match

## Examples

``` r
if (FALSE) { # \dontrun{
# Get Christopher Bell's career summary
get_driver_info("Christopher Bell")

# Handle misspelling - will prompt for selection
get_driver_info("cristopher bell")
# Found 1 drivers matching 'cristopher bell':
#  1 - Christopher Bell
# Select driver number: 1
# Driver: Christopher Bell
# Returns summary table

# Get season-by-season data for Cup series only
get_driver_info("Christopher Bell", series = "cup", type = "season")
} # }
```
