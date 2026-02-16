# nascaR.data 3.0.1

* **Removed disk cache.** The on-disk cache from v3.0.0 silently
  served stale data across R sessions. `load_series()` now downloads
  fresh data from R2 once per session (in-memory cache only).


# nascaR.data 3.0.0

## Breaking Changes

* **Bundled data removed.** The `cup_series`, `xfinity_series`, and
  `truck_series` datasets are no longer shipped with the package. All data
  is now served from Cloudflare R2. Use `load_series()` to access data:
  ```r
  cup <- load_series("cup")
  nxs <- load_series("nxs")
  truck <- load_series("truck")
  ```

* **`arrow` is now a required dependency** (moved from Suggests to Imports)
  since all data access goes through parquet files on R2.

* **`"xfinity"` series renamed to `"nxs"`.** The second-tier series has changed
  title sponsors four times: Busch (1984-2007), Nationwide (2008-2014), Xfinity
  (2015-2025), and O'Reilly Auto Parts (2026-present). The identifier `"nxs"`
  is NASCAR's own sponsor-neutral abbreviation, so it will never go stale.
  Replace `load_series("xfinity")` with `load_series("nxs")`.

* **`find_driver()`, `find_team()`, `find_manufacturer()` removed.** The
  `get_*_info()` functions already include fuzzy matching and return actual data.
  Use `get_driver_info("bell")` instead of `find_driver("bell")`.

* **`data("cup_series")` no longer works.** Replace all `data()` calls with
  `load_series()`. The old lazy-loaded dataset names are gone.

## New Features

* **`load_series()`**: Downloads series data from R2 and caches in memory.
  Subsequent calls within the same session are instant. Use
  `refresh = TRUE` to force re-download.

* **`clear_cache()`**: New exported function to reset the in-memory cache.

* **R2-canonical pipeline**: The weekly GitHub Actions scraper now reads
  existing data from R2, appends new races, and uploads back to R2.
  No local rda files are generated or committed.

## Improvements

* Migrated from `httr` to `httr2` for HTTP requests. The scraper now
  uses `httr2::request()` with built-in retry logic (`req_retry()`).

* Consolidated web scraping with `httr2`, `imap_dfr()` indexing, explicit
  column type coercion, placeholder detection, and empty table guards.

* Data validation framework for schema, integrity, and value checks.

* Code quality enforced with `styler` and `lintr` (zero warnings).

* All `stop()` calls in package code replaced with `rlang::abort()`.


# nascaR.data 2.2.3

* Adding season updates for all divisions


# nascaR.data 2.2.2

Deprecating the `weekly` branch! Weekly race results will be added to the `main` branch. CRAN-stable version is available via CRAN:
```r
install.packages("nascaR.data")
remotes::install_github("kyleGrealis/nascaR.data") # please do not use "@weekly"
```

## Major Enhancement: Complete Fuzzy Matching System Overhaul

### New Features

* **Interactive driver/team/manufacturer selection**: When multiple matches are found, users can now select from a numbered list

* **Intelligent fuzzy matching**: Dramatically improved search algorithm that handles typos, partial names, and word boundaries
  * `find_driver("kyle")` -> returns Kyle Busch, Kyle Larson, Kyle Petty, etc.
  * `find_team("gibbs")` -> finds Joe Gibbs Racing
  * `find_driver("earnhart")` -> correctly finds Earnhardt family drivers

* **Flexible series input**: All functions now accept both character strings AND data frames
  * `get_driver_info("kyle", "cup")` check
  * `get_driver_info("kyle", "Cup Series")` check
  * `get_driver_info("kyle", cup_series)` check

* **Smart string matching**: Handles variations like "cup", "Cup Series", "xfinity", "Xfinity Series" automatically

### Technical Improvements

* **Consolidated codebase**: Replaced three separate fuzzy matching files with one unified system

* **Priority-based matching**: Exact matches > starts with > contains > word boundaries > fuzzy similarity

* **Non-interactive mode**: Dashboard/script developers can set `interactive = FALSE` to get list returns

* **Removed dependency on problematic Levenshtein distance calculations**

* **Eliminated interactive prompts that broke in non-interactive environments**

### User Experience

* **Typo tolerance**: Common misspellings now find correct matches

* **One-step workflow**: Search and select in the same function call

* **Clear feedback**: Better messaging when multiple options are available

### Breaking Changes

* None! All existing function calls continue to work as before

* New `interactive` parameter defaults to `TRUE` for better user experience

### Bug Fixes

* Fixed fuzzy matching returning irrelevant results

* Resolved cases where obvious matches weren't found due to strict string matching

* Eliminated interactive readline prompts that failed in scripts and R Markdown


# nascaR.data 2.2.1

## Enhancements

* Added missing races. The Cup Series season finale was omitted for a number of years from 2002 to 2022. Thank you to Nick Triplett for the catching the mistake!

* `Seg Points` has been removed. Instead, `S1` & `S2` variables correspond to the driver's finishing position during each segment.

* Updated missing track information (length, surface type) for 32 Cup races with varying years, mostly pre-2000s.

## Documentation

* Updated `S1` & `S2` documentation.


# nascaR.data 2.1.0

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


# nascaR.data 2.0.0

* *BREAKING* CHANGES:
  * Web data scraped using R packages & removed existing Python scripts.
  * Reduced number of datasets for Cup, Xfinity, & Truck series results by series only.

* Integrated GitHub Actions for auto-updating all series results


# nascaR.data 1.0.0

* Initial CRAN submission.
