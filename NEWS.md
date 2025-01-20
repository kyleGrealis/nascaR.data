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
* Fuzzing finding is used within the functions returning the driver, team, or manufacturer information. There is room for improvement: "Chris Bell" would find "Christopher Bell" instead of "Chris Miller" as it does now. Improvements would include a stronger focus on the driver or owner's last name, but this will take some trial and error to really dial in.


---

# nascaR.data 2.0.0

* *BREAKING* CHANGES:
    * Web data scraped using R packages & removed existing Python scripts.
    * Reduced number of datasets for Cup, Xfinity, & Truck series results by series only.
* Integrated GitHub Actions for auto-updating all series results 

# nascaR.data 1.0.0

* Initial CRAN submission.
