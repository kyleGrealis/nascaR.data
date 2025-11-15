# Enhanced Get Manufacturer Info with Smart Matching

Enhanced Get Manufacturer Info with Smart Matching

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

  Character string of manufacturer name to search for

- series:

  Either character string ("cup", "xfinity", "truck", "all") or data
  frame

- type:

  Character string specifying return type ("summary", "season", "all")

- interactive:

  Logical. Is the session interactive?

## Value

Tibble with manufacturer statistics or NULL if no exact match

## Examples

``` r
if (FALSE) { # \dontrun{
# Get Toyota career summary
get_manufacturer_info("Toyota")

# Handle misspelling - will prompt for selection
get_manufacturer_info("toyoda")
# Found 1 manufacturers matching 'toyoda':
#  1 - Toyota
# Select manufacturer number: 1
# Manufacturer: Toyota
# Returns summary table

# Get season-by-season data for Cup series only
get_manufacturer_info("Toyota", series = "cup", type = "season")
} # }
```
