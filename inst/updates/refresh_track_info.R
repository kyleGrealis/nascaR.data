#' Refresh Track Info from Wikipedia
#'
#' Scrapes the Wikipedia "List of NASCAR tracks" page to update
#' track metadata (length, surface) for all three series.
#'
#' This is a developer tool, not part of the package build.
#' Run manually when new tracks appear on the schedule or when
#' track configurations change.
#'
#' @examples
#' \dontrun{
#' source("inst/updates/refresh_track_info.R")
#' refresh_track_info()                       # update all
#' refresh_track_info("cup", save = FALSE)    # preview only
#' add_track("cup", "Coronado Speed Festival", 2.1, "paved", 2026L)
#' }

refresh_track_info <- function(
  series = c("cup", "nxs", "truck"),
  save = TRUE,
  verbose = TRUE
) {
  series <- match.arg(series, several.ok = TRUE)

  if (verbose) message("Fetching Wikipedia track data...")

  page <- tryCatch(
    rvest::read_html(
      "https://en.wikipedia.org/wiki/List_of_NASCAR_tracks"
    ),
    error = function(e) {
      stop(
        "Failed to fetch Wikipedia page: ",
        conditionMessage(e)
      )
    }
  )

  tables <- page |>
    rvest::html_elements("table.wikitable") |>
    rvest::html_table()

  # Table 1: Current active tracks
  #   Columns: Track, Track Length, Configuration, ...
  # Table 2: Recently added/returning tracks
  #   Columns: Track, Type and layout, ...
  active <- tables[[1]]
  recent <- tables[[2]]

  # Parse active tracks (Table 1)
  active_parsed <- data.frame(
    Track = active$Track,
    Length = as.numeric(stringr::str_extract(
      active[["Track Length"]],
      "[\\d.]+"
    )),
    Surface = dplyr::case_when(
      stringr::str_detect(
        stringr::str_to_lower(active$Configuration), "dirt"
      ) ~ "dirt",
      stringr::str_detect(
        stringr::str_to_lower(active$Configuration), "road"
      ) ~ "road",
      TRUE ~ "paved"
    ),
    stringsAsFactors = FALSE
  )

  # Parse recently added tracks (Table 2)
  layout_col <- recent[["Type and layout"]]
  recent_parsed <- data.frame(
    Track = recent$Track,
    Length = as.numeric(stringr::str_extract(
      layout_col, "[\\d.]+"
    )),
    Surface = dplyr::case_when(
      stringr::str_detect(
        stringr::str_to_lower(layout_col), "dirt"
      ) ~ "dirt",
      stringr::str_detect(
        stringr::str_to_lower(layout_col), "road|street"
      ) ~ "road",
      TRUE ~ "paved"
    ),
    stringsAsFactors = FALSE
  )

  wiki_tracks <- rbind(active_parsed, recent_parsed)
  wiki_tracks <- wiki_tracks[!is.na(wiki_tracks$Length), ]

  if (verbose) {
    message(
      "  Parsed ", nrow(wiki_tracks),
      " tracks from Wikipedia (",
      nrow(active_parsed), " active + ",
      nrow(recent_parsed), " recent)"
    )
  }

  # Update each series
  results <- list()

  for (s in series) {
    rda_file <- file.path(
      "inst", "updates",
      paste0(s, "_track_info.rda")
    )
    obj_name <- paste0(s, "_track_info")

    if (!file.exists(rda_file)) {
      if (verbose) message("  ", s, ": .rda not found, skipping")
      next
    }

    load(rda_file)
    existing <- get(obj_name)

    if (verbose) {
      message(
        "  ", s, ": ", nrow(existing), " existing tracks"
      )
    }

    updated <- existing
    n_filled <- 0L
    diffs <- list()

    for (i in seq_len(nrow(existing))) {
      track_name <- existing$Track[i]
      distances <- stringdist::stringdist(
        stringr::str_to_lower(track_name),
        stringr::str_to_lower(wiki_tracks$Track),
        method = "jw"
      )
      best_idx <- which.min(distances)
      best_dist <- distances[best_idx]

      # Tight threshold: only match near-identical names.
      # Variants like "Road Course" / "Dirt Track" will NOT
      # fuzzy-match to the base track (which is correct).
      if (best_dist >= 0.08) next

      wiki_len <- wiki_tracks$Length[best_idx]
      wiki_sfc <- wiki_tracks$Surface[best_idx]
      old_len <- updated$Length[i]
      old_sfc <- updated$Surface[i]

      # Fill missing values (NAs)
      if (is.na(old_len) && !is.na(wiki_len)) {
        updated$Length[i] <- wiki_len
        n_filled <- n_filled + 1L
        if (verbose) {
          message(
            "    Filled: ", track_name,
            " Length = ", wiki_len, " mi"
          )
        }
      }
      if (is.na(old_sfc) && !is.na(wiki_sfc)) {
        updated$Surface[i] <- wiki_sfc
        n_filled <- n_filled + 1L
        if (verbose) {
          message(
            "    Filled: ", track_name,
            " Surface = ", wiki_sfc
          )
        }
      }

      # Report differences (don't auto-overwrite)
      len_diff <- !is.na(wiki_len) && !is.na(old_len) &&
        abs(old_len - wiki_len) > 0.01
      sfc_diff <- !is.na(wiki_sfc) && !is.na(old_sfc) &&
        old_sfc != wiki_sfc

      if (len_diff || sfc_diff) {
        diffs[[length(diffs) + 1]] <- list(
          track = track_name,
          wiki_match = wiki_tracks$Track[best_idx],
          old_len = old_len, wiki_len = wiki_len,
          old_sfc = old_sfc, wiki_sfc = wiki_sfc
        )
      }
    }

    if (verbose) {
      message("  ", s, ": ", n_filled, " NA values filled")
    }

    if (length(diffs) > 0 && verbose) {
      message(
        "  ", s, ": ", length(diffs),
        " tracks differ from Wikipedia (review manually):"
      )
      for (d in diffs) {
        message(
          "    ", d$track, " -> '", d$wiki_match, "': ",
          d$old_len, "/", d$old_sfc,
          " vs wiki ", d$wiki_len, "/", d$wiki_sfc
        )
      }
    }

    # Report unmatched existing tracks (no Wikipedia match)
    unmatched <- character(0)
    for (i in seq_len(nrow(existing))) {
      distances <- stringdist::stringdist(
        stringr::str_to_lower(existing$Track[i]),
        stringr::str_to_lower(wiki_tracks$Track),
        method = "jw"
      )
      if (min(distances) >= 0.15) {
        unmatched <- c(unmatched, existing$Track[i])
      }
    }

    if (length(unmatched) > 0 && verbose) {
      message(
        "  ", s, ": ", length(unmatched),
        " existing tracks had no Wikipedia match:"
      )
      for (t in unmatched) message("    - ", t)
    }

    results[[s]] <- updated

    if (save) {
      assign(obj_name, updated)
      save(list = obj_name, file = rda_file)
      if (verbose) message("  ", s, ": saved to ", rda_file)
    }
  }

  invisible(results)
}


#' Manually Add a Track to Series Track Info
#'
#' For tracks not yet on Wikipedia (e.g., brand-new street
#' courses announced mid-season).
#'
#' @param series One of "cup", "nxs", "truck".
#' @param track Character. Exact track name as it appears on
#'   DriverAverages.com.
#' @param length Numeric. Track length in miles.
#' @param surface Character. "paved", "dirt", or "road".
#' @param season Integer. First season this track appears.
#'
#' @examples
#' \dontrun{
#' source("inst/updates/refresh_track_info.R")
#' add_track("cup", "Coronado Speed Festival", 2.1, "paved", 2026L)
#' }
add_track <- function(series, track, length, surface, season) {
  series <- match.arg(series, c("cup", "nxs", "truck"))
  rda_file <- file.path(
    "inst", "updates",
    paste0(series, "_track_info.rda")
  )
  obj_name <- paste0(series, "_track_info")

  if (!file.exists(rda_file)) {
    stop("File not found: ", rda_file)
  }

  load(rda_file)
  existing <- get(obj_name)

  if (track %in% existing$Track) {
    message("Track '", track, "' already exists. Skipping.")
    return(invisible(existing))
  }

  new_row <- data.frame(
    Season = as.integer(season),
    Track = track,
    Length = as.numeric(length),
    Surface = surface,
    stringsAsFactors = FALSE
  )

  updated <- rbind(existing, new_row)
  updated <- updated[order(updated$Track), ]

  assign(obj_name, updated)
  save(list = obj_name, file = rda_file)
  message(
    "Added '", track, "' to ", series, " track info (",
    nrow(updated), " total tracks)"
  )

  invisible(updated)
}
