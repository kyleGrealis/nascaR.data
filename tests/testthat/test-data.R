# Test data loading from R2 and structure validation

test_that("load_series() returns cup data with correct structure", {
  skip_on_cran()
  skip_if_offline()

  cup <- load_series("cup")

  expect_s3_class(cup, "data.frame")
  expect_true(nrow(cup) > 0)

  expected_cols <- c(
    "Season", "Race", "Track", "Name", "Length", "Surface",
    "Finish", "Start", "Car", "Driver", "Team", "Make",
    "Pts", "Laps", "Led", "Status", "Win"
  )
  expect_true(all(expected_cols %in% names(cup)))
})

test_that("load_series() returns xfinity data with correct structure", {
  skip_on_cran()
  skip_if_offline()

  xfinity <- load_series("xfinity")

  expect_s3_class(xfinity, "data.frame")
  expect_true(nrow(xfinity) > 0)

  expected_cols <- c(
    "Season", "Race", "Track", "Name", "Length", "Surface",
    "Finish", "Start", "Car", "Driver", "Team", "Make",
    "Pts", "Laps", "Led", "Status", "Win"
  )
  expect_true(all(expected_cols %in% names(xfinity)))
})

test_that("load_series() returns truck data with correct structure", {
  skip_on_cran()
  skip_if_offline()

  truck <- load_series("truck")

  expect_s3_class(truck, "data.frame")
  expect_true(nrow(truck) > 0)

  expected_cols <- c(
    "Season", "Race", "Track", "Name", "Length", "Surface",
    "Finish", "Start", "Car", "Driver", "Team", "Make",
    "Pts", "Laps", "Led", "Status", "Win"
  )
  expect_true(all(expected_cols %in% names(truck)))
})

test_that("cup data has reasonable values", {
  skip_on_cran()
  skip_if_offline()

  cup <- load_series("cup")

  # Season should be reasonable (1949 to present)
  expect_true(all(cup$Season >= 1949, na.rm = TRUE))
  expect_true(all(cup$Season <= as.numeric(format(Sys.Date(), "%Y")),
    na.rm = TRUE
  ))

  # Finish position should be positive
  expect_true(all(cup$Finish > 0, na.rm = TRUE))

  # Win should be binary (0 or 1) where not NA
  win_values <- cup$Win[!is.na(cup$Win)]
  expect_true(all(win_values %in% c(0, 1)))

  # Laps should be non-negative where not NA
  laps_values <- cup$Laps[!is.na(cup$Laps)]
  expect_true(all(laps_values >= 0))

  # Led laps should generally not exceed total laps
  # Note: < 10 historical anomalies in early NASCAR history
  valid_rows <- !is.na(cup$Led) & !is.na(cup$Laps)
  violations <- sum(cup$Led[valid_rows] > cup$Laps[valid_rows])
  expect_lt(violations / sum(valid_rows), 0.0001)
})

test_that("xfinity data has reasonable values", {
  skip_on_cran()
  skip_if_offline()

  xfinity <- load_series("xfinity")

  expect_true(all(xfinity$Season >= 1982, na.rm = TRUE))
  expect_true(all(xfinity$Season <= as.numeric(format(Sys.Date(), "%Y")),
    na.rm = TRUE
  ))

  finish_values <- xfinity$Finish[!is.na(xfinity$Finish)]
  expect_true(all(finish_values > 0))

  win_values <- xfinity$Win[!is.na(xfinity$Win)]
  expect_true(all(win_values %in% c(0, 1)))

  laps_values <- xfinity$Laps[!is.na(xfinity$Laps)]
  expect_true(all(laps_values >= 0))
})

test_that("truck data has reasonable values", {
  skip_on_cran()
  skip_if_offline()

  truck <- load_series("truck")

  expect_true(all(truck$Season >= 1995, na.rm = TRUE))
  expect_true(all(truck$Season <= as.numeric(format(Sys.Date(), "%Y")),
    na.rm = TRUE
  ))

  finish_values <- truck$Finish[!is.na(truck$Finish)]
  expect_true(all(finish_values > 0))

  win_values <- truck$Win[!is.na(truck$Win)]
  expect_true(all(win_values %in% c(0, 1)))

  laps_values <- truck$Laps[!is.na(truck$Laps)]
  expect_true(all(laps_values >= 0))
})

test_that("cup data contains known drivers", {
  skip_on_cran()
  skip_if_offline()

  cup <- load_series("cup")

  expect_true("Richard Petty" %in% cup$Driver)
  expect_true("Dale Earnhardt" %in% cup$Driver)
  expect_true("Jeff Gordon" %in% cup$Driver)
})

test_that("cup data contains known manufacturers", {
  skip_on_cran()
  skip_if_offline()

  cup <- load_series("cup")

  manufacturers <- unique(cup$Make)
  expect_true("Chevrolet" %in% manufacturers)
  expect_true("Ford" %in% manufacturers)
  expect_true("Toyota" %in% manufacturers)
})

test_that("load_series() validates input", {
  expect_error(load_series("invalid"))
})

test_that("load_series() uses memory cache on second call", {
  skip_on_cran()
  skip_if_offline()

  # First call downloads
  cup1 <- load_series("cup")

  # Second call should return identical data from memory cache
  cup2 <- load_series("cup")
  expect_identical(cup1, cup2)
})

test_that("load_series() refresh parameter bypasses cache", {
  skip_on_cran()
  skip_if_offline()

  cup1 <- load_series("cup")
  cup2 <- load_series("cup", refresh = TRUE)

  # Data should still be identical (same R2 source)
  expect_equal(nrow(cup1), nrow(cup2))
  expect_equal(ncol(cup1), ncol(cup2))
})

test_that("clear_cache() runs without error", {
  expect_no_error(clear_cache())
})
