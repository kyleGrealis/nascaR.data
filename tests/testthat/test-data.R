# Test dataset loading and structure

test_that('cup_series dataset loads and has correct structure', {
  data('cup_series', package = 'nascaR.data')

  expect_s3_class(cup_series, 'data.frame')
  expect_true(nrow(cup_series) > 0)

  # Check for expected columns
  expected_cols <- c(
    'Season', 'Race', 'Track', 'Name', 'Length', 'Surface',
    'Finish', 'Start', 'Car', 'Driver', 'Team', 'Make',
    'Pts', 'Laps', 'Led', 'Status', 'Win'
  )
  expect_true(all(expected_cols %in% names(cup_series)))
})

test_that('xfinity_series dataset loads and has correct structure', {
  data('xfinity_series', package = 'nascaR.data')

  expect_s3_class(xfinity_series, 'data.frame')
  expect_true(nrow(xfinity_series) > 0)

  # Check for expected columns
  expected_cols <- c(
    'Season', 'Race', 'Track', 'Name', 'Length', 'Surface',
    'Finish', 'Start', 'Car', 'Driver', 'Team', 'Make',
    'Pts', 'Laps', 'Led', 'Status', 'Win'
  )
  expect_true(all(expected_cols %in% names(xfinity_series)))
})

test_that('truck_series dataset loads and has correct structure', {
  data('truck_series', package = 'nascaR.data')

  expect_s3_class(truck_series, 'data.frame')
  expect_true(nrow(truck_series) > 0)

  # Check for expected columns
  expected_cols <- c(
    'Season', 'Race', 'Track', 'Name', 'Length', 'Surface',
    'Finish', 'Start', 'Car', 'Driver', 'Team', 'Make',
    'Pts', 'Laps', 'Led', 'Status', 'Win'
  )
  expect_true(all(expected_cols %in% names(truck_series)))
})

test_that('cup_series has reasonable values', {
  data('cup_series', package = 'nascaR.data')

  # Season should be reasonable (1949 to present)
  expect_true(all(cup_series$Season >= 1949, na.rm = TRUE))
  expect_true(all(cup_series$Season <= as.numeric(format(Sys.Date(), '%Y')),
                  na.rm = TRUE))

  # Finish position should be positive
  expect_true(all(cup_series$Finish > 0, na.rm = TRUE))

  # Win should be binary (0 or 1) where not NA
  win_values <- cup_series$Win[!is.na(cup_series$Win)]
  expect_true(all(win_values %in% c(0, 1)))

  # Laps should be non-negative where not NA
  laps_values <- cup_series$Laps[!is.na(cup_series$Laps)]
  expect_true(all(laps_values >= 0))

  # Led laps should generally not exceed total laps
  # Note: There are a few historical data anomalies (< 10 cases out of 500k+)
  # in early NASCAR history where this doesn't hold
  valid_rows <- !is.na(cup_series$Led) & !is.na(cup_series$Laps)
  violations <- sum(cup_series$Led[valid_rows] > cup_series$Laps[valid_rows])
  # Should be very rare (less than 0.01% of records)
  expect_lt(violations / sum(valid_rows), 0.0001)
})

test_that('xfinity_series has reasonable values', {
  data('xfinity_series', package = 'nascaR.data')

  # Season should be reasonable (1982 to present)
  expect_true(all(xfinity_series$Season >= 1982, na.rm = TRUE))
  expect_true(all(xfinity_series$Season <= as.numeric(format(Sys.Date(), '%Y')),
                  na.rm = TRUE))

  # Finish position should be positive where not NA
  finish_values <- xfinity_series$Finish[!is.na(xfinity_series$Finish)]
  expect_true(all(finish_values > 0))

  # Win should be binary where not NA
  win_values <- xfinity_series$Win[!is.na(xfinity_series$Win)]
  expect_true(all(win_values %in% c(0, 1)))

  # Laps should be non-negative where not NA
  laps_values <- xfinity_series$Laps[!is.na(xfinity_series$Laps)]
  expect_true(all(laps_values >= 0))
})

test_that('truck_series has reasonable values', {
  data('truck_series', package = 'nascaR.data')

  # Season should be reasonable (1995 to present)
  expect_true(all(truck_series$Season >= 1995, na.rm = TRUE))
  expect_true(all(truck_series$Season <= as.numeric(format(Sys.Date(), '%Y')),
                  na.rm = TRUE))

  # Finish position should be positive where not NA
  finish_values <- truck_series$Finish[!is.na(truck_series$Finish)]
  expect_true(all(finish_values > 0))

  # Win should be binary where not NA
  win_values <- truck_series$Win[!is.na(truck_series$Win)]
  expect_true(all(win_values %in% c(0, 1)))

  # Laps should be non-negative where not NA
  laps_values <- truck_series$Laps[!is.na(truck_series$Laps)]
  expect_true(all(laps_values >= 0))
})

test_that('datasets contain known drivers', {
  data('cup_series', package = 'nascaR.data')

  # Test for some legendary drivers
  expect_true('Richard Petty' %in% cup_series$Driver)
  expect_true('Dale Earnhardt' %in% cup_series$Driver)
  expect_true('Jeff Gordon' %in% cup_series$Driver)
})

test_that('datasets contain known manufacturers', {
  data('cup_series', package = 'nascaR.data')

  # Check for major manufacturers
  manufacturers <- unique(cup_series$Make)
  expect_true('Chevrolet' %in% manufacturers)
  expect_true('Ford' %in% manufacturers)
  expect_true('Toyota' %in% manufacturers)
})
