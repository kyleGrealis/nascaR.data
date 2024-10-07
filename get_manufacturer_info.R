library(tidyverse)

# First write a function to fuzzy find a manufacturer.
# Example: "Jimmy Johnson" or "Jimmi Jahnsen" would get "Jimmie Johnson"
find_similar_manufacturer <- function(name) {
  name <- str_to_lower(name)
  manufacturer_list <- cup_series |> 
    mutate(manufacturer = str_to_lower(manufacturer)) |> 
    pull(manufacturer)
  distances <- stringdist::stringdist(name, manufacturer_list, method = 'lv')
  closest_match <- manufacturer_list[which.min(distances)]
  return(str_to_title(closest_match))
}

# Aggregate manufacturer information
# type: career, season, summary
filter_manufacturer_info <- function(the_manufacturer, type) {

  race_results <- 
    cup_series |>
    filter(manufacturer == the_manufacturer)

  if (type == 'career') {
    manufacturer_table <<- race_results
    glue::glue(
      "{the_manufacturer}'s results have been saved to the global environment as `manufacturer_table`."
    )
  } else if (type == 'season') {
    manufacturer_table <- 
      race_results |>
      group_by(season) |>
      summarize(
        season_races = n_distinct(race_name),
        number_of_drivers = n_distinct(driver),
        best_finish = min(finish),
        average_finish = round(mean(finish, na.rm = TRUE), 1),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(manufacturer_table)
  } else if (type == 'summary') {
    manufacturer_table <- 
      race_results |>
      summarize(
        number_of_seasons = n_distinct(season),
        number_of_drivers = n_distinct(driver),
        total_races = nrow(race_results),
        best_finish = min(finish),
        average_finish = round(mean(finish, na.rm = TRUE), 1),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(manufacturer_table)
  }
  
  # return(manufacturer_table)
}

get_manufacturer_info <- function(name, type = 'summary') {
  name <- str_to_title(name)
  if (find_similar_manufacturer(name) != name) {
    # Get user input if the entered name does not match available manufacturers
    answer <- readline(
      glue::glue(
        '\n\nI was unable to find "{name}" but found {find_similar_manufacturer(name)}. \nIs this what you meant? [y/n] '
      )
    )
    if (str_to_lower(answer) %in% c('y', 'yes', 'ye', 'yeah', 'yup')) {
      name <- find_similar_manufacturer(name)
      message(name)
      filter_manufacturer_info(name, type = type)
    } else {
      message('\nPlease check the spelling & try your search function again.')
    }
  } else {
    # this will return the list of the manufacturer information
    message(name)
    filter_manufacturer_info(name, type = type)
  }
}

# get_manufacturer_info('Toyota', type = 'season')
# get_manufacturer_info('Toyota', type = 'career')
# get_manufacturer_info('toyata', type = 'summary')
# get_manufacturer_info('Chevrolet', type = 'summary')
