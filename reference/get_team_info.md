# Enhanced Get Team Info with Smart Matching

Enhanced Get Team Info with Smart Matching

## Usage

``` r
get_team_info(team, series = "all", type = "summary", interactive = TRUE)
```

## Arguments

- team:

  Character string of team name to search for

- series:

  Either character string ("cup", "xfinity", "truck", "all") or data
  frame

- type:

  Character string specifying return type ("summary", "season", "all")

- interactive:

  Logical. Is the session interactive?

## Value

Tibble with team statistics or NULL if no exact match

## Examples

``` r
if (FALSE) { # \dontrun{
# Get Joe Gibbs Racing career summary
get_team_info("Joe Gibbs Racing")

# Handle partial name - will prompt for selection
get_team_info("joe gib racing")
# Found 1 teams matching 'joe gib racing':
#  1 - Joe Gibbs Racing
# Select team number: 1
# Team: Joe Gibbs Racing
# Returns summary table

# Get season-by-season data for Cup series only
get_team_info("Joe Gibbs Racing", series = "cup", type = "season")
} # }
```
