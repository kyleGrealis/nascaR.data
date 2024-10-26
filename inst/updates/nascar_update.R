library(tidyverse)
library(rvest)

#' Update NASCAR race data
#'
#' @param debug Logical. If TRUE, uses manual target year and race
#' @param target_year Numeric. Specify year when debug is TRUE
#' @param target_race Numeric. Specify race number when debug is TRUE
#' @noRd
update_nascar_data <- function(debug = FALSE, target_year = NULL, target_race = NULL) {

  # Add to beginning of function:
  if (debug && (is.null(target_year) || is.null(target_race))) {
    stop("When debug is TRUE, both target_year and target_race must be specified")
  }
    
  # Series configurations
  series_config <- list(
    cup = list(
      base_url = "https://www.driveraverages.com/nascar/",
      data_file = "data/cup_series.rda",
      track_info = "data/cup_track_info.rda"
    ),
    xfinity = list(
      base_url = "https://www.driveraverages.com/nascar_xfinityseries/",
      data_file = "data/xfinity_series.rda",
      track_info = "data/xfinity_track_info.rda"
    ),
    truck = list(
      base_url = "https://www.driveraverages.com/nascar_truckseries/",
      data_file = "data/truck_series.rda",
      track_info = "data/truck_track_info.rda"
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
    message(paste("\nUpdating", toupper(series_name), "Series data..."))
    
    # Load existing data
    load(config$data_file)
    load(config$track_info)
    
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
    
    # Only process races after current_race
    new_links <- new_links[(current_race + 1):length(new_links)]
    
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
      
      # Get race data
      race <- page |> 
        html_table(header = TRUE) |> 
        pluck(3)
      
      # Process race results
      result <- race |> 
        rename(Car = `#`) |> 
        mutate(
          Car = str_remove(Car, '#'),
          Season = current_year,
          Race = current_race + 1,
          Track = track_name,
          Name = race_name
        ) |> 
        mutate(Win = if_else(Finish == 1, 1, 0))
      
      # Merge track info
      track_info <- get(paste0(series_name, "_track_info"))
      result <- result |> 
        left_join(track_info, by = c("Track"))
      
      return(result)
    })
    
    # Combine and save
    if (nrow(new_results) > 0) {
      updated_data <- bind_rows(existing_data, new_results)
      save(updated_data, file = config$data_file)
      message(paste("Added", nrow(new_results), "new races to", series_name, "series"))
    } else {
      message("No new races found for", series_name, "series")
    }
  }
  
  # Update all series
  walk(names(series_config), ~update_series(.x, series_config[[.x]]))
}

# Usage example:
# Normal update mode:
update_nascar_data()

# Debug mode:
# update_nascar_data(debug = TRUE, target_year = 2024, target_race = 5)