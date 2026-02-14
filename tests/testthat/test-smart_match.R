# Test smart_match() internal function

test_that("smart_match handles NULL, NA, and empty inputs", {
  test_data <- c("Dale Earnhardt", "Jeff Gordon", "Jimmie Johnson")

  expect_equal(
    nascaR.data:::smart_match(NULL, test_data),
    character(0)
  )

  expect_equal(
    nascaR.data:::smart_match(NA, test_data),
    character(0)
  )

  expect_equal(
    nascaR.data:::smart_match("", test_data),
    character(0)
  )
})

test_that("smart_match handles empty data_column", {
  expect_equal(
    nascaR.data:::smart_match("test", character(0)),
    character(0)
  )

  expect_equal(
    nascaR.data:::smart_match("test", c(NA, NA)),
    character(0)
  )

  expect_equal(
    nascaR.data:::smart_match("test", c("", "", NA)),
    character(0)
  )
})

test_that("smart_match returns exact matches with priority", {
  test_data <- c(
    "Dale Earnhardt",
    "Dale Earnhardt Jr.",
    "Ralph Dale Earnhardt"
  )

  result <- nascaR.data:::smart_match("Dale Earnhardt", test_data)

  expect_length(result, 1)
  expect_equal(result, "Dale Earnhardt")
})

test_that("smart_match is case-insensitive", {
  test_data <- c("Jeff Gordon", "Dale Earnhardt", "Jimmie Johnson")

  expect_equal(
    nascaR.data:::smart_match("JEFF GORDON", test_data),
    "Jeff Gordon"
  )

  expect_equal(
    nascaR.data:::smart_match("jeff gordon", test_data),
    "Jeff Gordon"
  )

  expect_equal(
    nascaR.data:::smart_match("JeFf GoRdOn", test_data),
    "Jeff Gordon"
  )
})

test_that("smart_match trims whitespace", {
  test_data <- c("Jeff Gordon", "Dale Earnhardt")

  expect_equal(
    nascaR.data:::smart_match("  Jeff Gordon  ", test_data),
    "Jeff Gordon"
  )

  expect_equal(
    nascaR.data:::smart_match("\tJeff Gordon\n", test_data),
    "Jeff Gordon"
  )
})

test_that("smart_match prioritizes starts_with over contains", {
  test_data <- c(
    "Hendrick Motorsports",
    "Stewart-Haas Racing",
    "Rick Hendrick"
  )

  result <- nascaR.data:::smart_match("Hend", test_data)

  expect_true(result[1] == "Hendrick Motorsports")
})

test_that("smart_match finds contains matches", {
  test_data <- c(
    "Stewart-Haas Racing",
    "Haas Automation",
    "Gene Haas"
  )

  result <- nascaR.data:::smart_match("Haas", test_data)

  expect_true("Haas Automation" %in% result)
  expect_true("Gene Haas" %in% result)
})

test_that("smart_match handles word boundary matching - single word", {
  test_data <- c(
    "Dale Earnhardt",
    "Dale Earnhardt Jr.",
    "Ralph Dale Earnhardt",
    "Daleville Racing"
  )

  result <- nascaR.data:::smart_match("Dale", test_data)

  expect_true("Dale Earnhardt" %in% result)
  expect_true("Dale Earnhardt Jr." %in% result)
  expect_true("Ralph Dale Earnhardt" %in% result)
})

test_that("smart_match handles word boundary matching - multi-word", {
  test_data <- c(
    "Hendrick Motorsports Racing",
    "Racing Motorsports Hendrick",
    "Joe Gibbs Racing",
    "Jeff Gordon Motorsports"
  )

  result <- nascaR.data:::smart_match("Hendrick Motorsports", test_data)

  expect_true("Hendrick Motorsports Racing" %in% result)
  expect_true("Racing Motorsports Hendrick" %in% result)
})

test_that("smart_match handles partial word matching", {
  test_data <- c(
    "Richard Childress Racing",
    "Childress Vineyards",
    "Austin Dillon"
  )

  result <- nascaR.data:::smart_match("Child", test_data)

  expect_true("Richard Childress Racing" %in% result)
  expect_true("Childress Vineyards" %in% result)
})

test_that("smart_match requires minimum length for partial matching", {
  test_data <- c("Dale Earnhardt", "Jeff Gordon")

  result <- nascaR.data:::smart_match("Da", test_data)

  expect_true("Dale Earnhardt" %in% result)
})

test_that("smart_match handles fuzzy/typo matching", {
  test_data <- c(
    "Dale Earnhardt",
    "Jeff Gordon",
    "Jimmie Johnson"
  )

  result <- nascaR.data:::smart_match("Earnhart", test_data)

  expect_true("Dale Earnhardt" %in% result)

  result <- nascaR.data:::smart_match("Gordan", test_data)

  expect_true("Jeff Gordon" %in% result)
})

test_that("smart_match requires minimum length for fuzzy matching", {
  test_data <- c("Dale Earnhardt", "Jeff Gordon")

  result <- nascaR.data:::smart_match("abc", test_data)

  expect_equal(result, character(0))
})

test_that("smart_match fuzzy matching has 70% similarity threshold", {
  test_data <- c("Earnhardt", "Gordon", "Johnson")

  result <- nascaR.data:::smart_match("Earnhart", test_data)

  expect_true("Earnhardt" %in% result)

  result <- nascaR.data:::smart_match("xyz", test_data)

  expect_equal(result, character(0))
})

test_that("smart_match respects max_results parameter", {
  test_data <- c(
    "Dale Earnhardt",
    "Dale Earnhardt Jr.",
    "Dale Jarrett",
    "Dale Coyne Racing",
    "Daleville Racing",
    "Ralph Dale Earnhardt"
  )

  result <- nascaR.data:::smart_match("Dale", test_data, max_results = 3)

  expect_length(result, 3)
})

test_that("smart_match max_results works with exact matches", {
  test_data <- c("Jeff Gordon", "Dale Earnhardt")

  result <- nascaR.data:::smart_match("Jeff Gordon", test_data, max_results = 1)

  expect_length(result, 1)
  expect_equal(result, "Jeff Gordon")
})

test_that("smart_match max_results works with starts_with matches", {
  test_data <- c(
    "Hendrick Motorsports",
    "Hendrick Performance",
    "Hendrick Racing"
  )

  result <- nascaR.data:::smart_match("Hend", test_data, max_results = 2)

  expect_length(result, 2)
})

test_that("smart_match results are priority-ordered", {
  test_data <- c(
    "Gene Haas",
    "Stewart-Haas Racing",
    "Haas Automation"
  )

  result <- nascaR.data:::smart_match("Haas", test_data, max_results = 5)

  expect_true(which(result == "Haas Automation") < which(result == "Gene Haas"))
})

test_that("smart_match prioritizes exact over starts_with", {
  test_data <- c(
    "Gordon",
    "Gordon Racing",
    "Jeff Gordon"
  )

  result <- nascaR.data:::smart_match("Gordon", test_data)

  expect_equal(result[1], "Gordon")
  expect_length(result, 1)
})

test_that("smart_match prioritizes starts_with over word_boundary", {
  test_data <- c(
    "Jeff Gordon Racing",
    "Gordon Racing Team",
    "Rick Gordon"
  )

  result <- nascaR.data:::smart_match("Gordon", test_data, max_results = 5)

  expect_true(
    which(result == "Gordon Racing Team") < which(result == "Jeff Gordon Racing")
  )
})

test_that("smart_match removes duplicates while preserving case", {
  test_data <- c(
    "Jeff Gordon",
    "JEFF GORDON",
    "jeff gordon",
    "Dale Earnhardt"
  )

  result <- nascaR.data:::smart_match("Gordon", test_data)

  expect_equal(result, "Jeff Gordon")
})

test_that("smart_match handles data with NA values", {
  test_data <- c(
    "Jeff Gordon",
    NA,
    "Dale Earnhardt",
    NA,
    "Jimmie Johnson"
  )

  result <- nascaR.data:::smart_match("Gordon", test_data)

  expect_equal(result, "Jeff Gordon")
  expect_false(anyNA(result))
})

test_that("smart_match handles data with empty strings", {
  test_data <- c(
    "Jeff Gordon",
    "",
    "Dale Earnhardt",
    "",
    "Jimmie Johnson"
  )

  result <- nascaR.data:::smart_match("Gordon", test_data)

  expect_equal(result, "Jeff Gordon")
  expect_false(any(result == ""))
})

test_that("smart_match early exit doesn't break priority ordering", {
  test_data <- c(
    "Motorsports",
    "Hendrick Motorsports",
    "Penske Motorsports",
    "Gibbs Motorsports",
    "Ganassi Motorsports",
    "Roush Motorsports",
    "Stewart-Haas Motorsports"
  )

  result <- nascaR.data:::smart_match("Motorsports", test_data, max_results = 1)

  expect_equal(result, "Motorsports")
})

test_that("smart_match handles special characters in search", {
  test_data <- c(
    "Stewart-Haas Racing",
    "Richard Childress Racing",
    "Joe Gibbs Racing"
  )

  result <- nascaR.data:::smart_match("Stewart-Haas", test_data)

  expect_equal(result, "Stewart-Haas Racing")
})

test_that("smart_match handles numbers in data", {
  test_data <- c(
    "Car 3",
    "Car 24",
    "Car 48",
    "Car 88"
  )

  result <- nascaR.data:::smart_match("24", test_data)

  expect_true("Car 24" %in% result)
})

test_that("smart_match returns character(0) when no matches found", {
  test_data <- c("Jeff Gordon", "Dale Earnhardt", "Jimmie Johnson")

  result <- nascaR.data:::smart_match("xyz123", test_data)

  expect_equal(result, character(0))
  expect_type(result, "character")
})

test_that("smart_match handles single element data", {
  test_data <- "Jeff Gordon"

  result <- nascaR.data:::smart_match("Gordon", test_data)

  expect_equal(result, "Jeff Gordon")
})

test_that("smart_match handles very long search terms", {
  test_data <- c(
    "Hendrick Motorsports",
    "Joe Gibbs Racing",
    "Team Penske"
  )

  long_term <- paste(rep("VeryLongUnmatchableWord", 10), collapse = " ")

  result <- nascaR.data:::smart_match(long_term, test_data)

  expect_equal(result, character(0))
})

test_that("smart_match partial matching skips already matched items", {
  test_data <- c(
    "Hendrick Motorsports",
    "Rick Hendrick",
    "Hendrick Performance"
  )

  result <- nascaR.data:::smart_match("Hend", test_data, max_results = 10)

  expect_length(unique(result), length(result))
})

test_that("smart_match handles regex metacharacters - period", {
  test_data <- c(
    "Dale Earnhardt Jr.",
    "Dale Earnhardt Sr.",
    "Dale Earnhardt III",
    "Dale Jarrett"
  )

  result <- nascaR.data:::smart_match("Jr.", test_data)

  expect_true("Dale Earnhardt Jr." %in% result)
  expect_false("Dale Jarrett" %in% result)
})

test_that("smart_match handles regex metacharacters - parentheses", {
  test_data <- c(
    "Racing Team (Owner)",
    "Racing Team",
    "Owner Racing Team",
    "Team (Official)"
  )

  result <- nascaR.data:::smart_match("Team (Owner)", test_data)

  expect_true("Racing Team (Owner)" %in% result)
})

test_that("smart_match handles regex metacharacters - brackets", {
  test_data <- c(
    "Car [3]",
    "Car [24]",
    "Car [48]",
    "Car 3"
  )

  result <- nascaR.data:::smart_match("Car [3]", test_data)

  expect_equal(result, "Car [3]")
})
