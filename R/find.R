#' Smart Matching Engine
#'
#' Performs priority-ranked fuzzy matching against a character
#' vector. Match priority: exact > starts_with > contains >
#' word_boundary > partial > fuzzy (Levenshtein, 70% threshold).
#'
#' @param search_term Character string to search for.
#' @param data_column Character vector to search within.
#' @param max_results Maximum number of matches to return
#'   (default: 5).
#' @return Character vector of best matches ranked by relevance,
#'   or `character(0)` if no matches are found.
#' @keywords internal
#' @noRd
smart_match <- function(
  search_term,
  data_column,
  max_results = 5
) {
  if (
    is.null(search_term) ||
      is.na(search_term) ||
      search_term == ""
  ) {
    return(character(0))
  }

  data_column <- data_column[!is.na(data_column)]
  data_column <- data_column[data_column != ""]

  if (length(data_column) == 0) {
    return(character(0))
  }

  search_clean <- str_to_lower(str_trim(search_term))
  options_clean <- str_to_lower(str_trim(data_column))

  unique_options <- data_column[!duplicated(options_clean)]
  unique_clean <- str_to_lower(str_trim(unique_options))

  # 1. EXACT MATCH (highest priority)
  exact_match <- which(unique_clean == search_clean)
  if (length(exact_match) > 0) {
    return(unique_options[exact_match[1]])
  }

  # Use fixed() throughout to prevent regex injection
  # (e.g., "Jr." won't be treated as regex "Jr" + any char)
  search_fixed <- fixed(search_clean)

  # 2. STARTS WITH (very high priority)
  starts_with <- which(
    str_starts(unique_clean, search_fixed)
  )
  if (length(starts_with) >= max_results) {
    return(unique_options[head(starts_with, max_results)])
  }

  # 3. CONTAINS SEARCH TERM (high priority)
  contains_term <- which(
    str_detect(unique_clean, search_fixed)
  )
  all_so_far <- unique(c(starts_with, contains_term))
  if (length(all_so_far) >= max_results) {
    return(unique_options[head(all_so_far, max_results)])
  }

  # 4. WORD BOUNDARY MATCHES (medium priority)
  search_words <- str_split(search_clean, "\\s+")[[1]]
  word_matches <- integer(0)

  if (length(search_words) > 1) {
    for (i in seq_along(unique_clean)) {
      words <- str_split(unique_clean[i], "\\s+")[[1]]
      if (all(search_words %in% words)) {
        word_matches <- c(word_matches, i)
      }
    }
  } else {
    for (i in seq_along(unique_clean)) {
      words <- str_split(unique_clean[i], "\\s+")[[1]]
      if (search_clean %in% words) {
        word_matches <- c(word_matches, i)
      }
    }
  }

  all_so_far <- unique(c(all_so_far, word_matches))
  if (length(all_so_far) >= max_results) {
    return(unique_options[head(all_so_far, max_results)])
  }

  # 5. PARTIAL WORD MATCHES (lower priority)
  if (nchar(search_clean) >= 3) {
    for (i in seq_along(unique_clean)) {
      if (i %in% all_so_far) next
      words <- str_split(unique_clean[i], "\\s+")[[1]]
      for (word in words) {
        if (str_detect(word, search_fixed)) {
          all_so_far <- c(all_so_far, i)
          break
        }
      }
    }
  }
  if (length(all_so_far) >= max_results) {
    return(unique_options[head(all_so_far, max_results)])
  }

  # 6. TYPO/FUZZY MATCHING (lowest priority)
  if (nchar(search_clean) >= 4) {
    for (i in seq_along(unique_clean)) {
      if (i %in% all_so_far) next
      words <- str_split(unique_clean[i], "\\s+")[[1]]
      for (word in words) {
        if (nchar(word) >= 4) {
          similarity <- 1 - (
            stringdist::stringdist(
              search_clean, word,
              method = "lv"
            ) / max(nchar(search_clean), nchar(word))
          )
          if (similarity >= 0.7) {
            all_so_far <- c(all_so_far, i)
            break
          }
        }
      }
    }
  }

  final_matches <- head(all_so_far, max_results)
  if (length(final_matches) == 0) {
    return(character(0))
  }

  unique_options[final_matches]
}


#' Flexible Series Data Handler
#'
#' Resolves a series argument to a tibble of race data. Accepts
#' character strings (e.g., `"cup"`, `"Cup Series"`) or a
#' pre-loaded data frame.
#'
#' @param series Character string or data frame.
#' @return Tibble with race data and a `Series` column.
#' @keywords internal
#' @noRd
get_series_data <- function(series) {
  if (is.character(series)) {
    series_clean <- str_to_lower(str_trim(series))

    series_map <- c(
      "cup" = "cup",
      "cup series" = "cup",
      "nxs" = "nxs",
      "nxs series" = "nxs",
      "truck" = "truck",
      "truck series" = "truck",
      "trucks" = "truck",
      "all" = "all"
    )

    matched_key <- series_map[series_clean]

    if (is.na(matched_key)) {
      rlang::abort(c(
        glue("Unknown series: {series}"),
        i = "Valid options: cup, nxs, truck, all"
      ))
    }

    selected_series_data(unname(matched_key))
  } else if (is.data.frame(series)) {
    race_data <- series
    if (!"Series" %in% names(race_data)) {
      race_data$Series <- "Custom"
    }
    race_data
  } else {
    rlang::abort(
      "`series` must be a character string or a data frame."
    )
  }
}


#' Handle Match Selection
#'
#' Resolves a vector of matches to a single selection, prompting
#' the user in interactive mode or defaulting to the first match.
#'
#' @param matches Character vector of matches found.
#' @param entity_label Display label (e.g., "Driver").
#' @param search_term Original search term for display.
#' @param interactive Whether to prompt for selection.
#' @return Single character string of the selected match.
#' @keywords internal
#' @noRd
select_match <- function(
  matches,
  entity_label,
  search_term,
  interactive
) {
  if (length(matches) == 1) {
    return(matches[1])
  }

  label_lower <- tolower(entity_label)

  if (interactive && base::interactive()) {
    message(glue(
      "Found {length(matches)} {label_lower}s ",
      "matching '{search_term}':"
    ))
    for (i in seq_along(matches)) {
      message("  ", i, " - ", matches[i])
    }

    choice <- readline(
      glue("Select {label_lower} number: ")
    )
    choice_num <- suppressWarnings(
      as.numeric(str_trim(choice))
    )

    if (
      !is.na(choice_num) &&
        choice_num >= 1 &&
        choice_num <= length(matches)
    ) {
      return(matches[choice_num])
    }

    message(
      "Invalid selection. Using first match: ", matches[1]
    )
    return(matches[1])
  }

  # Non-interactive mode
  message(glue(
    "Multiple {label_lower}s found ",
    "matching '{search_term}':"
  ))
  for (i in seq_along(matches)) {
    message("  ", i, " - ", matches[i])
  }
  message("\nUsing first match: ", matches[1])
  message(
    "For other ", label_lower, "s, use more specific ",
    "search terms or set interactive = TRUE"
  )
  matches[1]
}


#' Core Entity Info Logic
#'
#' Internal helper shared by [get_driver_info()],
#' [get_team_info()], and [get_manufacturer_info()].
#'
#' @param search_term Character string to search for.
#' @param column Column name to search within the race data.
#' @param entity_label Display label ("Driver", "Team", or
#'   "Manufacturer").
#' @param series Series filter.
#' @param type Return type.
#' @param interactive Whether to prompt for selection.
#' @param help_page Function name for error messages.
#' @param summarize_fn Function(race_results, type) returning
#'   a summary tibble.
#' @return Data frame, or `invisible(NULL)` if no match.
#' @keywords internal
#' @noRd
get_entity_info <- function(
  search_term,
  column,
  entity_label,
  series,
  type,
  interactive,
  help_page,
  summarize_fn
) {
  if (
    is.null(search_term) ||
      is.null(series) ||
      is.null(type)
  ) {
    rlang::abort(
      glue("Please enter correct values. See ?{help_page}")
    )
  }

  type <- str_to_lower(type)
  if (!type %in% c("summary", "season", "all")) {
    rlang::abort(
      "Invalid type. Must be: summary, season, or all"
    )
  }

  race_data <- get_series_data(series)

  matches <- smart_match(
    search_term, race_data[[column]],
    max_results = 10
  )

  if (length(matches) == 0) {
    message(
      "No ", tolower(entity_label), "s found matching: ",
      search_term
    )
    return(invisible(NULL))
  }

  selected <- select_match(
    matches, entity_label, search_term, interactive
  )

  race_results <- race_data[
    race_data[[column]] == selected, ,
    drop = FALSE
  ]

  message(entity_label, ": ", selected)

  if (type == "all") {
    return(race_results)
  }

  summarize_fn(race_results, type)
}


#' Get Driver Info with Smart Matching
#'
#' Search for a driver by name and return career statistics.
#' Supports partial names, typos, and case-insensitive input
#' via the built-in fuzzy matching engine.
#'
#' @param driver Character string of the driver name to search
#'   for. Supports partial names and common misspellings
#'   (e.g., `"earnhart"` finds Earnhardt).
#' @param series Character string (`"cup"`, `"nxs"`, `"truck"`,
#'   `"all"`) or a pre-loaded data frame. Default is `"all"`.
#' @param type Character string specifying the return format:
#'   \describe{
#'     \item{`"summary"`}{Career totals grouped by series
#'       (Seasons, Career Races, Wins, Best Finish, Avg Finish,
#'       Laps Raced, Laps Led).}
#'     \item{`"season"`}{Season-by-season breakdown
#'       (Races, Wins, Best Finish, Avg Finish, Laps Raced,
#'       Laps Led).}
#'     \item{`"all"`}{Complete race-by-race results.}
#'   }
#' @param interactive Logical. When `TRUE` (default) and the R
#'   session is interactive, prompts the user to select from
#'   multiple matches. When `FALSE`, silently uses the first
#'   match.
#'
#' @return A tibble of driver statistics (format depends on
#'   `type`), or `invisible(NULL)` if no match is found.
#'
#' @seealso [get_team_info()], [get_manufacturer_info()],
#'   [load_series()], [series_data]
#'
#' @examples
#' \donttest{
#' # Career summary across all series
#' get_driver_info("Christopher Bell")
#'
#' # Season-by-season Cup data
#' get_driver_info(
#'   "Christopher Bell",
#'   series = "cup",
#'   type = "season"
#' )
#' }
#' @export
get_driver_info <- function(
  driver,
  series = "all",
  type = "summary",
  interactive = TRUE
) {
  get_entity_info(
    search_term = driver,
    column = "Driver",
    entity_label = "Driver",
    series = series,
    type = type,
    interactive = interactive,
    help_page = "get_driver_info",
    summarize_fn = function(race_results, type) {
      if (type == "season") {
        race_results |>
          group_by(Series, Season) |>
          summarize(
            Races = n_distinct(Name),
            Wins = sum(Win, na.rm = TRUE),
            `Best Finish` = min(Finish, na.rm = TRUE),
            `Avg Finish` = round(
              mean(Finish, na.rm = TRUE), 1
            ),
            `Laps Raced` = sum(Laps, na.rm = TRUE),
            `Laps Led` = sum(Led, na.rm = TRUE),
            .groups = "drop"
          )
      } else {
        race_results |>
          group_by(Series) |>
          summarize(
            Seasons = n_distinct(Season),
            `Career Races` = n(),
            Wins = sum(Win, na.rm = TRUE),
            `Best Finish` = min(Finish, na.rm = TRUE),
            `Avg Finish` = round(
              mean(Finish, na.rm = TRUE), 1
            ),
            `Laps Raced` = sum(Laps, na.rm = TRUE),
            `Laps Led` = sum(Led, na.rm = TRUE),
            .groups = "drop"
          )
      }
    }
  )
}


#' Get Team Info with Smart Matching
#'
#' Search for a team by name and return performance statistics.
#' Supports partial names, typos, and case-insensitive input
#' via the built-in fuzzy matching engine.
#'
#' @param team Character string of the team name to search for.
#'   Supports partial names and common misspellings
#'   (e.g., `"gibbs"` finds Joe Gibbs Racing).
#' @param series Character string (`"cup"`, `"nxs"`, `"truck"`,
#'   `"all"`) or a pre-loaded data frame. Default is `"all"`.
#' @param type Character string specifying the return format:
#'   \describe{
#'     \item{`"summary"`}{Career totals grouped by series
#'       (Seasons, Career Races, # of Drivers, Wins,
#'       Best Finish, Avg Finish, Laps Raced, Laps Led).}
#'     \item{`"season"`}{Season-by-season breakdown
#'       (Races, # of Drivers, Wins, Best Finish, Avg Finish,
#'       Laps Raced, Laps Led).}
#'     \item{`"all"`}{Complete race-by-race results.}
#'   }
#' @param interactive Logical. When `TRUE` (default) and the R
#'   session is interactive, prompts the user to select from
#'   multiple matches. When `FALSE`, silently uses the first
#'   match.
#'
#' @return A tibble of team statistics (format depends on
#'   `type`), or `invisible(NULL)` if no match is found.
#'
#' @seealso [get_driver_info()], [get_manufacturer_info()],
#'   [load_series()], [series_data]
#'
#' @examples
#' \donttest{
#' # Career summary across all series
#' get_team_info("Joe Gibbs Racing")
#'
#' # Season-by-season Cup data
#' get_team_info(
#'   "Joe Gibbs Racing",
#'   series = "cup",
#'   type = "season"
#' )
#' }
#' @export
get_team_info <- function(
  team,
  series = "all",
  type = "summary",
  interactive = TRUE
) {
  get_entity_info(
    search_term = team,
    column = "Team",
    entity_label = "Team",
    series = series,
    type = type,
    interactive = interactive,
    help_page = "get_team_info",
    summarize_fn = function(race_results, type) {
      if (type == "season") {
        race_results |>
          group_by(Series, Season) |>
          summarize(
            Races = n_distinct(Name),
            `# of Drivers` = n_distinct(Driver),
            Wins = sum(Win, na.rm = TRUE),
            `Best Finish` = min(Finish, na.rm = TRUE),
            `Avg Finish` = round(
              mean(Finish, na.rm = TRUE), 1
            ),
            `Laps Raced` = sum(Laps, na.rm = TRUE),
            `Laps Led` = sum(Led, na.rm = TRUE),
            .groups = "drop"
          )
      } else {
        race_results |>
          group_by(Series) |>
          summarize(
            Seasons = n_distinct(Season),
            `Career Races` = n(),
            `# of Drivers` = n_distinct(Driver),
            Wins = sum(Win, na.rm = TRUE),
            `Best Finish` = min(Finish, na.rm = TRUE),
            `Avg Finish` = round(
              mean(Finish, na.rm = TRUE), 1
            ),
            `Laps Raced` = sum(Laps, na.rm = TRUE),
            `Laps Led` = sum(Led, na.rm = TRUE),
            .groups = "drop"
          )
      }
    }
  )
}


#' Get Manufacturer Info with Smart Matching
#'
#' Search for a manufacturer by name and return performance
#' statistics. Uses fuzzy matching to handle partial names,
#' typos, and case-insensitive searches.
#'
#' @param manufacturer Character string of the manufacturer name
#'   to search for.
#' @param series Character string (`"cup"`, `"nxs"`, `"truck"`,
#'   `"all"`) or a pre-loaded data frame. Default is `"all"`.
#' @param type Character string specifying the return format:
#'   \describe{
#'     \item{`"summary"`}{Career totals grouped by series
#'       (Seasons, Races, Wins, Best Finish, Avg Finish,
#'       Laps Raced, Laps Led).}
#'     \item{`"season"`}{Season-by-season breakdown
#'       (Races, Wins, Best Finish, Avg Finish, Laps Raced,
#'       Laps Led).}
#'     \item{`"all"`}{Complete race-by-race results.}
#'   }
#' @param interactive Logical. When `TRUE` (default) and the R
#'   session is interactive, prompts the user to select from
#'   multiple matches. When `FALSE`, silently uses the first
#'   match.
#'
#' @return A tibble of manufacturer statistics (format depends on
#'   `type`), or `invisible(NULL)` if no match is found.
#'
#' @seealso [get_driver_info()], [get_team_info()],
#'   [load_series()], [series_data]
#'
#' @examples
#' \donttest{
#' # Career summary across all series
#' get_manufacturer_info("Toyota")
#'
#' # Season-by-season Cup data
#' get_manufacturer_info(
#'   "Toyota",
#'   series = "cup",
#'   type = "season"
#' )
#' }
#' @export
get_manufacturer_info <- function(
  manufacturer,
  series = "all",
  type = "summary",
  interactive = TRUE
) {
  get_entity_info(
    search_term = manufacturer,
    column = "Make",
    entity_label = "Manufacturer",
    series = series,
    type = type,
    interactive = interactive,
    help_page = "get_manufacturer_info",
    summarize_fn = function(race_results, type) {
      if (type == "season") {
        race_results |>
          group_by(Series, Season) |>
          summarize(
            Races = n_distinct(Name),
            Wins = sum(Win, na.rm = TRUE),
            `Best Finish` = min(Finish, na.rm = TRUE),
            `Avg Finish` = round(
              mean(Finish, na.rm = TRUE), 1
            ),
            `Laps Raced` = sum(Laps, na.rm = TRUE),
            `Laps Led` = sum(Led, na.rm = TRUE),
            .groups = "drop"
          )
      } else {
        race_results |>
          group_by(Series) |>
          summarize(
            Seasons = n_distinct(Season),
            Races = n(),
            Wins = sum(Win, na.rm = TRUE),
            `Best Finish` = min(Finish, na.rm = TRUE),
            `Avg Finish` = round(
              mean(Finish, na.rm = TRUE), 1
            ),
            `Laps Raced` = sum(Laps, na.rm = TRUE),
            `Laps Led` = sum(Led, na.rm = TRUE),
            .groups = "drop"
          )
      }
    }
  )
}
