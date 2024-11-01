#' Find closest matching team name
#'
#' @param df A tibble containing NASCAR race data
#' @param the_team Character string of team name to search for
#' @return Character string of the matched team name
#' @keywords internal
#' @noRd
find_team <- function(df, the_team) {
  # Create a list of teams
  team_list <- df |> 
    mutate(Team = str_to_lower(Team)) |> 
    pull(Team)
 
  # Calculate distance of entered name and those in list of teams
  entered_name <- str_to_lower(the_team)
  distances <- stringdist::stringdist(entered_name, team_list, method = 'lv')
  closest_match <- team_list[which.min(distances)]
 
  # Get user input if the entered name does not match available teams
  if (entered_name != str_to_lower(closest_match)) {
    entered_name <- str_to_title(entered_name)
    found_name <- str_to_title(closest_match)

    # Feedback prompt:
    answer <- str_to_lower(readline(
      glue::glue(
        '\n\nI was unable to find "{entered_name}" but found {found_name}. \nIs this who you meant? [y/n] '
      )
    ))
    # User response:
    if (answer %in% c('y', 'yes', 'ye', 'yeah', 'yup')) {
      return(closest_match)
    } else {
      stop('\nPlease check the spelling & try your search function again.')
    }
  }
  return(closest_match)
}

#' Filter race data for a specific team
#'
#' @param race_data A tibble containing NASCAR race data
#' @param the_team Character string of team name
#' @return A tibble filtered for the specified team
#' @keywords internal
#' @noRd
filter_team_data <- function(race_data, the_team) {
  race_results <- 
    race_data |>
    filter(Team == str_to_title(the_team))
  return(race_results)  
}

#' Get NASCAR team statistics
#'
#' Retrieves and summarizes NASCAR race statistics for a specified team across
#' different racing series. The function provides flexibility in viewing career
#' summaries, season-by-season breakdowns, or complete race-by-race data.
#'
#' @param team Character string specifying an team name (case-insensitive, fuzzy matching
#'   available)
#' @param series Character string specifying the racing series to analyze. Must be
#'   one of 'all' (default), 'cup', 'xfinity', or 'truck'
#' @param type Character string specifying the type of summary to return. Must be
#'   one of:
#'   * 'summary' (default): Career statistics grouped by series
#'   * 'season': Season-by-season statistics for each series
#'   * 'all': Complete race-by-race data
#'
#' @return A tibble containing team statistics based on the specified type:
#'   * For type = 'summary': Career statistics grouped by series
#'   * For type = 'season': Season-by-season breakdown
#'   * For type = 'all': Complete race-by-race data
#'
#' @export
#'
#' @examples
#' # Get career summary for Joe Gibbs Racing across all series
#' get_team_info("Joe Gibbs Racing")
#'
#' # Get Cup series statistics only
#' get_team_info("Joe Gibbs Racing", series = "cup")
#'
#' # Get season-by-season breakdown for Truck series
#' get_team_info("Kyle Busch Racing", series = "truck", type = "season")

get_team_info <- function(team, series = 'all', type = 'summary') {

  # Filter all race data for selected series
  race_series <- selected_series_data(the_series = series)
  # Find team name
  the_team <- find_team(df = race_series, the_team = team)
  # Get all team's data
  race_results <- filter_team_data(race_data = race_series, the_team = the_team)
 
  message(str_to_title(the_team))
 
  if (type == 'season') {
    team_table <- 
      race_results |>
      group_by(Series, Season) |>
      summarize(
        Races = n_distinct(Name),
        `# of Drivers` = n_distinct(Driver),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish, na.rm = TRUE),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE)
      )
      return(team_table)
  } else if (type == 'summary') {
    team_table <- 
      race_results |>
      group_by(Series) |>
      summarize(
        Seasons = n_distinct(Season),
        `Career Races` = n(),
        `# of Drivers` = n_distinct(Driver),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish, na.rm = TRUE),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE)
      )
      return(team_table)
  } else if (type == 'all') {  
    # table of career across all series
    return(race_results)
  } else {
    stop(paste('Unknown `type =', type, '` entered. Please try again.'))
  }
}