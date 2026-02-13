# Test get_*_info functions (always use interactive = FALSE for tests)

# get_driver_info tests ----

test_that("get_driver_info returns summary for known driver", {
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
  cup_result <- get_driver_info(
    "Dale Earnhardt",
    series = "cup",
    interactive = FALSE
  )
  expect_s3_class(cup_result, "data.frame")
  expect_true(all(cup_result$Series == "Cup"))
})

test_that("get_driver_info returns NULL for non-existent driver", {
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

# get_team_info tests ----

test_that("get_team_info returns summary for known team", {
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
  result <- get_team_info(
    "Hendrick Motorsports",
    series = "cup",
    interactive = FALSE
  )
  expect_s3_class(result, "data.frame")
  expect_true(all(result$Series == "Cup"))
})

test_that("get_team_info returns NULL for non-existent team", {
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
  result <- get_manufacturer_info(
    "Toyota",
    series = "cup",
    interactive = FALSE
  )
  expect_s3_class(result, "data.frame")
  expect_true(all(result$Series == "Cup"))
})

test_that("get_manufacturer_info returns NULL for non-existent manufacturer", {
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
  # Get Richard Petty's stats (known legendary driver)
  petty <- get_driver_info("Richard Petty", interactive = FALSE)

  # Richard Petty should have many wins
  expect_true(sum(petty$Wins) > 100)

  # Check for reasonable average finish
  expect_true(all(petty$`Avg Finish` > 0))
  expect_true(all(petty$`Avg Finish` < 50))
})
