# Test internal utility functions

test_that("selected_series_data errors for invalid series", {
  expect_error(
    nascaR.data:::selected_series_data("formula1"),
    class = "nascaR_invalid_series"
  )
})

test_that("get_series_data errors for non-string non-df", {
  expect_error(
    nascaR.data:::get_series_data(42),
    "character string or a data frame"
  )
})

test_that("get_series_data handles data frame input", {
  df <- data.frame(Driver = "Test", Finish = 1L)
  result <- nascaR.data:::get_series_data(df)
  expect_true("Series" %in% names(result))
  expect_equal(result$Series, "Custom")
})

test_that("get_series_data preserves existing Series column", {
  df <- data.frame(
    Driver = "Test", Finish = 1L, Series = "Cup"
  )
  result <- nascaR.data:::get_series_data(df)
  expect_equal(result$Series, "Cup")
})
