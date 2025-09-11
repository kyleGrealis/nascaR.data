# nascaR.data 2.2.3

+ Adding season updates for all divisions


# nascaR.data 2.2.2

> Deprecating the `weekly` branch! Weekly race results will be added to the `main` branch. CRAN-stable version is available via CRAN:
```r
install.packages("nascaR.data")
remotes::install_github("kyleGrealis/nascaR.data") # please do not use "@weekly"
```

## Major Enhancement: Complete Fuzzy Matching System Overhaul

### New Features
- **Interactive driver/team/manufacturer selection**: When multiple matches are found, users can now select from a numbered list
- **Intelligent fuzzy matching**: Dramatically improved search algorithm that handles typos, partial names, and word boundaries
  - `find_driver("kyle")` → returns Kyle Busch, Kyle Larson, Kyle Petty, etc.
  - `find_team("gibbs")` → finds Joe Gibbs Racing
  - `find_driver("earnhart")` → correctly finds Earnhardt family drivers
- **Flexible series input**: All functions now accept both character strings AND data frames
  - `get_driver_info("kyle", "cup")` ✓
  - `get_driver_info("kyle", "Cup Series")` ✓  
  - `get_driver_info("kyle", cup_series)` ✓
- **Smart string matching**: Handles variations like "cup", "Cup Series", "xfinity", "Xfinity Series" automatically

### Technical Improvements
- **Consolidated codebase**: Replaced three separate fuzzy matching files with one unified system
- **Priority-based matching**: Exact matches > starts with > contains > word boundaries > fuzzy similarity
- **Non-interactive mode**: Dashboard/script developers can set `interactive = FALSE` to get list returns
- **Removed dependency on problematic Levenshtein distance calculations**
- **Eliminated interactive prompts that broke in non-interactive environments**

### User Experience
- **Typo tolerance**: Common misspellings now find correct matches
- **One-step workflow**: Search and select in the same function call
- **Clear feedback**: Better messaging when multiple options are available

### Breaking Changes
- None! All existing function calls continue to work as before
- New `interactive` parameter defaults to `TRUE` for better user experience

### Bug Fixes
- Fixed fuzzy matching returning irrelevant results
- Resolved cases where obvious matches weren't found due to strict string matching
- Eliminated interactive readline prompts that failed in scripts and R Markdown



# nascaR.data 2.2.1

## Enhancements
* Added missing races. The Cup Series season finale was omitted for a number of years from 2002 to 2022. Thank you to Nick Triplett for the catching the mistake!
* `Seg Points` has been removed. Instead, `S1` & `S2` variables correspond to the driver's finishing position during each segment.
* Updated missing track information (length, surface type) for 32 Cup races with varying years, mostly pre-2000s.

## Documentation
* Updated `S1` & `S2` documentation.


# nascar.data 2.1.0

## Enhancements
* `dev` branch will be updated with the most recent racing results every Monday at 10AM during the race season (February through November).
* New `get_*_info()` functions provide summary statistics on a by-race, season, or career format.
* Fuzzy matching has been included to search across the database in the respective series

## Bug Fixes
* *None*

## Documentation
* Updated README and vignette reflecting package changes.

## Internal Changes
* Error handling for placeholder race. The "DriverAverages.com" site will sometimes have one row for the upcoming race. This has routinely caused issues for the weekly scraping functions accidentally "recognizing" that as having been a completed race. The oversight has been addressed by removing that (essentially) blank row, decreasing the index, and continuing to scrape for new race data.
* Fuzzy finding is used within the functions returning the driver, team, or manufacturer information. There is room for improvement: "Chris Bell" would find "Christopher Bell" instead of "Chris Miller" as it does now. Improvements would include a stronger focus on the driver or owner's last name, but this will take some trial and error to really dial in.


---

# nascaR.data 2.0.0

* *BREAKING* CHANGES:
    * Web data scraped using R packages & removed existing Python scripts.
    * Reduced number of datasets for Cup, Xfinity, & Truck series results by series only.
* Integrated GitHub Actions for auto-updating all series results 

# nascaR.data 1.0.0

* Initial CRAN submission.
