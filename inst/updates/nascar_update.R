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
#' @param debug Logical. If TRUE, uses manual target year and race
#' @param target_year Numeric. Specify year when debug is TRUE
#' @param target_race Numeric. Specify race number when debug is TRUE
#' @noRd
update_nascar_data <- function(debug = FALSE, target_year = NULL, target_race = NULL) {
  if (debug && (is.null(target_year) || is.null(target_race))) {
    stop("When debug is TRUE, both target_year and target_race must be specified")
  }

  # Clear debug data files
  if (debug) { unlink('inst/extdata/debug/*') }
 
  # Add debug path logic
  get_file_path <- function(original_path, is_debug) {
    if (is_debug) {
      # Create debug directory if it doesn't exist
      dir.create("inst/extdata/debug", showWarnings = FALSE, recursive = TRUE)
      # Replace data/ with inst/extdata/debug/ in the path
      gsub("^data/", "inst/extdata/debug/", original_path)
    } else {
      original_path
    }
  }
  
  # Series configurations with debug paths
  series_config <- list(
    cup = list(
      base_url = "https://www.driveraverages.com/nascar/",
      data_file = get_file_path("data/cup_series.rda", debug),
      track_info = "inst/updates/cup_track_info.rda"
    ),
    xfinity = list(
      base_url = "https://www.driveraverages.com/nascar_xfinityseries/",
      data_file = get_file_path("data/xfinity_series.rda", debug),
      track_info = "inst/updates/xfinity_track_info.rda"
    ),
    truck = list(
      base_url = "https://www.driveraverages.com/nascar_truckseries/",
      data_file = get_file_path("data/truck_series.rda", debug),
      track_info = "inst/updates/truck_track_info.rda"
    )
  )
  
  # Helper function for page retry logic
  get_page_with_retry <- function(url) {
    attempts <- 0
    wait_time <- 3
    while (attempts < 5) {
      result <- tryCatch({
        read_html(url)
      }, error = function(e) {
        if (grepl('SSL connection timeout', e$message, ignore.case = TRUE)) {
          message(paste('SSL timeout occurred. Retrying in', wait_time, 'seconds...'))
          Sys.sleep(wait_time)
          wait_time <<- wait_time * 1.5
          return(NULL)
        } else {
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
      # "Updating Cup Series data..." or
      # "Updating Cup Series data... (DEBUG MODE)"
      paste(
        "\nUpdating", toupper(series_name), 
        "Series data...",
        if(debug) "(DEBUG MODE)" else ""
      )
    )
    
    # Load existing data from real path, not debug path
    real_data_file <- gsub("^inst/extdata/debug/", "data/", config$data_file)
    
    # Try to load the data, with error handling
    tryCatch({
      # Load the specific dataset based on series name
      if (series_name == "cup") {
        load(real_data_file)  # Loads cup_series
        existing_data <- cup_series
      } else if (series_name == "xfinity") {
        load(real_data_file)  # Loads xfinity_series
        existing_data <- xfinity_series
      } else if (series_name == "truck") {
        load(real_data_file)  # Loads truck_series
        existing_data <- truck_series
      }
    }, error = function(e) {
      # If file doesn't exist, create empty data frame with required columns
      message("No existing data found. Creating debug dataset...")
    })
    
    # Try to load track info, with error handling
    tryCatch({
      if (series_name == "cup") {
        load(config$track_info)  # Loads cup_track_info
        track_info_data <- cup_track_info
      } else if (series_name == "xfinity") {
        load(config$track_info)  # Loads xfinity_track_info
        track_info_data <- xfinity_track_info
      } else if (series_name == "truck") {
        load(config$track_info)  # Loads truck_track_info
        track_info_data <- truck_track_info
      }
    }, error = function(e) {
      message("No track info found. Proceeding without track data...")
      track_info_data <<- data.frame(
        Track = character(),
        Length = numeric(),
        Surface = character(),
        stringsAsFactors = FALSE
      )
    })
    
    # Determine where to start scraping
    if (debug) {
      current_year <- target_year
      current_race <- target_race
    } else {
      current_year <- max(existing_data$Season)
      current_race <- max(existing_data$Race[existing_data$Season == current_year])
    }
    
    # Get new race data
    season_url <- paste0(config$base_url, "year.php?yr_id=", current_year)
    
    new_links <- get_page_with_retry(season_url) |> 
      html_elements('div#Div2Nav ul a') |> 
      html_attr('href') |> 
      keep(~str_detect(., 'race.php?'))
    
    message(paste("Found", length(new_links), "total races"))
    message(paste("Processing races after race number:", current_race))
    
    # Only process races after current_race
    new_links <- new_links[(current_race + 1):length(new_links)]
    
    # Add check for empty links
    if (length(new_links) == 0) {
      message("No new races found to process")
      return()
    }
    
    # Process new races
    new_results <- map_dfr(new_links, function(link) {
      page <- get_page_with_retry(paste0(config$base_url, link))
      
      # Extract race details
      details <- page |> 
        html_element('td.td-left span.td-bold') |> 
        html_text2()
      
      parts <- str_split(details, '\n')[[1]]
      race_name <- parts[1]
      track_name <- parts[2]
      
      # message(paste("Race:", race_name))
      message(paste("Track:", track_name))
      
      # Get race data
      race <- page |> 
        html_table(header = TRUE) |> 
        pluck(3)
      
      # Process race results with consistent structure
      result <- race |>
        rename(Car = `#`) |> 
        mutate(
          Season = as.integer(current_year),
          Race = as.integer(
            current_race + seq_along(new_links)[which(new_links == link)]
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
          by = "Track"
        ) |> 
        # Then select columns in the right order
        select(
          Season, Race, Track, Name, Length, Surface,
          Finish, Start, Car, Driver, Team, Make,
          Pts, Laps, Led, Status, `Seg Points`,
          Rating, Win
        )
      
      message(paste("Processed", nrow(result), "results for this race\n"))
      return(result)
    })
    
    # Combine and save with proper race counting
    if (nrow(new_results) > 0) {
      if (debug) { existing_data <- NULL }
      updated_data <- bind_rows(existing_data, new_results)
      
      # Count unique races instead of rows
      n_new_races <- n_distinct(new_results$Race)
      
      # Save with appropriate name based on series
      if (series_name == "cup") {
        cup_series <- updated_data
        save(cup_series, file = config$data_file)
      } else if (series_name == "xfinity") {
        xfinity_series <- updated_data
        save(xfinity_series, file = config$data_file)
      } else if (series_name == "truck") {
        truck_series <- updated_data
        save(truck_series, file = config$data_file)
      }
      
      message(
        paste(
          "Added", n_new_races, "new races to", series_name, "series", 
          if(debug) "(saved to debug directory)" else ""
        )
      )
    } else {
      message(
        paste(
          "No new races found for", series_name, "series", 
          if(debug) "(DEBUG MODE)" else ""
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
update_nascar_data(debug = TRUE, target_year = 2024, target_race = 15)
# load('inst/extdata/debug/cup_series.rda')
# load('inst/extdata/debug/xfinity_series.rda')
load('inst/extdata/debug/truck_series.rda')