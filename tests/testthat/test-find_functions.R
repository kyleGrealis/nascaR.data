# Test find_* functions (always use interactive = FALSE for tests)

# find_driver tests ----

test_that("find_driver returns exact match for known driver", {
  result <- find_driver("Richard Petty", interactive = FALSE)
  expect_equal(result, "Richard Petty")
})

test_that("find_driver handles partial matches", {
  result <- find_driver("petty", interactive = FALSE)
  expect_true("Richard Petty" %in% result)
  expect_type(result, "character")
})

test_that("find_driver handles case insensitivity", {
  result <- find_driver("JEFF GORDON", interactive = FALSE)
  expect_equal(result, "Jeff Gordon")
})

test_that("find_driver returns empty for non-existent driver", {
  expect_message(
    result <- find_driver("ZZZ_NonExistent_Driver_XYZ", interactive = FALSE),
    "No drivers found matching"
  )
  expect_length(result, 0)
})

test_that("find_driver respects max_results parameter", {
  result <- find_driver("kyle", max_results = 2, interactive = FALSE)
  expect_lte(length(result), 2)
})

test_that("find_driver works with cup series only", {
  result <- find_driver("Dale Earnhardt", data = "cup", interactive = FALSE)
  expect_equal(result, "Dale Earnhardt")
})

test_that("find_driver handles typos with fuzzy matching", {
  # Test if fuzzy matching catches common typos
  result <- find_driver("earnhart", interactive = FALSE)
  # Should find Earnhardt variants
  expect_true(any(grepl("Earnhardt", result)))
})

# find_team tests ----

test_that("find_team returns exact match for known team", {
  result <- find_team("Hendrick Motorsports", interactive = FALSE)
  expect_equal(result, "Hendrick Motorsports")
})

test_that("find_team handles partial matches", {
  result <- find_team("hendrick", interactive = FALSE)
  expect_true("Hendrick Motorsports" %in% result)
})

test_that("find_team handles case insensitivity", {
  result <- find_team("JOE GIBBS RACING", interactive = FALSE)
  expect_equal(result, "Joe Gibbs Racing")
})

test_that("find_team returns empty for non-existent team", {
  expect_message(
    result <- find_team("ZZZ_NonExistent_Team_XYZ", interactive = FALSE),
    "No teams found matching"
  )
  expect_length(result, 0)
})

test_that("find_team respects max_results parameter", {
  result <- find_team("racing", max_results = 3, interactive = FALSE)
  expect_lte(length(result), 3)
})

test_that("find_team works with specific series", {
  result <- find_team("Joe Gibbs Racing", data = "xfinity", interactive = FALSE)
  expect_type(result, "character")
})

# find_manufacturer tests ----

test_that("find_manufacturer returns exact match", {
  result <- find_manufacturer("Chevrolet", interactive = FALSE)
  expect_equal(result, "Chevrolet")
})

test_that("find_manufacturer handles common aliases", {
  # Test chevy -> Chevrolet alias
  result <- find_manufacturer("chevy", interactive = FALSE)
  expect_equal(result, "Chevrolet")
})

test_that("find_manufacturer handles case insensitivity", {
  result <- find_manufacturer("TOYOTA", interactive = FALSE)
  expect_equal(result, "Toyota")
})

test_that("find_manufacturer returns empty for non-existent make", {
  expect_message(
    result <- find_manufacturer("ZZZ_NonExistent_Make_XYZ", interactive = FALSE),
    "No manufacturers found matching"
  )
  expect_length(result, 0)
})

test_that("find_manufacturer works with all major manufacturers", {
  # Test the big three
  chevy <- find_manufacturer("Chevrolet", interactive = FALSE)
  ford <- find_manufacturer("Ford", interactive = FALSE)
  toyota <- find_manufacturer("Toyota", interactive = FALSE)

  expect_equal(chevy, "Chevrolet")
  expect_equal(ford, "Ford")
  expect_equal(toyota, "Toyota")
})

test_that("find_manufacturer respects max_results parameter", {
  result <- find_manufacturer("o", max_results = 2, interactive = FALSE)
  expect_lte(length(result), 2)
})

# Edge cases for all find_* functions ----

test_that("find_driver handles empty string input", {
  expect_message(
    result <- find_driver("", interactive = FALSE),
    "No drivers found"
  )
  expect_length(result, 0)
})

test_that("find_team handles whitespace-only input", {
  # Note: Current behavior is to error on whitespace-only input
  # because it gets trimmed to empty string after the initial check
  # This could be improved in the package code
  expect_error(
    find_team("   ", interactive = FALSE),
    "can't be the empty string"
  )
})

test_that("find_manufacturer handles single character search", {
  result <- find_manufacturer("f", interactive = FALSE)
  # Should return results, but limited by max_results
  expect_type(result, "character")
})
