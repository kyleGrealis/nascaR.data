# NASCAR Data Validation Framework
#
# This framework validates NASCAR series data before committing to ensure data
# quality. It performs schema, integrity, value, and track info validation.
#
# Usage:
#   source("inst/validation/validate_data.R")
#   validate_series_data(cup_series, "cup", cup_track_info)

# Helper function to format messages
format_msg <- function(type, msg) {
  if (requireNamespace("cli", quietly = TRUE)) {
    switch(type,
      error = cli::cli_alert_danger(msg),
      warn = cli::cli_alert_warning(msg),
      success = cli::cli_alert_success(msg),
      info = cli::cli_alert_info(msg)
    )
  } else {
    prefix <- switch(type,
      error = "ERROR: ",
      warn = "WARNING: ",
      success = "SUCCESS: ",
      info = "INFO: "
    )
    message(paste0(prefix, msg))
  }
}

#' Validate NASCAR Series Data
#'
#' Main validation function that runs all validation checks on series data.
#'
#' @param data A data frame containing NASCAR series data.
#' @param series_name Character. One of 'cup', 'xfinity', or 'truck'.
#' @param track_info A data frame containing track reference information.
#'
#' @return Logical. TRUE if all validations pass, otherwise stops with error.
#'
#' @examples
#' \dontrun{
#' validate_series_data(cup_series, "cup", cup_track_info)
#' }
validate_series_data <- function(data, series_name, track_info) {
  format_msg("info", paste("Starting validation for", series_name, "series"))

  # Run all validation checks
  check_schema(data, series_name)
  check_integrity(data, series_name)
  check_values(data, series_name)
  check_track_info(data, track_info, series_name)

  format_msg("success", paste(series_name, "series passed all validation checks"))
  TRUE
}

#' Check Data Schema
#'
#' Validates that all required columns exist, have correct data types, and are
#' not completely empty.
#'
#' @param data A data frame containing NASCAR series data.
#' @param series_name Character. Name of the series being validated.
#'
#' @return Logical. TRUE if schema is valid, otherwise stops with error.
check_schema <- function(data, series_name) {
  format_msg("info", "Checking schema...")

  # Define required columns and their expected types
  required_cols <- c(
    "Season", "Race", "Track", "Name", "Length", "Surface",
    "Finish", "Start", "Car", "Driver", "Make", "Pts",
    "Laps", "Led", "Status", "Team", "S1", "S2",
    "Rating", "Win", "Seg Points"
  )

  expected_types <- list(
    Season = "integer",
    Race = "integer",
    Track = "character",
    Name = "character",
    Length = "numeric",
    Surface = "character",
    Finish = "integer",
    Start = "integer",
    Car = "character",
    Driver = "character",
    Make = "character",
    Pts = "integer",
    Laps = "integer",
    Led = "integer",
    Status = "character",
    Team = "character",
    S1 = "integer",
    S2 = "integer",
    Rating = "numeric",
    Win = "numeric",
    "Seg Points" = "integer"
  )

  # Check for missing required columns
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop(
      paste0(
        "Missing required columns in ", series_name, " series: ",
        paste(missing_cols, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  # Check data types
  for (col in names(expected_types)) {
    actual_type <- class(data[[col]])[1]
    expected_type <- expected_types[[col]]

    if (!actual_type %in% c(expected_type, "numeric")) {
      # Allow numeric for integer columns (R sometimes converts)
      if (!(expected_type == "integer" && actual_type == "numeric")) {
        stop(
          paste0(
            'Column "', col, '" has incorrect type in ', series_name, " series. ",
            "Expected: ", expected_type, ", Got: ", actual_type
          ),
          call. = FALSE
        )
      }
    }
  }

  # Check for completely empty columns (all NA)
  for (col in required_cols) {
    if (all(is.na(data[[col]]))) {
      stop(
        paste0(
          'Column "', col, '" is completely empty (all NA) in ',
          series_name, " series"
        ),
        call. = FALSE
      )
    }
  }

  format_msg("success", "Schema validation passed")
  TRUE
}

#' Check Data Integrity
#'
#' Validates data integrity including duplicates, sequential race numbers,
#' reasonable seasons, and valid position values.
#'
#' @param data A data frame containing NASCAR series data.
#' @param series_name Character. Name of the series being validated.
#'
#' @return Logical. TRUE if integrity checks pass, otherwise stops with error.
check_integrity <- function(data, series_name) {
  format_msg("info", "Checking data integrity...")

  # Check for duplicate rows (same Season + Race + Driver) in recent data.
  # Historical data (pre-2000) legitimately has drivers entering the same

  # race with different teams/cars, so only flag recent duplicates.
  current_year <- as.integer(format(Sys.Date(), "%Y"))
  recent_cutoff <- current_year - 10

  dup_check <- data |>
    dplyr::filter(Season >= recent_cutoff) |>
    dplyr::group_by(Season, Race, Driver) |>
    dplyr::filter(dplyr::n() > 1) |>
    dplyr::ungroup()

  if (nrow(dup_check) > 0) {
    sample_dups <- dup_check |>
      dplyr::select(Season, Race, Driver) |>
      dplyr::distinct() |>
      head(5)

    stop(
      paste0(
        "Found ", nrow(dup_check), " duplicate rows in recent ",
        series_name, " series data. Sample duplicates:\n",
        paste(capture.output(print(sample_dups)), collapse = "\n")
      ),
      call. = FALSE
    )
  }

  # Check that race numbers are sequential within each season
  race_check <- data |>
    dplyr::select(Season, Race) |>
    dplyr::distinct() |>
    dplyr::group_by(Season) |>
    dplyr::arrange(Season, Race) |>
    dplyr::mutate(
      expected_race = dplyr::row_number(),
      is_sequential = Race == expected_race
    ) |>
    dplyr::filter(!is_sequential) |>
    dplyr::ungroup()

  if (nrow(race_check) > 0) {
    sample_issues <- race_check |>
      dplyr::select(Season, Race, expected_race) |>
      head(5)

    stop(
      paste0(
        "Race numbers are not sequential in ", series_name, " series. ",
        "Found ", nrow(race_check), " issues. Sample:\n",
        paste(capture.output(print(sample_issues)), collapse = "\n")
      ),
      call. = FALSE
    )
  }

  # Check seasons are reasonable (>= 1949, <= current year + 1)
  current_year <- as.integer(format(Sys.Date(), "%Y"))
  max_allowed_season <- current_year + 1

  invalid_seasons <- data |>
    dplyr::filter(Season < 1949 | Season > max_allowed_season) |>
    dplyr::select(Season) |>
    dplyr::distinct()

  if (nrow(invalid_seasons) > 0) {
    stop(
      paste0(
        "Found invalid seasons in ", series_name, " series: ",
        paste(invalid_seasons$Season, collapse = ", "),
        ". Seasons must be >= 1949 and <= ", max_allowed_season
      ),
      call. = FALSE
    )
  }

  # Check finish positions are positive integers
  invalid_finish <- data |>
    dplyr::filter(!is.na(Finish) & (Finish < 1 | Finish != as.integer(Finish))) |>
    nrow()

  if (invalid_finish > 0) {
    stop(
      paste0(
        "Found ", invalid_finish, " invalid finish positions in ",
        series_name, " series. Finish must be positive integers."
      ),
      call. = FALSE
    )
  }

  # Check start positions are non-negative integers (excluding NA).
  # Historical data uses 0 for unknown/unreported starting positions.
  invalid_start <- data |>
    dplyr::filter(!is.na(Start) & (Start < 0 | Start != as.integer(Start))) |>
    nrow()

  if (invalid_start > 0) {
    stop(
      paste0(
        "Found ", invalid_start, " invalid start positions in ",
        series_name, " series. Start must be non-negative integers or NA."
      ),
      call. = FALSE
    )
  }

  format_msg("success", "Data integrity validation passed")
  TRUE
}

#' Check Data Values
#'
#' Validates that critical fields contain acceptable values and are not missing
#' where required.
#'
#' @param data A data frame containing NASCAR series data.
#' @param series_name Character. Name of the series being validated.
#'
#' @return Logical. TRUE if value checks pass, otherwise stops with error.
check_values <- function(data, series_name) {
  format_msg("info", "Checking data values...")

  # Check track names are not "TBD" or empty
  tbd_tracks <- data |>
    dplyr::filter(
      is.na(Track) |
        trimws(Track) == "" |
        toupper(trimws(Track)) == "TBD"
    ) |>
    dplyr::select(Season, Race, Track) |>
    dplyr::distinct()

  if (nrow(tbd_tracks) > 0) {
    stop(
      paste0(
        "Found ", nrow(tbd_tracks), " races with invalid track names ",
        '(NA, empty, or "TBD") in ', series_name, " series. Sample:\n",
        paste(capture.output(print(head(tbd_tracks, 5))), collapse = "\n")
      ),
      call. = FALSE
    )
  }

  # Check dates are valid (Name column often contains date info)
  # For now, just ensure Name field is not NA or empty
  invalid_names <- data |>
    dplyr::filter(is.na(Name) | trimws(Name) == "") |>
    dplyr::select(Season, Race, Name) |>
    dplyr::distinct()

  if (nrow(invalid_names) > 0) {
    stop(
      paste0(
        "Found ", nrow(invalid_names), " races with invalid race names ",
        "(NA or empty) in ", series_name, " series. Sample:\n",
        paste(capture.output(print(head(invalid_names, 5))), collapse = "\n")
      ),
      call. = FALSE
    )
  }

  # Check that each race has a winner (at least one Finish = 1)
  races_without_winner <- data |>
    dplyr::group_by(Season, Race) |>
    dplyr::summarize(
      has_winner = any(Finish == 1, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::filter(!has_winner)

  if (nrow(races_without_winner) > 0) {
    stop(
      paste0(
        "Found ", nrow(races_without_winner), " races without a winner ",
        "(Finish = 1) in ", series_name, " series. Sample:\n",
        paste(
          capture.output(print(head(races_without_winner, 5))),
          collapse = "\n"
        )
      ),
      call. = FALSE
    )
  }

  # Check that Driver field is not NA or empty
  invalid_drivers <- data |>
    dplyr::filter(is.na(Driver) | trimws(Driver) == "") |>
    dplyr::select(Season, Race, Finish, Driver) |>
    head(10)

  if (nrow(invalid_drivers) > 0) {
    stop(
      paste0(
        "Found rows with invalid driver names (NA or empty) in ",
        series_name, " series. Sample:\n",
        paste(capture.output(print(invalid_drivers)), collapse = "\n")
      ),
      call. = FALSE
    )
  }

  format_msg("success", "Data value validation passed")
  TRUE
}

#' Check Track Info Integration
#'
#' Validates that track names in the series data match the track_info reference
#' data. Allows for some fuzzy matching to handle minor variations.
#'
#' @param data A data frame containing NASCAR series data.
#' @param track_info A data frame containing track reference information.
#' @param series_name Character. Name of the series being validated.
#'
#' @return Logical. TRUE if track info checks pass, otherwise stops with error.
check_track_info <- function(data, track_info, series_name) {
  format_msg("info", "Checking track info integration...")

  # Get unique tracks from data (recent seasons only for relevance)
  current_year <- as.integer(format(Sys.Date(), "%Y"))
  recent_cutoff <- current_year - 5

  recent_tracks <- data |>
    dplyr::filter(Season >= recent_cutoff) |>
    dplyr::select(Track) |>
    dplyr::distinct() |>
    dplyr::pull(Track)

  # Get unique tracks from track_info
  reference_tracks <- track_info |>
    dplyr::select(Track) |>
    dplyr::distinct() |>
    dplyr::pull(Track)

  # Find tracks in data that don't match track_info
  unmatched_tracks <- setdiff(recent_tracks, reference_tracks)

  if (length(unmatched_tracks) > 0) {
    # Try fuzzy matching to find close matches
    fuzzy_results <- purrr::map(
      unmatched_tracks,
      function(track) {
        distances <- stringdist::stringdist(
          track,
          reference_tracks,
          method = "jw"
        )
        min_dist <- min(distances)

        if (min_dist < 0.15) {
          closest_match <- reference_tracks[which.min(distances)]
          list(
            unmatched = track,
            suggestion = closest_match,
            distance = min_dist
          )
        } else {
          list(
            unmatched = track,
            suggestion = NA_character_,
            distance = min_dist
          )
        }
      }
    )

    suggestions <- purrr::map_chr(
      fuzzy_results,
      function(x) {
        if (!is.na(x$suggestion)) {
          paste0(
            x$unmatched, " -> ", x$suggestion, " (dist: ",
            round(x$distance, 3), ")"
          )
        } else {
          paste0(x$unmatched, " (no close match)")
        }
      }
    )

    format_msg(
      "warn",
      paste0(
        "Found ", length(unmatched_tracks), " tracks in recent ",
        series_name, " data not in track_info"
      )
    )

    format_msg("info", "Unmatched tracks (last 5 seasons):")
    for (suggestion in head(suggestions, 10)) {
      format_msg("info", paste("  -", suggestion))
    }

    # Don't fail on this - it's informational
    # Track info might be updated separately
  }

  format_msg("success", "Track info validation completed")
  TRUE
}
