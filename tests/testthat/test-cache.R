# Test cache infrastructure

test_that("clear_cache empties memory cache", {
  assign("test_key", "test_value", envir = nascaR.data:::.nascar_cache)
  expect_true(exists("test_key", envir = nascaR.data:::.nascar_cache))

  expect_message(clear_cache(), "cache cleared")

  expect_false(exists("test_key", envir = nascaR.data:::.nascar_cache))
})

test_that("clear_cache returns invisible NULL", {
  expect_invisible(clear_cache())
  expect_null(clear_cache())
})

test_that("clear_cache is idempotent", {
  expect_no_error(clear_cache())
  expect_no_error(clear_cache())
})
