#' Update NASCAR race data
#' 
#' This function is designed to pull the last value of Season and Race from the
#' most-recent scrape as a starting point for new data. If the function is ran in
#' debug mode, the output is saved to \code{inst/extdata/debug}, otherwise it is 
#' appended to the full data for the respective series.
#' 
#' Debug mode allows to review scraping process and output of new races before 
#' configuring automated GitHub Actions.
#'
#' @param debug Logical. Enables debug mode to allow safe testing of data updates 
#' without modifying production datasets.
#' @param target_year Numeric. (Debug mode only) Specifies the year to scrape manually.
#' @param target_race Numeric. (Debug mode only) Specifies the race number to scrape manually.

#' @noRd
update_nascar_data <- function(debug = FALSE, target_year = NULL, target_race = NULL) {

  # Storage directories
  debug_dir <- 'inst/extdata/debug'
  data_dir <- 'data'
  updates_dir <- 'inst/updates'

  
  if (debug && (is.null(target_year) || is.null(target_race))) {
    stop('When debug is TRUE, both target_year and target_race must be specified')
  }

  # Clear debug data files
  if (debug) { unlink('inst/extdata/debug/*') }
 
  # Helper function to build file paths based on debug mode
  get_file_path <- function(original_path, is_debug) {
    if (is_debug) {
      # Create debug directory if it doesn't exist
      dir.create(debug_dir, showWarnings = FALSE, recursive = TRUE)
      # Replace data/ with inst/extdata/debug/ in the path
      gsub(paste0('^', data_dir, '/'), paste0(debug_dir, '/'), original_path)
    } else {
      original_path
    }
  }
  
  ### Series Configuration ###
  # Define URLs and file paths for each series, including debug versions.
  series_config <- list(
    cup = list(
      base_url = 'https://www.driveraverages.com/nascar/',
      data_file = get_file_path(file.path(data_dir, 'cup_series.rda'), debug),
      track_info = file.path(updates_dir, 'cup_track_info.rda')
    ),
    xfinity = list(
      base_url = 'https://www.driveraverages.com/nascar_xfinityseries/',
      data_file = get_file_path(file.path(data_dir, 'xfinity_series.rda'), debug),
      track_info = file.path(updates_dir, 'xfinity_track_info.rda')
    ),
    truck = list(
      base_url = 'https://www.driveraverages.com/nascar_truckseries/',
      data_file = get_file_path(file.path(data_dir, 'truck_series.rda'), debug),
      track_info = file.path(updates_dir, 'truck_track_info.rda')
    )
  )
  
  
  # Helper function for page retry logic
  get_page_with_retry <- function(url) {
    attempts <- 0
    wait_time <- 3
    while (attempts < 5) {
      result <- tryCatch({
        # Attempt to read the page
        read_html(url)
      }, error = function(e) {
        if (grepl('SSL connection timeout', e$message, ignore.case = TRUE)) {
          # Retry on SSL timeouts with exponential backoff
          message(paste('SSL timeout occurred. Retrying in', wait_time, 'seconds...'))
          Sys.sleep(wait_time)
          wait_time <<- wait_time * 1.5
          return(NULL)
        } else {
          # Stop for unexpected errors
          stop(e)
        }
      })
      if (!is.null(result)) return(result)
      attempts <- attempts + 1
    }
    stop('Failed to retrieve page after 5 attempts.')
  }
 
  # Update function for each series
  update_series <- function(series_name, config) {
    message(
      # 'Updating Cup Series data...' or
      # 'Updating Cup Series data... (DEBUG MODE)'
      paste(
        '\nUpdating', toupper(series_name), 
        'Series data...',
        if(debug) '(DEBUG MODE)' else ''
      )
    )
    
    # Load existing data from real path, not debug path
    real_data_file <- gsub('^inst/extdata/debug/', 'data/', config$data_file)
    
    # Load existing data. If the file doesn't exist, a new dataset will be created.
    tryCatch({
      # Load the specific dataset based on series name
      if (series_name == 'cup') {
        load(real_data_file)
        existing_data <- cup_series
      } else if (series_name == 'xfinity') {
        load(real_data_file)
        existing_data <- xfinity_series
      } else if (series_name == 'truck') {
        load(real_data_file)
        existing_data <- truck_series
      }
    }, error = function(e) {
      # If data doesn't exist, initialize an empty dataset.
      message('No existing data found. Creating debug dataset...')
    })
    
    # Try to load track info, with error handling
    tryCatch({
      if (series_name == 'cup') {
        load(config$track_info)  # Loads cup_track_info
        track_info_data <- cup_track_info
      } else if (series_name == 'xfinity') {
        load(config$track_info)  # Loads xfinity_track_info
        track_info_data <- xfinity_track_info
      } else if (series_name == 'truck') {
        load(config$track_info)  # Loads truck_track_info
        track_info_data <- truck_track_info
      }
    }, error = function(e) {
      message('No track info found. Proceeding without track data...')
      track_info_data <<- data.frame(
        Track = character(),
        Length = numeric(),
        Surface = character(),
        stringsAsFactors = FALSE
      )
    })

    # browser()
    
    # Determine where to start scraping
    # current_year = year as determined by Sys.Date()
    # last_completed_race = number index of race
    if (debug) {
      current_year <- target_year
      last_completed_race <- target_race
    } else {
      # current_year <- 2024  # hard-coding year for debugging
      current_year <- as.numeric(format(Sys.Date(), '%Y'))
      last_completed_race <- max(existing_data$Race[existing_data$Season == current_year])
    }

    # Add check for being off-season or site not updated
    if (is.infinite(last_completed_race) || is.na(last_completed_race) || last_completed_race < 1) {
      message(
        paste(
          str_to_title(series_name), 
          'Series is up-to-date. It may be off-season right now.'
        )
      )
      return(NULL)
    }

    ###################################################################################
    # DriverAverages.com will sometimes add 1 row for the next week's race. This has 
    # created issues for this script in the past where this function "thinks" that
    # there's a race that occurred and skips without processing new data. This check
    # ensures that new race data can be processed as intended.

    # Drop placeholder rows added for the next week's race.
    # These rows cause issues when processing new data because they aren't real results.
    if(
      nrow(
        existing_data |> 
          filter(Season == current_year, Race == last_completed_race)
      ) == 1
    ) {
      # Drop place-holder row signifying that the race wasn't actually completed 
      # and proceed with processing. Also, decrease the last_completed_race index
      # by 1 so it reflects the true index for the last completed race.
      existing_data <- existing_data |> 
        filter(row_number() <= n() - 1)

      last_completed_race = last_completed_race - 1

      message(
        '\n\nNOTE: 1 row dropped from existing data & index updated. See script!!!\n\n'
      )
    }
    ###################################################################################
    ###################################################################################
    
    # Get new race data
    season_url <- paste0(config$base_url, 'year.php?yr_id=', current_year)
    
    new_links <- get_page_with_retry(season_url) |> 
      html_elements('div#Div2Nav ul a') |> 
      html_attr('href') |> 
      keep(~str_detect(., 'race.php?'))
    
    message(paste('Found', length(new_links), 'total races'))
    message(paste('Processing races after race number:', last_completed_race))

    # Add check for being up to date
    if (length(new_links) <= last_completed_race) {
      message(
        paste(
          # Cup Series is up to date with 20 races
          str_to_title(series_name), 'Series is up-to-date with', 
          last_completed_race, 'races!'
        )
      )
      return()
    }
    
    # Only process races after last_completed_race
    new_links <- new_links[(last_completed_race + 1):length(new_links)]
    
    # Add check for empty links
    if (length(new_links) == 0) {
      message('No new races found to process')
      return()
    }
    
    # Process new race data
    new_results <- map_dfr(new_links, function(link) {
      page <- get_page_with_retry(paste0(config$base_url, link))
      
      # Extract race & track details
      details <- page |> 
        html_element('td.td-left span.td-bold') |> 
        html_text2()
      
      parts <- str_split(details, '\n')[[1]]
      race_name <- parts[1]
      track_name <- parts[2]
      
      # message(paste('Race:', race_name))
      message(paste('Track:', track_name))
      
      # Extract race table and clean data
      race <- page |> 
        html_table(header = TRUE) |> 
        pluck(3)
      
      result <- race |>
        rename(Car = `#`) |> 
        mutate(
          Season = as.integer(current_year),
          Race = as.integer(
            last_completed_race + seq_along(new_links)[which(new_links == link)]
          ),
          Car = str_remove(Car, '#'),
          Track = track_name,
          Name = race_name,
          `Seg Points` = S1 + S2,
          Win = if_else(Finish == 1, 1, 0)
        )
      
      # Merge track info first
      result <- result |> 
        left_join(
          track_info_data |> select(Track, Length, Surface),
          by = 'Track'
        ) |> 
        # Then select columns in the right order
        select(
          Season, Race, Track, Name, Length, Surface,
          Finish, Start, Car, Driver, Team, Make,
          Pts, Laps, Led, Status, `Seg Points`,
          Rating, Win
        )
      
      message(paste('Processed', nrow(result), 'results for this race\n'))
      return(result)
    })
    
    # Combine and save with proper race counting
    if (nrow(new_results) > 0) {
      if (debug) { existing_data <- NULL }
      updated_data <- bind_rows(existing_data, new_results)
      
      # Count unique races instead of rows
      n_new_races <- n_distinct(new_results$Race)
      
      # Save with appropriate name based on series
      if (series_name == 'cup') {
        cup_series <- updated_data
        save(cup_series, file = config$data_file)
      } else if (series_name == 'xfinity') {
        xfinity_series <- updated_data
        save(xfinity_series, file = config$data_file)
      } else if (series_name == 'truck') {
        truck_series <- updated_data
        save(truck_series, file = config$data_file)
      }
      
      message(
        paste(
          'Added', n_new_races, 'new races to', series_name, 'series', 
          if(debug) '(saved to debug directory)' else ''
        )
      )
    } else {
      message(
        paste(
          'No new races found for', series_name, 'series', 
          if(debug) '(DEBUG MODE)' else ''
        )
      )
    }
  }
  
  # Update all series
  walk(names(series_config), ~update_series(.x, series_config[[.x]]))
 }

# Usage example:
# Normal update mode:
# update_nascar_data()

# Debug mode:
# update_nascar_data(debug = TRUE, target_year = 2024, target_race = 15)
