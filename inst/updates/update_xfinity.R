#' Update Xfinity Series Data
#'
#' Standalone script to update NASCAR Xfinity Series race data from DriverAverages.com
#' This script handles ONLY Xfinity Series - no conditionals, no complexity.

update_xfinity_series <- function() {
  # Load required libraries
  suppressPackageStartupMessages({
    library(dplyr)
    library(rvest)
    library(stringr)
    library(purrr)
  })

  message("Updating Xfinity Series data...")

  # Configuration - Xfinity Series only
  base_url <- "https://www.driveraverages.com/nascar_xfinityseries/"
  data_file <- "data/xfinity_series.rda"
  track_info_file <- "inst/updates/xfinity_track_info.rda"

  # Helper function for page retry logic
  get_page_with_retry <- function(url) {
    attempts <- 0
    wait_time <- 3

    while (attempts < 5) {
      result <- tryCatch(
        {
          read_html(url)
        },
        error = function(e) {
          if (grepl("SSL connection timeout", e$message, ignore.case = TRUE)) {
            message(paste(
              "SSL timeout occurred. Retrying in",
              wait_time,
              "seconds..."
            ))
            Sys.sleep(wait_time)
            wait_time <<- wait_time * 1.5
            return(NULL)
          } else {
            stop(e)
          }
        }
      )

      if (!is.null(result)) return(result)
      attempts <- attempts + 1
    }
    stop("Failed to retrieve page after 5 attempts.")
  }

  # Load existing Xfinity Series data
  if (file.exists(data_file)) {
    load(data_file)
    existing_data <- xfinity_series
  } else {
    stop("Xfinity series data file not found!")
  }

  # Load track info
  if (file.exists(track_info_file)) {
    load(track_info_file)
    track_info <- xfinity_track_info
  } else {
    message("No track info found. Proceeding without track data...")
    track_info <- data.frame(
      Track = character(),
      Length = numeric(),
      Surface = character(),
      stringsAsFactors = FALSE
    )
  }

  # Determine current year and last completed race
  current_year <- as.numeric(format(Sys.Date(), "%Y"))

  if (current_year == max(existing_data$Season)) {
    last_completed_race <- max(existing_data$Race[
      existing_data$Season == current_year
    ])
  } else {
    last_completed_race <- 0
    message("No Xfinity races completed yet for this season.")
  }

  ###################################################################################
  # DriverAverages.com will sometimes add 1 row for the next week's race. This has
  # created issues for this script in the past where this function "thinks" that
  # there's a race that occurred and skips without processing new data. This check
  # ensures that new race data can be processed as intended.

  # Drop placeholder rows added for the next week's race.
  # These rows cause issues when processing new data because they aren't real results.
  placeholder_check <- existing_data |>
    filter(Season == current_year, Race == last_completed_race)

  if (nrow(placeholder_check) == 1) {
    # Drop place-holder row signifying that the race wasn't actually completed
    # and proceed with processing. Also, decrease the last_completed_race index
    # by 1 so it reflects the true index for the last completed race.
    existing_data <- existing_data |>
      filter(row_number() <= n() - 1)
    last_completed_race <- last_completed_race - 1
    message(
      "\n\nNOTE: 1 row dropped from existing data & index updated. See script!!!\n\n"
    )
  }
  ###################################################################################
  ###################################################################################

  # Get new race links
  season_url <- paste0(base_url, "year.php?yr_id=", current_year)

  new_links <- get_page_with_retry(season_url) |>
    html_elements("div#Div2Nav ul a") |>
    html_attr("href") |>
    keep(~ str_detect(., "race.php?"))

  message(paste("Found", length(new_links), "total Xfinity races"))
  message(paste("Processing races after race number:", last_completed_race))

  # Check if up to date
  if (length(new_links) <= last_completed_race) {
    message(paste(
      "Xfinity Series is up-to-date with",
      last_completed_race,
      "races!"
    ))
    return(invisible())
  }

  # Only process new races
  new_links <- new_links[(last_completed_race + 1):length(new_links)]

  if (length(new_links) == 0) {
    message("No new Xfinity races found to process")
    return(invisible())
  }

  # Process each new race
  new_results <- map_dfr(new_links, function(link) {
    page <- get_page_with_retry(paste0(base_url, link))

    # Extract race details
    details <- page |>
      html_element("td.td-left span.td-bold") |>
      html_text2()

    parts <- str_split(details, "\n")[[1]]
    race_name <- parts[1]
    track_name <- parts[2]

    message(paste("Processing Xfinity race at:", track_name))

    # Extract race table
    race_table <- page |>
      html_table(header = TRUE) |>
      pluck(3)

    # Clean and format data
    result <- race_table |>
      rename(Car = `#`) |>
      mutate(
        Season = as.integer(current_year),
        Race = as.integer(last_completed_race + which(new_links == link)),
        Car = str_remove(Car, "#"),
        Track = track_name,
        Name = race_name,
        Win = if_else(Finish == 1, 1, 0)
      ) |>
      left_join(
        track_info |> select(Track, Length, Surface),
        by = "Track"
      ) |>
      select(
        Season,
        Race,
        Track,
        Name,
        Length,
        Surface,
        Finish,
        Start,
        Car,
        Driver,
        Team,
        Make,
        Pts,
        Laps,
        Led,
        Status,
        Rating,
        Win
      )

    message(paste("Processed", nrow(result), "Xfinity results for this race"))
    return(result)
  })

  # Combine and save
  if (nrow(new_results) > 0) {
    xfinity_series <- bind_rows(existing_data, new_results)
    save(xfinity_series, file = data_file, compress = "bzip2")

    n_new_races <- n_distinct(new_results$Race)
    message(paste("Added", n_new_races, "new Xfinity races!"))
  } else {
    message("No new Xfinity race data found")
  }
}

# Run the update
update_xfinity_series()
