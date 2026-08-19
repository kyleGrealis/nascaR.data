# Test NASCAR stage points integrity across all series (2017-present)

test_that("stage points (S1, S2) are present for all series from 2017 to present", {
  skip_on_cran()
  skip_if_offline()

  for (series in c("cup", "nxs", "truck")) {
    data <- load_series(series)

    # 2017 was the inaugural season for stage racing
    stage_era <- data[data$Season >= 2017, ]
    seasons <- unique(stage_era$Season)

    for (yr in seasons) {
      season_data <- stage_era[stage_era$Season == yr, ]
      n_races <- length(unique(season_data$Race))

      # Each standard race awards stage points to the top 10 in S1 and S2
      s1_points_count <- sum(!is.na(season_data$S1) & season_data$S1 > 0)
      s2_points_count <- sum(!is.na(season_data$S2) & season_data$S2 > 0)

      expect_gt(
        s1_points_count,
        0,
        label = paste(series, yr, "S1 points count")
      )
      expect_gt(
        s2_points_count,
        0,
        label = paste(series, yr, "S2 points count")
      )

      # Top 10 drivers score stage points in each stage (approx 10 * n_races)
      expect_gte(
        s1_points_count,
        n_races * 8, # allow margin for shortened/rainout edge cases
        label = paste(series, yr, "S1 minimum expected points awarded")
      )
      expect_gte(
        s2_points_count,
        n_races * 8,
        label = paste(series, yr, "S2 minimum expected points awarded")
      )
    }
  }
})

test_that("2025 season specifically has stage data across all three series", {
  skip_on_cran()
  skip_if_offline()

  for (series in c("cup", "nxs", "truck")) {
    data <- load_series(series)
    d2025 <- data[data$Season == 2025, ]

    expect_gt(
      nrow(d2025),
      0,
      label = paste(series, "2025 row count")
    )

    s1_valid <- sum(!is.na(d2025$S1) & d2025$S1 > 0)
    s2_valid <- sum(!is.na(d2025$S2) & d2025$S2 > 0)

    expect_gt(
      s1_valid,
      0,
      label = paste(series, "2025 S1 non-NA count")
    )
    expect_gt(
      s2_valid,
      0,
      label = paste(series, "2025 S2 non-NA count")
    )
  }
})

test_that("stage points are NA for pre-2017 seasons", {
  skip_on_cran()
  skip_if_offline()

  for (series in c("cup", "nxs", "truck")) {
    data <- load_series(series)
    pre_stage <- data[data$Season < 2017, ]

    expect_equal(
      sum(!is.na(pre_stage$S1)),
      0,
      info = paste(series, "pre-2017 S1 should all be NA")
    )
    expect_equal(
      sum(!is.na(pre_stage$S2)),
      0,
      info = paste(series, "pre-2017 S2 should all be NA")
    )
  }
})

test_that("stage point values fall within valid NASCAR scoring ranges (1-10)", {
  skip_on_cran()
  skip_if_offline()

  for (series in c("cup", "nxs", "truck")) {
    data <- load_series(series)
    stage_era <- data[data$Season >= 2017, ]

    s1_vals <- stage_era$S1[!is.na(stage_era$S1)]
    s2_vals <- stage_era$S2[!is.na(stage_era$S2)]

    if (length(s1_vals) > 0) {
      expect_true(
        all(s1_vals >= 1 & s1_vals <= 10),
        info = paste(series, "S1 points between 1 and 10")
      )
    }
    if (length(s2_vals) > 0) {
      expect_true(
        all(s2_vals >= 1 & s2_vals <= 10),
        info = paste(series, "S2 points between 1 and 10")
      )
    }
  }
})
