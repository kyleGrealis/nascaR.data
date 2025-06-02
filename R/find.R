#' Smart Matching Engine - The Heart of All Fuzzy Finding
#'
#' @param search_term Character string to search for
#' @param data_column Character vector of valid options to search within
#' @param max_results Maximum number of matches to return (default: 5)
#' @return Character vector of best matches, ranked by relevance
#' @keywords internal
#' @noRd
smart_match <- function(search_term, data_column, max_results = 5) {
  # Handle missing inputs
  if (is.null(search_term) || is.na(search_term) || search_term == "") {
    return(character(0))
  }

  # Remove NA values from data column
  data_column <- data_column[!is.na(data_column)]
  data_column <- data_column[data_column != ""]

  if (length(data_column) == 0) {
    return(character(0))
  }

  # Clean inputs
  search_clean <- str_to_lower(str_trim(search_term))
  options_clean <- str_to_lower(str_trim(data_column))

  # Remove duplicates while preserving original case
  unique_options <- data_column[!duplicated(options_clean)]
  unique_clean <- str_to_lower(str_trim(unique_options))

  # 1. EXACT MATCH (highest priority)
  exact_match <- which(unique_clean == search_clean)
  if (length(exact_match) > 0) {
    return(unique_options[exact_match[1]])
  }

  # 2. STARTS WITH (very high priority)
  starts_with <- which(str_starts(unique_clean, search_clean))

  # 3. CONTAINS SEARCH TERM (high priority)
  contains_term <- which(str_detect(unique_clean, fixed(search_clean)))

  # 4. WORD BOUNDARY MATCHES (medium priority)
  # Split search term and check each word
  search_words <- str_split(search_clean, "\\s+")[[1]]
  word_matches <- c()

  if (length(search_words) > 1) {
    # Multi-word search: check if all words appear
    for (i in seq_along(unique_clean)) {
      option_words <- str_split(unique_clean[i], "\\s+")[[1]]
      if (all(search_words %in% option_words)) {
        word_matches <- c(word_matches, i)
      }
    }
  } else {
    # Single word: check if it matches any word in the options
    for (i in seq_along(unique_clean)) {
      option_words <- str_split(unique_clean[i], "\\s+")[[1]]
      if (search_clean %in% option_words) {
        word_matches <- c(word_matches, i)
      }
    }
  }

  # 5. PARTIAL WORD MATCHES (lower priority)
  # For cases like "bus" matching "Busch"
  partial_matches <- c()
  for (i in seq_along(unique_clean)) {
    option_words <- str_split(unique_clean[i], "\\s+")[[1]]
    for (word in option_words) {
      if (str_detect(word, search_clean) && nchar(search_clean) >= 3) {
        partial_matches <- c(partial_matches, i)
        break
      }
    }
  }

  # 6. TYPO/FUZZY MATCHING (lowest priority)
  # For cases like "earnhart" → "Earnhardt"
  fuzzy_matches <- c()
  if (nchar(search_clean) >= 4) {
    # Only for longer terms
    for (i in seq_along(unique_clean)) {
      # Simple character similarity for common typos
      option_words <- str_split(unique_clean[i], "\\s+")[[1]]
      for (word in option_words) {
        if (nchar(word) >= 4) {
          # Check if most characters match (allowing 1-2 typos)
          similarity <- 1 -
            (stringdist::stringdist(search_clean, word, method = "lv") /
              max(nchar(search_clean), nchar(word)))
          if (similarity >= 0.7) {
            # 70% similarity threshold
            fuzzy_matches <- c(fuzzy_matches, i)
            break
          }
        }
      }
    }
  }

  # Combine all matches with priority ranking
  all_matches <- c(
    starts_with,
    setdiff(contains_term, starts_with),
    setdiff(word_matches, c(starts_with, contains_term)),
    setdiff(partial_matches, c(starts_with, contains_term, word_matches)),
    setdiff(
      fuzzy_matches,
      c(starts_with, contains_term, word_matches, partial_matches)
    )
  )

  # Remove duplicates and limit results
  final_matches <- unique(all_matches)
  final_matches <- head(final_matches, max_results)

  if (length(final_matches) == 0) {
    return(character(0))
  }

  return(unique_options[final_matches])
}

#' Flexible Series Data Handler
#'
#' @param series Either a character string or data frame
#' @return Tibble with race data and Series column
#' @keywords internal
#' @noRd
get_series_data <- function(series) {
  if (is.character(series)) {
    # Handle string inputs with flexible matching
    series_clean <- str_to_lower(str_trim(series))

    # Smart series name detection
    if (str_detect(series_clean, "cup")) {
      return(selected_series_data("cup"))
    } else if (str_detect(series_clean, "xfinity")) {
      return(selected_series_data("xfinity"))
    } else if (str_detect(series_clean, "truck")) {
      return(selected_series_data("truck"))
    } else if (str_detect(series_clean, "all")) {
      return(selected_series_data("all"))
    } else {
      # Try the original function for exact matches
      tryCatch(
        {
          selected_series_data(series)
        },
        error = function(e) {
          stop(paste(
            "Unknown series:",
            series,
            "\nValid options: cup, xfinity, truck, all"
          ))
        }
      )
    }
  } else if (is.data.frame(series)) {
    # Handle direct data frame inputs
    race_data <- series

    # Add Series column if missing
    if (!"Series" %in% names(race_data)) {
      # Try to detect series from common patterns or just mark as "Custom"
      race_data$Series <- "Custom"
    }

    return(race_data)
  } else {
    stop("series must be either a character string or a data frame")
  }
}

#' Find Driver Matches
#'
#' @param search_term Character string to search for
#' @param data Tibble containing NASCAR race data
#' @param max_results Maximum number of matches to return
#' @return Character vector of matching driver names
#' @export
find_driver <- function(
  search_term,
  data = NULL,
  max_results = 5,
  interactive = TRUE
) {
  # Use all series data if none provided
  if (is.null(data)) {
    data <- selected_series_data("all")
  }

  # Handle flexible series input
  if (!is.data.frame(data)) {
    data <- get_series_data(data)
  }

  matches <- smart_match(search_term, data$Driver, max_results)

  if (length(matches) == 0) {
    message(paste("No drivers found matching:", search_term))
    return(invisible(character(0)))
  }

  if (length(matches) == 1) {
    return(matches)
  } else {
    if (interactive && base::interactive()) {
      # Interactive selection
      message(paste(
        "Found ",
        length(matches),
        " drivers matching '",
        search_term,
        "':",
        sep = ""
      ))
      for (i in seq_along(matches)) {
        message(paste(" ", i, "-", matches[i]))
      }

      choice <- readline(
        "Select driver number (or press Enter to return all): "
      )
      choice <- str_trim(choice)

      if (choice == "") {
        return(matches)
      }

      choice_num <- suppressWarnings(as.numeric(choice))
      if (
        !is.na(choice_num) && choice_num >= 1 && choice_num <= length(matches)
      ) {
        return(matches[choice_num])
      } else {
        message("Invalid selection. Returning all matches.")
        return(matches)
      }
    } else {
      # Non-interactive mode - return list with helpful message
      message(paste(
        "Found ",
        length(matches),
        " drivers matching '",
        search_term,
        "':",
        sep = ""
      ))
      message("To get specific driver data, use exact name from:")
      for (i in seq_along(matches)) {
        message(paste(" ", i, "-", matches[i]))
      }
      message("")
      return(matches)
    }
  }
}

#' Find Team Matches
#'
#' @param search_term Character string to search for
#' @param data Tibble containing NASCAR race data or series specification
#' @param max_results Maximum number of matches to return
#' @return Character vector of matching team names
#' @export
find_team <- function(
  search_term,
  data = NULL,
  max_results = 5,
  interactive = TRUE
) {
  # Use all series data if none provided
  if (is.null(data)) {
    data <- selected_series_data("all")
  }

  # Handle flexible series input
  if (!is.data.frame(data)) {
    data <- get_series_data(data)
  }

  matches <- smart_match(search_term, data$Team, max_results)

  if (length(matches) == 0) {
    message(paste("No teams found matching:", search_term))
    return(invisible(character(0)))
  }

  if (length(matches) == 1) {
    return(matches)
  } else {
    if (interactive && base::interactive()) {
      # Interactive selection
      message(paste(
        "Found ",
        length(matches),
        " teams matching '",
        search_term,
        "':",
        sep = ""
      ))
      for (i in seq_along(matches)) {
        message(paste(" ", i, "-", matches[i]))
      }

      choice <- readline("Select team number (or press Enter to return all): ")
      choice <- str_trim(choice)

      if (choice == "") {
        return(matches)
      }

      choice_num <- suppressWarnings(as.numeric(choice))
      if (
        !is.na(choice_num) && choice_num >= 1 && choice_num <= length(matches)
      ) {
        return(matches[choice_num])
      } else {
        message("Invalid selection. Returning all matches.")
        return(matches)
      }
    } else {
      # Non-interactive mode - return list with helpful message
      message(paste(
        "Found ",
        length(matches),
        " teams matching '",
        search_term,
        "':",
        sep = ""
      ))
      message("To get specific team data, use exact name from:")
      for (i in seq_along(matches)) {
        message(paste(" ", i, "-", matches[i]))
      }
      message("")
      return(matches)
    }
  }
}

#' Find Manufacturer Matches
#'
#' @param search_term Character string to search for
#' @param data Tibble containing NASCAR race data or series specification
#' @param max_results Maximum number of matches to return
#' @return Character vector of matching manufacturer names
#' @export
find_manufacturer <- function(
  search_term,
  data = NULL,
  max_results = 5,
  interactive = TRUE
) {
  # Use all series data if none provided
  if (is.null(data)) {
    data <- selected_series_data("all")
  }

  # Handle flexible series input
  if (!is.data.frame(data)) {
    data <- get_series_data(data)
  }

  # Handle common manufacturer aliases
  if (str_to_lower(search_term) %in% c("chevy", "chevrolet")) {
    search_term <- "chevrolet"
  }

  matches <- smart_match(search_term, data$Make, max_results)

  if (length(matches) == 0) {
    message(paste("No manufacturers found matching:", search_term))
    return(invisible(character(0)))
  }

  if (length(matches) == 1) {
    return(matches)
  } else {
    if (interactive && base::interactive()) {
      # Interactive selection
      message(paste(
        "Found ",
        length(matches),
        " manufacturers matching '",
        search_term,
        "':",
        sep = ""
      ))
      for (i in seq_along(matches)) {
        message(paste(" ", i, "-", matches[i]))
      }

      choice <- readline(
        "Select manufacturer number (or press Enter to return all): "
      )
      choice <- str_trim(choice)

      if (choice == "") {
        return(matches)
      }

      choice_num <- suppressWarnings(as.numeric(choice))
      if (
        !is.na(choice_num) && choice_num >= 1 && choice_num <= length(matches)
      ) {
        return(matches[choice_num])
      } else {
        message("Invalid selection. Returning all matches.")
        return(matches)
      }
    } else {
      # Non-interactive mode - return list with helpful message
      message(paste(
        "Found ",
        length(matches),
        " manufacturers matching '",
        search_term,
        "':",
        sep = ""
      ))
      message("To get specific manufacturer data, use exact name from:")
      for (i in seq_along(matches)) {
        message(paste(" ", i, "-", matches[i]))
      }
      message("")
      return(matches)
    }
  }
}

#' Enhanced Get Driver Info with Smart Matching
#'
#' @param driver Character string of driver name to search for
#' @param series Either character string ("cup", "xfinity", "truck", "all") or data frame
#' @param type Character string specifying return type ("summary", "season", "all")
#' @return Tibble with driver statistics or NULL if no exact match
#' @export
get_driver_info <- function(
  driver,
  series = "all",
  type = "summary",
  interactive = TRUE
) {
  # Input validation
  if (is.null(driver) || is.null(series) || is.null(type)) {
    stop("Please enter correct values. See ?get_driver_info")
  }
  if (!str_to_lower(type) %in% c("summary", "season", "all")) {
    stop("Invalid type. Must be: summary, season, or all")
  }

  # Get race data
  race_data <- get_series_data(series)

  # Find driver matches
  driver_matches <- smart_match(driver, race_data$Driver, max_results = 10)

  if (length(driver_matches) == 0) {
    message(paste("No drivers found matching:", driver))
    return(invisible(NULL))
  }

  # Handle multiple matches with user choice
  if (length(driver_matches) == 1) {
    selected_driver <- driver_matches[1]
  } else {
    if (interactive && base::interactive()) {
      # Interactive selection
      message(paste(
        "Found ",
        length(driver_matches),
        " drivers matching '",
        driver,
        "':",
        sep = ""
      ))
      for (i in seq_along(driver_matches)) {
        message(paste(" ", i, "-", driver_matches[i]))
      }

      choice <- readline("Select driver number: ")
      choice_num <- suppressWarnings(as.numeric(str_trim(choice)))

      if (
        !is.na(choice_num) &&
          choice_num >= 1 &&
          choice_num <= length(driver_matches)
      ) {
        selected_driver <- driver_matches[choice_num]
      } else {
        message("Invalid selection. Using first match:", driver_matches[1])
        selected_driver <- driver_matches[1]
      }
    } else {
      # Non-interactive mode - use first match but warn user
      message(paste(
        "Multiple drivers found matching '",
        driver,
        "':",
        sep = ""
      ))
      for (i in seq_along(driver_matches)) {
        message(paste(" ", i, "-", driver_matches[i]))
      }
      message("\nUsing first match:", driver_matches[1])
      message(
        "For other drivers, use more specific search terms or set interactive = TRUE"
      )
      selected_driver <- driver_matches[1]
    }
  }

  # Filter data for selected driver
  race_results <- race_data |>
    filter(Driver == selected_driver)

  message(paste("Driver:", selected_driver))

  # Return results based on type
  if (type == "season") {
    driver_table <- race_results |>
      group_by(Series, Season) |>
      summarize(
        Races = n_distinct(Name),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish, na.rm = TRUE),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE),
        .groups = "drop"
      )
    return(driver_table)
  } else if (type == "summary") {
    driver_table <- race_results |>
      group_by(Series) |>
      summarize(
        Seasons = n_distinct(Season),
        `Career Races` = n(),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish, na.rm = TRUE),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE),
        .groups = "drop"
      )
    return(driver_table)
  } else if (type == "all") {
    return(race_results)
  }
}

#' Enhanced Get Team Info with Smart Matching
#'
#' @param team Character string of team name to search for
#' @param series Either character string ("cup", "xfinity", "truck", "all") or data frame
#' @param type Character string specifying return type ("summary", "season", "all")
#' @return Tibble with team statistics or NULL if no exact match
#' @export
get_team_info <- function(
  team,
  series = "all",
  type = "summary",
  interactive = TRUE
) {
  # Input validation
  if (is.null(team) || is.null(series) || is.null(type)) {
    stop("Please enter correct values. See ?get_team_info")
  }
  if (!str_to_lower(type) %in% c("summary", "season", "all")) {
    stop("Invalid type. Must be: summary, season, or all")
  }

  # Get race data
  race_data <- get_series_data(series)

  # Find team matches
  team_matches <- smart_match(team, race_data$Team, max_results = 10)

  if (length(team_matches) == 0) {
    message(paste("No teams found matching:", team))
    return(invisible(NULL))
  }

  # Handle multiple matches with user choice
  if (length(team_matches) == 1) {
    selected_team <- team_matches[1]
  } else {
    if (interactive && base::interactive()) {
      # Interactive selection
      message(paste(
        "Found ",
        length(team_matches),
        " teams matching '",
        team,
        "':",
        sep = ""
      ))
      for (i in seq_along(team_matches)) {
        message(paste(" ", i, "-", team_matches[i]))
      }

      choice <- readline("Select team number: ")
      choice_num <- suppressWarnings(as.numeric(str_trim(choice)))

      if (
        !is.na(choice_num) &&
          choice_num >= 1 &&
          choice_num <= length(team_matches)
      ) {
        selected_team <- team_matches[choice_num]
      } else {
        message("Invalid selection. Using first match:", team_matches[1])
        selected_team <- team_matches[1]
      }
    } else {
      # Non-interactive mode - use first match but warn user
      message(paste("Multiple teams found matching '", team, "':", sep = ""))
      for (i in seq_along(team_matches)) {
        message(paste(" ", i, "-", team_matches[i]))
      }
      message("\nUsing first match:", team_matches[1])
      message(
        "For other teams, use more specific search terms or set interactive = TRUE"
      )
      selected_team <- team_matches[1]
    }
  }

  # Filter data for selected team
  race_results <- race_data |>
    filter(Team == selected_team)

  message(paste("Team:", selected_team))

  # Return results based on type
  if (type == "season") {
    team_table <- race_results |>
      group_by(Series, Season) |>
      summarize(
        Races = n_distinct(Name),
        `# of Drivers` = n_distinct(Driver),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish, na.rm = TRUE),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE),
        .groups = "drop"
      )
    return(team_table)
  } else if (type == "summary") {
    team_table <- race_results |>
      group_by(Series) |>
      summarize(
        Seasons = n_distinct(Season),
        `Career Races` = n(),
        `# of Drivers` = n_distinct(Driver),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish, na.rm = TRUE),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE),
        .groups = "drop"
      )
    return(team_table)
  } else if (type == "all") {
    return(race_results)
  }
}

#' Enhanced Get Manufacturer Info with Smart Matching
#'
#' @param manufacturer Character string of manufacturer name to search for
#' @param series Either character string ("cup", "xfinity", "truck", "all") or data frame
#' @param type Character string specifying return type ("summary", "season", "all")
#' @return Tibble with manufacturer statistics or NULL if no exact match
#' @export
get_manufacturer_info <- function(
  manufacturer,
  series = "all",
  type = "summary",
  interactive = TRUE
) {
  # Input validation
  if (is.null(manufacturer) || is.null(series) || is.null(type)) {
    stop("Please enter correct values. See ?get_manufacturer_info")
  }
  if (!str_to_lower(type) %in% c("summary", "season", "all")) {
    stop("Invalid type. Must be: summary, season, or all")
  }

  # Get race data
  race_data <- get_series_data(series)

  # Find manufacturer matches
  mfg_matches <- smart_match(manufacturer, race_data$Make, max_results = 10)

  if (length(mfg_matches) == 0) {
    message(paste("No manufacturers found matching:", manufacturer))
    return(invisible(NULL))
  }

  # Handle multiple matches with user choice
  if (length(mfg_matches) == 1) {
    selected_mfg <- mfg_matches[1]
  } else {
    if (interactive && base::interactive()) {
      # Interactive selection
      message(paste(
        "Found ",
        length(mfg_matches),
        " manufacturers matching '",
        manufacturer,
        "':",
        sep = ""
      ))
      for (i in seq_along(mfg_matches)) {
        message(paste(" ", i, "-", mfg_matches[i]))
      }

      choice <- readline("Select manufacturer number: ")
      choice_num <- suppressWarnings(as.numeric(str_trim(choice)))

      if (
        !is.na(choice_num) &&
          choice_num >= 1 &&
          choice_num <= length(mfg_matches)
      ) {
        selected_mfg <- mfg_matches[choice_num]
      } else {
        message("Invalid selection. Using first match:", mfg_matches[1])
        selected_mfg <- mfg_matches[1]
      }
    } else {
      # Non-interactive mode - use first match but warn user
      message(paste(
        "Multiple manufacturers found matching '",
        manufacturer,
        "':",
        sep = ""
      ))
      for (i in seq_along(mfg_matches)) {
        message(paste(" ", i, "-", mfg_matches[i]))
      }
      message("\nUsing first match:", mfg_matches[1])
      message(
        "For other manufacturers, use more specific search terms or set interactive = TRUE"
      )
      selected_mfg <- mfg_matches[1]
    }
  }

  # Filter data for selected manufacturer
  race_results <- race_data |>
    filter(Make == selected_mfg)

  message(paste("Manufacturer:", selected_mfg))

  # Return results based on type
  if (type == "season") {
    mfg_table <- race_results |>
      group_by(Series, Season) |>
      summarize(
        Races = n_distinct(Name),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish, na.rm = TRUE),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE),
        .groups = "drop"
      )
    return(mfg_table)
  } else if (type == "summary") {
    mfg_table <- race_results |>
      group_by(Series) |>
      summarize(
        Seasons = n_distinct(Season),
        Races = n(),
        Wins = sum(Win, na.rm = TRUE),
        `Best Finish` = min(Finish, na.rm = TRUE),
        `Avg Finish` = round(mean(Finish, na.rm = TRUE), 1),
        `Laps Raced` = sum(Laps, na.rm = TRUE),
        `Laps Led` = sum(Led, na.rm = TRUE),
        .groups = "drop"
      )
    return(mfg_table)
  } else if (type == "all") {
    return(race_results)
  }
}
