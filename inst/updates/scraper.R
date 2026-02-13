#' Update NASCAR Series Data
#'
#' Consolidated scraper for all three NASCAR series (Cup, Xfinity, Truck).
#' Downloads current data from R2, scrapes new races from DriverAverages.com,
#' combines the results, and uploads back to R2.
#'
#' Uses httr2 for HTTP requests with built-in retry logic, placeholder
#' detection, and track info merging.
#'
#' @param series Character. One of "cup", "xfinity", or "truck".
#'
#' @return Invisible NULL. Uploads updated data to R2 as side effect.

update_nascar_series <- function(series) {
  # Validate series parameter
  series <- tolower(series)
  if (!series %in% c("cup", "xfinity", "truck")) {
    stop(
      "Invalid series '", series,
      "'. Must be one of: 'cup', 'xfinity', 'truck'"
    )
  }

  # Series-specific configuration
  config <- list(
    cup = list(
      base_url = "https://www.driveraverages.com/nascar/",
      r2_key = "cup_series",
      track_info_file = "inst/updates/cup_track_info.rda",
      track_object = "cup_track_info",
      series_name = "Cup"
    ),
    xfinity = list(
      base_url = "https://www.driveraverages.com/nascar_xfinityseries/",
      r2_key = "xfinity_series",
      track_info_file = "inst/updates/xfinity_track_info.rda",
      track_object = "xfinity_track_info",
      series_name = "Xfinity"
    ),
    truck = list(
      base_url = "https://www.driveraverages.com/nascar_truckseries/",
      r2_key = "truck_series",
      track_info_file = "inst/updates/truck_track_info.rda",
      track_object = "truck_track_info",
      series_name = "Truck"
    )
  )

  cfg <- config[[series]]
  message("Updating ", cfg$series_name, " Series data...")

  # Helper: fetch a page with httr2 built-in retry
  get_page <- function(url) {
    tryCatch(
      {
        httr2::request(url) |>
          httr2::req_user_agent(
            "nascaR.data R package (https://github.com/kyleGrealis/nascaR.data)"
          ) |>
          httr2::req_retry(
            max_tries = 5,
            backoff = ~ 3 * 1.5^.x
          ) |>
          httr2::req_perform() |>
          httr2::resp_body_string() |>
          rvest::read_html()
      },
      error = function(e) {
        stop(
          "[", cfg$series_name, "] Failed to retrieve ", url,
          ": ", conditionMessage(e)
        )
      }
    )
  }

  # Download existing data from R2
  r2_url <- paste0(
    "https://nascar.kylegrealis.com/", cfg$r2_key, ".parquet"
  )
  message("Downloading current data from R2...")

  existing_data <- tryCatch(
    arrow::read_parquet(r2_url),
    error = function(e) {
      stop(
        "[", cfg$series_name,
        "] Failed to download from R2: ",
        conditionMessage(e)
      )
    }
  )

  message(
    "  Loaded ", format(nrow(existing_data), big.mark = ","),
    " existing rows"
  )

  # Load track info
  if (file.exists(cfg$track_info_file)) {
    load(cfg$track_info_file)
    track_info <- get(cfg$track_object)
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
  current_year <- as.integer(format(Sys.Date(), "%Y"))

  if (current_year %in% existing_data$Season) {
    last_completed_race <- max(
      existing_data$Race[existing_data$Season == current_year]
    )
  } else {
    last_completed_race <- 0L
    message(
      "No ", cfg$series_name,
      " races completed yet for ", current_year, "."
    )
  }

  # Check for placeholder row from DriverAverages.com
  # They sometimes add a single-row placeholder for next week's race
  # with mostly empty/NA values, causing stale data detection
  placeholder_check <- existing_data |>
    dplyr::filter(
      Season == current_year,
      Race == last_completed_race
    )

  is_placeholder <- nrow(placeholder_check) == 1 ||
    (nrow(placeholder_check) > 0 &&
      all(is.na(placeholder_check$Laps) | placeholder_check$Laps == 0))

  if (is_placeholder) {
    existing_data <- existing_data |>
      dplyr::filter(
        !(Season == current_year & Race == last_completed_race)
      )
    last_completed_race <- last_completed_race - 1L
    message("Removed placeholder row(s) for incomplete race")
  }

  # Get race links for current season
  season_url <- paste0(cfg$base_url, "year.php?yr_id=", current_year)

  new_links <- get_page(season_url) |>
    rvest::html_elements("div#Div2Nav ul a") |>
    rvest::html_attr("href") |>
    purrr::keep(~ stringr::str_detect(., "race.php?"))

  message(
    "Found ", length(new_links), " total ", cfg$series_name,
    " races for ", current_year
  )
  message("Last completed race: ", last_completed_race)

  # Check if up to date
  if (length(new_links) <= last_completed_race) {
    message(
      cfg$series_name, " Series is up-to-date with ",
      last_completed_race, " races"
    )
    return(invisible())
  }

  # Only process new races
  new_links <- new_links[(last_completed_race + 1):length(new_links)]

  if (length(new_links) == 0) {
    message("No new ", cfg$series_name, " races to process")
    return(invisible())
  }

  message("Processing ", length(new_links), " new race(s)...")

  # Process each new race with rate limiting and proper indexing
  new_results <- purrr::imap_dfr(new_links, function(link, race_index) {
    race_number <- as.integer(last_completed_race + race_index)

    # Rate limiting: small delay between requests
    Sys.sleep(0.5)

    page <- get_page(paste0(cfg$base_url, link))

    # Extract race details
    details <- page |>
      rvest::html_element("td.td-left span.td-bold") |>
      rvest::html_text2()

    parts <- stringr::str_split(details, "\n")[[1]]
    race_name <- parts[1]
    track_name <- parts[2]

    message(
      "  [Race ", race_number, "] Processing: ",
      track_name
    )

    # Extract race table
    race_table <- page |>
      rvest::html_table(header = TRUE) |>
      purrr::pluck(3)

    if (is.null(race_table) || nrow(race_table) == 0) {
      message(
        "  [Race ", race_number,
        "] Skipping: empty or missing table"
      )
      return(NULL)
    }

    # Clean and format data with explicit type coercion
    result <- race_table |>
      dplyr::rename(Car = `#`) |>
      dplyr::mutate(
        Season = current_year,
        Race = race_number,
        Car = stringr::str_remove(Car, "#"),
        Track = track_name,
        Name = race_name,
        Finish = as.integer(Finish),
        Start = as.integer(Start),
        Pts = as.integer(Pts),
        Laps = as.integer(Laps),
        Led = as.integer(Led),
        S1 = as.integer(S1),
        S2 = as.integer(S2),
        Rating = as.numeric(Rating),
        Win = dplyr::if_else(Finish == 1L, 1, 0),
        `Seg Points` = as.integer(`Seg Points`)
      ) |>
      dplyr::left_join(
        track_info |> dplyr::select(Track, Length, Surface),
        by = "Track"
      ) |>
      dplyr::select(
        Season, Race, Track, Name, Length, Surface,
        Finish, Start, Car, Driver, Make, Pts,
        Laps, Led, Status, Team, S1, S2,
        Rating, Win, `Seg Points`
      )

    message("  Processed ", nrow(result), " driver results")
    result
  })

  # Combine and upload to R2
  if (nrow(new_results) > 0) {
    updated_data <- dplyr::bind_rows(existing_data, new_results)

    n_new_races <- dplyr::n_distinct(new_results$Race)
    n_new_results <- nrow(new_results)
    message(
      "Added ", n_new_races, " new race(s) with ",
      n_new_results, " total results"
    )

    # Upload combined data to R2
    message("Uploading ", cfg$r2_key, " to R2...")
    nascar_r2_upload(updated_data, cfg$r2_key)
    message("  -> uploaded ", cfg$r2_key, ".parquet to R2")
  } else {
    message("No new ", cfg$series_name, " race data found")
  }

  invisible()
}
