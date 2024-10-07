library(tidyverse)

# First write a function to fuzzy find a owner.
# Example: "Jack Rush" or "Jack Rousche" would get "Jack Roush"
find_similar_owner <- function(name) {
  name <- str_to_lower(name)
  owner_list <- cup_series |> 
    mutate(owner = str_to_lower(owner)) |> 
    pull(owner)
  distances <- stringdist::stringdist(name, owner_list, method = 'lv')
  closest_match <- owner_list[which.min(distances)]
  return(str_to_title(closest_match))
}

# Aggregate owner information
# type: career, season, summary
filter_owner_info <- function(the_owner, type = 'summary') {

  race_results <- 
    cup_series |>
    filter(owner == the_owner)

  if (type == 'career') {
    owner_table <<- race_results
    glue::glue(
      "{the_owner}'s results have been saved to the global environment as `owner_table`."
    )
  } else if (type == 'season') {
    owner_table <- 
      race_results |>
      group_by(season) |>
      summarize(
        total_drivers = n_distinct(driver),
        season_races = n_distinct(race_name),
        best_finish = min(finish),
        average_finish = round(mean(finish, na.rm = TRUE), 1),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(owner_table)
  } else if (type == 'summary') {
    owner_table <- 
      race_results |>
      summarize(
        total_drivers = n_distinct(driver),
        number_of_seasons = n_distinct(season),
        career_races = nrow(race_results),
        best_finish = min(finish),
        average_finish = round(mean(finish, na.rm = TRUE), 1),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(owner_table)
  }
  
  # return(owner_table)
}

get_owner_info <- function(name, type) {
  if (find_similar_owner(name) != name) {
    # Get user input if the entered name does not match available owners
    answer <- readline(
      glue::glue(
        '\n\nI was unable to find "{name}" but found {find_similar_owner(name)}. Is this who you meant? [y/n] '
      )
    )
    if (str_to_lower(answer) %in% c('y', 'yes', 'ye', 'yeah', 'yup')) {
      name <- find_similar_owner(name)
      message(name)
      filter_owner_info(name, type = type)
    } else {
      message('\nPlease check the spelling & try your search function again.')
    }
  } else {
    # this will return the list of the owner information
    message(name)
    filter_owner_info(name, type = type)
  }
}

get_owner_info('jack rush', type = 'season')
get_owner_info('jack rush', type = 'career')
get_owner_info('jack rush', type = 'summary')
