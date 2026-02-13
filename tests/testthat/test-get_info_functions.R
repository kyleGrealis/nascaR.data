# Test get_*_info functions (always use interactive = FALSE for tests)

# Mock data for CRAN-safe tests
mock_cup_data <- data.frame(
  Season = rep(c(2023L, 2024L), each = 4),
  Race = rep(1:2, each = 2, times = 2),
  Track = "Daytona International Speedway",
  Name = "Daytona 500",
  Length = 2.5,
  Surface = "Paved",
  Finish = c(1L, 3L, 2L, 5L, 4L, 1L, 3L, 2L),
  Start = c(5L, 10L, 3L, 15L, 8L, 1L, 6L, 12L),
  Car = c("24", "3", "24", "11", "24", "3", "24", "11"),
  Driver = c(
    "Jeff Gordon", "Dale Earnhardt",
    "Jeff Gordon", "Denny Hamlin",
    "Jeff Gordon", "Dale Earnhardt",
    "Jeff Gordon", "Denny Hamlin"
  ),
  Team = c(
    "Hendrick Motorsports", "RCR",
    "Hendrick Motorsports", "Joe Gibbs Racing",
    "Hendrick Motorsports", "RCR",
    "Hendrick Motorsports", "Joe Gibbs Racing"
  ),
  Make = c(
    "Chevrolet", "Chevrolet",
    "Chevrolet", "Toyota",
    "Chevrolet", "Chevrolet",
    "Chevrolet", "Toyota"
  ),
  Pts = c(40L, 35L, 39L, 30L, 33L, 40L, 36L, 37L),
  Laps = rep(200L, 8),
  Led = c(50L, 10L, 30L, 5L, 20L, 60L, 15L, 25L),
  Status = "Running",
  S1 = NA_integer_,
  S2 = NA_integer_,
  Rating = NA_real_,
  Win = c(1L, 0L, 0L, 0L, 0L, 1L, 0L, 0L),
  stringsAsFactors = FALSE
)

# get_driver_info tests ----

test_that("get_driver_info returns summary for known driver", {
  skip_on_cran()
  skip_if_offline()

  expect_message(
    result <- get_driver_info("Richard Petty", interactive = FALSE),
    "Driver: Richard Petty"
  )
  expect_s3_class(result, "data.frame")
  expect_true("Series" %in% names(result))
  expect_true("Career Races" %in% names(result))
  expect_true("Wins" %in% names(result))
})

test_that("get_driver_info returns correct type options", {
  skip_on_cran()
  skip_if_offline()

  # Summary type
  summary_result <- get_driver_info(
    "Jeff Gordon",
    type = "summary",
    interactive = FALSE
  )
  expect_s3_class(summary_result, "data.frame")
  expect_true("Career Races" %in% names(summary_result))

  # Season type
  season_result <- get_driver_info(
    "Jeff Gordon",
    type = "season",
    interactive = FALSE
  )
  expect_s3_class(season_result, "data.frame")
  expect_true("Season" %in% names(season_result))
  expect_true("Races" %in% names(season_result))

  # All type
  all_result <- get_driver_info(
    "Jeff Gordon",
    type = "all",
    interactive = FALSE
  )
  expect_s3_class(all_result, "data.frame")
  expect_true("Driver" %in% names(all_result))
  expect_true(all(all_result$Driver == "Jeff Gordon"))
})

test_that("get_driver_info filters by series correctly", {
  skip_on_cran()
  skip_if_offline()

  cup_result <- get_driver_info(
    "Dale Earnhardt",
    series = "cup",
    interactive = FALSE
  )
  expect_s3_class(cup_result, "data.frame")
  expect_true(all(cup_result$Series == "Cup"))
})

test_that("get_driver_info returns NULL for non-existent driver", {
  skip_on_cran()
  skip_if_offline()

  expect_message(
    result <- get_driver_info("ZZZ_NonExistent", interactive = FALSE),
    "No drivers found"
  )
  expect_null(result)
})

test_that("get_driver_info validates type parameter", {
  expect_error(
    get_driver_info("Jeff Gordon", type = "invalid", interactive = FALSE),
    "Invalid type"
  )
})

test_that("get_driver_info validates NULL inputs", {
  expect_error(
    get_driver_info(NULL),
    "Please enter correct values"
  )
  expect_error(
    get_driver_info("Jeff Gordon", series = NULL),
    "Please enter correct values"
  )
  expect_error(
    get_driver_info("Jeff Gordon", type = NULL),
    "Please enter correct values"
  )
})

test_that("get_driver_info handles fuzzy matching", {
  skip_on_cran()
  skip_if_offline()

  # Test with typo - will find multiple Earnhardts
  # In non-interactive mode, uses first match
  expect_message(
    result <- get_driver_info("earnhart", interactive = FALSE),
    "Multiple drivers found"
  )
  expect_s3_class(result, "data.frame")
  # Should successfully return data for an Earnhardt (whichever is first)
  expect_true(nrow(result) > 0)
})

# Mocked tests (CRAN-safe) ----

test_that("get_driver_info works with mocked data (CRAN-safe)", {
  local_mocked_bindings(
    load_series = function(series, refresh = FALSE) mock_cup_data
  )

  result <- get_driver_info(
    "Jeff Gordon",
    series = "cup", interactive = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true("Wins" %in% names(result))
  expect_equal(result$Wins, 1)
  expect_true("Series" %in% names(result))
  expect_equal(result$Series, "Cup")
})

test_that("get_driver_info type = season works with mocked data", {
  local_mocked_bindings(
    load_series = function(series, refresh = FALSE) mock_cup_data
  )

  result <- get_driver_info(
    "Jeff Gordon",
    series = "cup", type = "season", interactive = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true("Season" %in% names(result))
  expect_true("Races" %in% names(result))
  expect_equal(nrow(result), 2)
})

test_that("get_driver_info type = all works with mocked data", {
  local_mocked_bindings(
    load_series = function(series, refresh = FALSE) mock_cup_data
  )

  result <- get_driver_info(
    "Jeff Gordon",
    series = "cup", type = "all", interactive = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true("Driver" %in% names(result))
  expect_true(all(result$Driver == "Jeff Gordon"))
  expect_equal(nrow(result), 4)
})

test_that("get_driver_info type is case-insensitive", {
  local_mocked_bindings(
    load_series = function(series, refresh = FALSE) mock_cup_data
  )

  result <- get_driver_info(
    "Jeff Gordon",
    series = "cup", type = "Summary", interactive = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true("Career Races" %in% names(result))
})

test_that("get_driver_info returns NULL for empty string input", {
  local_mocked_bindings(
    load_series = function(series, refresh = FALSE) mock_cup_data
  )

  expect_message(
    result <- get_driver_info("", interactive = FALSE),
    "No drivers found"
  )
  expect_null(result)
})

test_that("get_driver_info returns NULL for NA input", {
  local_mocked_bindings(
    load_series = function(series, refresh = FALSE) mock_cup_data
  )

  expect_message(
    result <- get_driver_info(NA, interactive = FALSE),
    "No drivers found"
  )
  expect_null(result)
})

test_that("get_team_info works with mocked data", {
  local_mocked_bindings(
    load_series = function(series, refresh = FALSE) mock_cup_data
  )

  result <- get_team_info(
    "Hendrick Motorsports",
    series = "cup", interactive = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true("# of Drivers" %in% names(result))
  expect_true("Wins" %in% names(result))
})

test_that("get_team_info type = season works with mocked data", {
  local_mocked_bindings(
    load_series = function(series, refresh = FALSE) mock_cup_data
  )

  result <- get_team_info(
    "Hendrick Motorsports",
    series = "cup",
    type = "season",
    interactive = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true("Season" %in% names(result))
  expect_true("# of Drivers" %in% names(result))
})

test_that("get_manufacturer_info works with mocked data", {
  local_mocked_bindings(
    load_series = function(series, refresh = FALSE) mock_cup_data
  )

  result <- get_manufacturer_info(
    "Chevrolet",
    series = "cup", interactive = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true("Wins" %in% names(result))
  expect_true("Races" %in% names(result))
})

test_that("get_manufacturer_info type = season works with mocked data", {
  local_mocked_bindings(
    load_series = function(series, refresh = FALSE) mock_cup_data
  )

  result <- get_manufacturer_info(
    "Chevrolet",
    series = "cup",
    type = "season",
    interactive = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true("Season" %in% names(result))
  expect_true("Races" %in% names(result))
})

test_that("get_series_data works with data frame input", {
  df <- data.frame(Driver = "Test", Finish = 1L)
  result <- nascaR.data:::get_series_data(df)
  expect_true("Series" %in% names(result))
  expect_equal(result$Series, "Custom")
})

test_that("get_series_data errors for invalid series string", {
  expect_error(
    nascaR.data:::get_series_data("formula1"),
    "Unknown series"
  )
})

test_that("get_series_data errors for non-string non-df", {
  expect_error(
    nascaR.data:::get_series_data(42),
    "character string or a data frame"
  )
})

# get_team_info tests ----

test_that("get_team_info returns summary for known team", {
  skip_on_cran()
  skip_if_offline()

  expect_message(
    result <- get_team_info("Hendrick Motorsports", interactive = FALSE),
    "Team: Hendrick Motorsports"
  )
  expect_s3_class(result, "data.frame")
  expect_true("Series" %in% names(result))
  expect_true("Career Races" %in% names(result))
  expect_true("# of Drivers" %in% names(result))
})

test_that("get_team_info returns correct type options", {
  skip_on_cran()
  skip_if_offline()

  # Summary type
  summary_result <- get_team_info(
    "Joe Gibbs Racing",
    type = "summary",
    interactive = FALSE
  )
  expect_s3_class(summary_result, "data.frame")
  expect_true("Career Races" %in% names(summary_result))

  # Season type
  season_result <- get_team_info(
    "Joe Gibbs Racing",
    type = "season",
    interactive = FALSE
  )
  expect_s3_class(season_result, "data.frame")
  expect_true("Season" %in% names(season_result))
  expect_true("# of Drivers" %in% names(season_result))

  # All type
  all_result <- get_team_info(
    "Joe Gibbs Racing",
    type = "all",
    interactive = FALSE
  )
  expect_s3_class(all_result, "data.frame")
  expect_true("Team" %in% names(all_result))
})

test_that("get_team_info filters by series correctly", {
  skip_on_cran()
  skip_if_offline()

  result <- get_team_info(
    "Hendrick Motorsports",
    series = "cup",
    interactive = FALSE
  )
  expect_s3_class(result, "data.frame")
  expect_true(all(result$Series == "Cup"))
})

test_that("get_team_info returns NULL for non-existent team", {
  skip_on_cran()
  skip_if_offline()

  expect_message(
    result <- get_team_info("ZZZ_NonExistent_Team", interactive = FALSE),
    "No teams found"
  )
  expect_null(result)
})

test_that("get_team_info validates type parameter", {
  expect_error(
    get_team_info("Hendrick Motorsports", type = "invalid", interactive = FALSE),
    "Invalid type"
  )
})

test_that("get_team_info validates NULL inputs", {
  expect_error(
    get_team_info(NULL),
    "Please enter correct values"
  )
})

# get_manufacturer_info tests ----

test_that("get_manufacturer_info returns summary for known manufacturer", {
  skip_on_cran()
  skip_if_offline()

  expect_message(
    result <- get_manufacturer_info("Chevrolet", interactive = FALSE),
    "Manufacturer: Chevrolet"
  )
  expect_s3_class(result, "data.frame")
  expect_true("Series" %in% names(result))
  expect_true("Races" %in% names(result))
  expect_true("Wins" %in% names(result))
})

test_that("get_manufacturer_info returns correct type options", {
  skip_on_cran()
  skip_if_offline()

  # Summary type
  summary_result <- get_manufacturer_info(
    "Ford",
    type = "summary",
    interactive = FALSE
  )
  expect_s3_class(summary_result, "data.frame")
  expect_true("Races" %in% names(summary_result))

  # Season type
  season_result <- get_manufacturer_info(
    "Ford",
    type = "season",
    interactive = FALSE
  )
  expect_s3_class(season_result, "data.frame")
  expect_true("Season" %in% names(season_result))

  # All type
  all_result <- get_manufacturer_info(
    "Ford",
    type = "all",
    interactive = FALSE
  )
  expect_s3_class(all_result, "data.frame")
  expect_true("Make" %in% names(all_result))
})

test_that("get_manufacturer_info filters by series correctly", {
  skip_on_cran()
  skip_if_offline()

  result <- get_manufacturer_info(
    "Toyota",
    series = "cup",
    interactive = FALSE
  )
  expect_s3_class(result, "data.frame")
  expect_true(all(result$Series == "Cup"))
})

test_that("get_manufacturer_info returns NULL for non-existent manufacturer", {
  skip_on_cran()
  skip_if_offline()

  expect_message(
    result <- get_manufacturer_info("ZZZ_NonExistent", interactive = FALSE),
    "No manufacturers found"
  )
  expect_null(result)
})

test_that("get_manufacturer_info validates type parameter", {
  expect_error(
    get_manufacturer_info("Toyota", type = "invalid", interactive = FALSE),
    "Invalid type"
  )
})

test_that("get_manufacturer_info validates NULL inputs", {
  expect_error(
    get_manufacturer_info(NULL),
    "Please enter correct values"
  )
})

# Edge cases and integration tests ----

test_that("get_*_info functions handle all series option", {
  skip_on_cran()
  skip_if_offline()

  driver_all <- get_driver_info(
    "Dale Earnhardt Jr.",
    series = "all",
    interactive = FALSE
  )
  expect_s3_class(driver_all, "data.frame")
  # Should have multiple series
  expect_gte(nrow(driver_all), 1)

  team_all <- get_team_info(
    "Joe Gibbs Racing",
    series = "all",
    interactive = FALSE
  )
  expect_s3_class(team_all, "data.frame")

  mfg_all <- get_manufacturer_info(
    "Chevrolet",
    series = "all",
    interactive = FALSE
  )
  expect_s3_class(mfg_all, "data.frame")
})

test_that("get_*_info return reasonable statistics", {
  skip_on_cran()
  skip_if_offline()

  # Get Richard Petty's stats (known legendary driver)
  petty <- get_driver_info("Richard Petty", interactive = FALSE)

  # Richard Petty should have many wins
  expect_true(sum(petty$Wins) > 100)

  # Check for reasonable average finish
  expect_true(all(petty$`Avg Finish` > 0))
  expect_true(all(petty$`Avg Finish` < 50))
})
