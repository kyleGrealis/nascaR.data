library(tidyverse)

########################
# for testing
load('data/rvest/cup_series.rda')
load('data/rvest/xfinity_series.rda')
load('data/rvest/truck_series.rda')

# Function to get the driver information

# First write a function to fuzzy find a driver.
# Example: "Jimmy Johnson" or "Jimmi Jahnsen" would get "Jimmie Johnson"
find_similar_driver <- function(name) {
  name <- str_to_lower(name)
  driver_list <- cup_series |> 
    mutate(driver = str_to_lower(driver)) |> 
    pull(driver)
  distances <- stringdist::stringdist(name, driver_list, method = 'lv')
  closest_match <- driver_list[which.min(distances)]
  return(str_to_title(closest_match))
}


# Aggregate driver information
# type: career, season, summary
get_driver_info <- function(the_driver, type = 'summary') {

  race_results <- 
    cup_series |>
    filter(driver == the_driver)

  if (type == 'career') {
    driver_table <<- race_results
    glue::glue(
      "{the_driver}'s results have been saved to the global environment as `driver_table`."
    )
  } else if (type == 'season') {
    driver_table <- 
      race_results |>
      group_by(season) |>
      summarize(
        season_races = nrow(race_results),
        best_finish = min(finish),
        average_finish = mean(finish, na.rm = TRUE),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(driver_table)
  } else if (type == 'summary') {
    driver_table <- 
      race_results |>
      summarize(
        number_of_seasons = n_distinct(season),
        career_races = nrow(race_results),
        best_finish = min(finish),
        average_finish = mean(finish, na.rm = TRUE),
        laps_raced = sum(laps, na.rm = TRUE),
        laps_led = sum(led, na.rm = TRUE),
        total_money = scales::dollar(sum(money, na.rm = TRUE))
      )
      return(driver_table)
  }
  
  # return(driver_table)
}

get_driver_info(name)
get_driver_info(name, type = 'season')
get_driver_info(name, type = 'career')



# Get user input if the entered name does not match available drivers
name <- 'Jeff Garen'
name <- 'Jeff Gordon'
type <- 'career'
type <- 'season'
type <- 'summary'
if (find_similar_driver(name) != name) {
  answer <- readline(
    glue::glue(
      '\n\nI was able to find: {find_similar_driver(name)}. Is this who you meant? [y/n] '
    )
  )
  if (str_to_lower(answer) %in% c('y', 'yes', 'ye', 'yeah', 'yup')) {
    message('Great!')
    name <- find_similar_driver(name)
    get_driver_info(name, type = type)
  } else {
    message('\nPlease check the spelling & try your search function again.')
  }
} else {
  # this will return the list of the driver information
  message(name)
  get_driver_info(name, type = type)
}
