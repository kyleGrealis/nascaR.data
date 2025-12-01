#' Update NASCAR Series Data
#'
#' Consolidated scraper for all three NASCAR series (Cup, Xfinity, Truck).
#' Handles retry logic, placeholder detection, and track info merging.
#'
#' @param series Character. One of 'cup', 'xfinity', or 'truck'.
#'
#' @return Invisible NULL. Updates data files as side effect.

update_nascar_series <- function(series) {

  # Validate series parameter
  series <- tolower(series)
  if (!series %in% c('cup', 'xfinity', 'truck')) {
    stop(
      "Invalid series '", series, "'. Must be one of: 'cup', 'xfinity', 'truck'"
    )
  }

  # Series-specific configuration
  config <- list(
    cup = list(
      base_url = 'https://www.driveraverages.com/nascar/',
      data_file = 'data/cup_series.rda',
      track_info_file = 'inst/updates/cup_track_info.rda',
      data_object = 'cup_series',
      track_object = 'cup_track_info',
      series_name = 'Cup'
    ),
    xfinity = list(
      base_url = 'https://www.driveraverages.com/nascar_xfinityseries/',
      data_file = 'data/xfinity_series.rda',
      track_info_file = 'inst/updates/xfinity_track_info.rda',
      data_object = 'xfinity_series',
      track_object = 'xfinity_track_info',
      series_name = 'Xfinity'
    ),
    truck = list(
      base_url = 'https://www.driveraverages.com/nascar_truckseries/',
      data_file = 'data/truck_series.rda',
      track_info_file = 'inst/updates/truck_track_info.rda',
      data_object = 'truck_series',
      track_object = 'truck_track_info',
      series_name = 'Truck'
    )
  )

  cfg <- config[[series]]
  message('Updating ', cfg$series_name, ' Series data...')

  # Helper function for page retrieval with retry and user agent
  get_page_with_retry <- function(url) {
    attempts <- 0
    wait_time <- 3
    user_agent <- 'nascaR.data R package (https://github.com/sportsdataverse/nascaR.data)'

    while (attempts < 5) {
      result <- tryCatch(
        {
          httr::GET(url, httr::user_agent(user_agent)) |>
            httr::content(as = 'text', encoding = 'UTF-8') |>
            rvest::read_html()
        },
        error = function(e) {
          if (grepl('SSL connection timeout|timeout', e$message, ignore.case = TRUE)) {
            message(
              'Connection timeout for ', url, '. Retrying in ',
              wait_time, ' seconds... (attempt ', attempts + 1, '/5)'
            )
            Sys.sleep(wait_time)
            wait_time <<- wait_time * 1.5
            return(NULL)
          } else {
            stop('Failed to retrieve ', url, ': ', e$message)
          }
        }
      )

      if (!is.null(result)) return(result)
      attempts <- attempts + 1
    }
    stop('Failed to retrieve page after 5 attempts: ', url)
  }

  # Load existing data
  if (!file.exists(cfg$data_file)) {
    stop(cfg$series_name, ' series data file not found: ', cfg$data_file)
  }

  load(cfg$data_file)
  existing_data <- get(cfg$data_object)

  # Load track info
  if (file.exists(cfg$track_info_file)) {
    load(cfg$track_info_file)
    track_info <- get(cfg$track_object)
  } else {
    message('No track info found. Proceeding without track data...')
    track_info <- data.frame(
      Track = character(),
      Length = numeric(),
      Surface = character(),
      stringsAsFactors = FALSE
    )
  }

  # Determine current year and last completed race
  current_year <- as.numeric(format(Sys.Date(), '%Y'))

  if (current_year == max(existing_data$Season)) {
    last_completed_race <- max(existing_data$Race[
      existing_data$Season == current_year
    ])
  } else {
    last_completed_race <- 0
    message('No ', cfg$series_name, ' races completed yet for this season.')
  }

  # Check for placeholder row from DriverAverages.com
  # They sometimes add a single-row placeholder for next week's race which
  # causes the script to incorrectly think data is up-to-date
  placeholder_check <- existing_data |>
    dplyr::filter(Season == current_year, Race == last_completed_race)

  if (nrow(placeholder_check) == 1) {
    existing_data <- existing_data |>
      dplyr::filter(dplyr::row_number() <= dplyr::n() - 1)
    last_completed_race <- last_completed_race - 1
    message('Removed 1 placeholder row for incomplete race')
  }

  # Get race links for current season
  season_url <- paste0(cfg$base_url, 'year.php?yr_id=', current_year)

  new_links <- get_page_with_retry(season_url) |>
    rvest::html_elements('div#Div2Nav ul a') |>
    rvest::html_attr('href') |>
    purrr::keep(~ stringr::str_detect(., 'race.php?'))

  message(
    'Found ', length(new_links), ' total ', cfg$series_name, ' races for ',
    current_year
  )
  message('Last completed race: ', last_completed_race)

  # Check if up to date
  if (length(new_links) <= last_completed_race) {
    message(
      cfg$series_name, ' Series is up-to-date with ', last_completed_race,
      ' races'
    )
    return(invisible())
  }

  # Only process new races
  new_links <- new_links[(last_completed_race + 1):length(new_links)]

  if (length(new_links) == 0) {
    message('No new ', cfg$series_name, ' races to process')
    return(invisible())
  }

  message('Processing ', length(new_links), ' new race(s)...')

  # Process each new race with rate limiting
  new_results <- purrr::map_dfr(new_links, function(link) {

    # Rate limiting: small delay between requests
    Sys.sleep(0.5)

    page <- get_page_with_retry(paste0(cfg$base_url, link))

    # Extract race details
    details <- page |>
      rvest::html_element('td.td-left span.td-bold') |>
      rvest::html_text2()

    parts <- stringr::str_split(details, '\n')[[1]]
    race_name <- parts[1]
    track_name <- parts[2]

    message('  Processing race at: ', track_name)

    # Extract race table
    race_table <- page |>
      rvest::html_table(header = TRUE) |>
      purrr::pluck(3)

    # Clean and format data
    result <- race_table |>
      dplyr::rename(Car = `#`) |>
      dplyr::mutate(
        Season = as.integer(current_year),
        Race = as.integer(last_completed_race + which(new_links == link)),
        Car = stringr::str_remove(Car, '#'),
        Track = track_name,
        Name = race_name,
        Win = dplyr::if_else(Finish == 1, 1, 0)
      ) |>
      dplyr::left_join(
        track_info |> dplyr::select(Track, Length, Surface),
        by = 'Track'
      ) |>
      dplyr::select(
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
        Make,
        Pts,
        Laps,
        Led,
        Status,
        Team,
        S1,
        S2,
        Rating,
        Win,
        `Seg Points`
      )

    message('  Processed ', nrow(result), ' driver results')
    return(result)
  })

  # Combine and save
  if (nrow(new_results) > 0) {
    updated_data <- dplyr::bind_rows(existing_data, new_results)

    # Assign to correct object name and save
    assign(cfg$data_object, updated_data)
    save(
      list = cfg$data_object,
      file = cfg$data_file,
      compress = 'bzip2'
    )

    n_new_races <- dplyr::n_distinct(new_results$Race)
    n_new_results <- nrow(new_results)
    message(
      'Added ', n_new_races, ' new race(s) with ', n_new_results,
      ' total results'
    )
  } else {
    message('No new ', cfg$series_name, ' race data found')
  }

  invisible()
}
