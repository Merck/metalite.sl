# Load  metadata example for exposure
meta <- meta_sl_exposure_example()

# Prepare the exposure duration data
outdata <- prepare_exp_duration(meta,
  analysis = "exp_dur",
  population = "apat",
  parameter = "expdur"
)


outdata_prod_pop <- outdata$meta$data_population
outdata_prod_obs <- outdata$meta$data_observation


# Test1
#### Test for Extended Exposure Duration_population ######
test_that("Extended exposure duration population data is as expected", {
  # Extend the exposure duration
  extended_data <- outdata |>
    extend_exp_duration(
      duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
      duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
    )

  # Define expected output data for comparison
  expected_extended_data_pop <- extended_data$meta$data_population

  # Use expect_equal to compare the two dataframes
  testthat::expect_equal(
    outdata_prod_pop,
    expected_extended_data_pop
  )
})

# Test2

#### Test for Extended Exposure Duration_observation ######
test_that("Extended exposure duration observation data is as expected", {
  # Extend the exposure duration
  extended_data <- outdata |>
    extend_exp_duration(
      duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
      duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
    )

  # Define  expected output data for comparison
  expected_extended_data_obs <- extended_data$meta$data_observation

  # Use expect_equal to compare the two dataframes
  testthat::expect_equal(
    outdata_prod_obs,
    expected_extended_data_obs
  )
})

# Test 3 N for cumulative category
test_that("Extended exposure duration char_n_cum ", {
  # Extend the exposure duration
  extended_data <- outdata |>
    extend_exp_duration(
      duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
      duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
    )

  # Input observation data and exposure cumulative category
  expected_extended_data_obs <- extended_data$meta$data_observation
  duration_category_list <- list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA))
  duration_category_labels <- c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
  template <- data.frame(name = duration_category_labels, var_label = "Exposure Duration (Days) (extend)", ord = seq_along(duration_category_labels))

  # Create data for cumulative category
  for (i in seq_along(duration_category_list)) {
    low <- ifelse(is.na(duration_category_list[[i]][1]), -Inf, duration_category_list[[i]][1])
    high <- ifelse(is.na(duration_category_list[[i]][2]), Inf, duration_category_list[[i]][2])

    adexsum0 <- expected_extended_data_obs[which(expected_extended_data_obs$AVAL >= low & expected_extended_data_obs$AVAL < high), ]
    if (nrow(adexsum0) > 0) {
      adexsum0$EXDURGR <- NA
      adexsum0$EXDURGR <- duration_category_labels[i]
      adexsum0$EXDURGRN <- i

      if (i == 1) {
        adexsum <- adexsum0
      } else if (i > 1) {
        adexsum <- rbind(adexsum, adexsum0)
      }
    }
  }
  adexsumtot <- adexsum
  adexsumtot$TRTA <- NA
  adexsumtot$TRTA <- "Total"
  adexsum <- rbind(adexsum, adexsumtot)

  # Calculate Freq N to test char_n_cum
  counts <- reshape(as.data.frame(table(adexsum$EXDURGR, adexsum$TRTA)), idvar = "Var1", timevar = "Var2", direction = "wide")
  # Rename column name
  names(counts) <- gsub("Freq.", "", names(counts))
  colnames(counts)[1] <- "name"

  # Post processing test output data
  test_char_n_cum <- merge(x = counts, y = template, by = "name", all.y = TRUE)
  test_char_n_cum[is.na(test_char_n_cum)] <- 0
  # Convert int to char
  for (j in seq(1, ncol(test_char_n_cum) - 1, 1)) {
    test_char_n_cum[, j] <- as.character(test_char_n_cum[, j])
  }
  # Sorting Order
  test_char_n_cum <- test_char_n_cum[order(test_char_n_cum$ord), ]
  test_extended_data_n_cum <- list(test_char_n_cum[, !(names(test_char_n_cum) %in% "ord")])

  # Define expected output data for comparison
  expected_extended_data_n_cum <- extended_data$char_n_cum

  # Test n
  expect_equal(
    test_extended_data_n_cum,
    expected_extended_data_n_cum,
    ignore_attr = TRUE
  )
})

# Test 4 Prop for cumulative category
test_that("Extended exposure duration char_prop_cum ", {
  # Extend the exposure duration
  extended_data <- outdata |>
    extend_exp_duration(
      duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
      duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
    )

  # Input observation data and exposure cumulative category
  expected_extended_data_obs <- extended_data$meta$data_observation
  duration_category_list <- list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA))
  duration_category_labels <- c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
  template <- data.frame(name = duration_category_labels, var_label = "Exposure Duration (Days) (extend)", ord = seq_along(duration_category_labels))

  # Create data for cumulative category
  for (i in seq_along(duration_category_list)) {
    low <- ifelse(is.na(duration_category_list[[i]][1]), -Inf, duration_category_list[[i]][1])
    high <- ifelse(is.na(duration_category_list[[i]][2]), Inf, duration_category_list[[i]][2])

    adexsum0 <- expected_extended_data_obs[which(expected_extended_data_obs$AVAL >= low & expected_extended_data_obs$AVAL < high), ]
    if (nrow(adexsum0) > 0) {
      adexsum0$EXDURGR <- NA
      adexsum0$EXDURGR <- duration_category_labels[i]
      adexsum0$EXDURGRN <- i

      if (i == 1) {
        adexsum <- adexsum0
      } else if (i > 1) {
        adexsum <- rbind(adexsum, adexsum0)
      }
    }
  }
  adexsumtot <- adexsum
  adexsumtot$TRTA <- NA
  adexsumtot$TRTA <- "Total"
  adexsum <- rbind(adexsum, adexsumtot)

  # Calculate Freq N to test char_n_cum
  counts <- reshape(as.data.frame(table(adexsum$EXDURGR, adexsum$TRTA)), idvar = "Var1", timevar = "Var2", direction = "wide")
  # Rename column name
  names(counts) <- gsub("Freq.", "", names(counts))
  colnames(counts)[1] <- "name"

  # Bign
  bign <- extended_data$n
  counts[, 2] <- as.character(round(counts[, 2] * 100 / bign$n_1, digits = 5))
  counts[, 3] <- as.character(round(counts[, 3] * 100 / bign$n_2, digits = 5))
  counts[, 4] <- as.character(round(counts[, 4] * 100 / bign$n_3, digits = 5))
  counts$Total <- as.character(round(counts$Total * 100 / bign$n_9999, digits = 5))

  # Post processing test output data
  test_char_prop_cum <- merge(x = counts, y = template, by = "name", all.y = TRUE)
  test_char_prop_cum[is.na(test_char_prop_cum)] <- 0
  # Convert int to char
  for (j in seq(1, ncol(test_char_prop_cum) - 1, 1)) {
    test_char_prop_cum[, j] <- as.character(test_char_prop_cum[, j])
  }
  # Sorting Order
  test_char_prop_cum <- test_char_prop_cum[order(test_char_prop_cum$ord), ]
  test_extended_data_prop_cum <- list(test_char_prop_cum[, !(names(test_char_prop_cum) %in% "ord")])

  # Define expected output data for comparison
  expected_extended_data_prop_cum0 <- extended_data$char_prop_cum[[1]]
  cols_to_convert <- c(as.character(levels(extended_data$group_label)), "Total")
  expected_extended_data_prop_cum0[cols_to_convert] <- lapply(expected_extended_data_prop_cum0[cols_to_convert], as.numeric)
  expected_extended_data_prop_cum0[cols_to_convert] <- round(expected_extended_data_prop_cum0[cols_to_convert], digits = 5)
  expected_extended_data_prop_cum0[cols_to_convert] <- lapply(expected_extended_data_prop_cum0[cols_to_convert], as.character)
  expected_extended_data_prop_cum <- list(expected_extended_data_prop_cum0)

  # Test prop
  expect_equal(
    test_extended_data_prop_cum,
    expected_extended_data_prop_cum,
    ignore_attr = TRUE
  )
})

# Test 5 Stat for cumulative category
test_that("Extended exposure duration char_stat_cum ", {
  # Extend the exposure duration
  extended_data <- outdata |>
    extend_exp_duration(
      duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
      duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
    )

  # Input observation data and exposure cumulative category
  expected_extended_data_obs <- extended_data$meta$data_observation
  duration_category_list <- list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA))
  duration_category_labels <- c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")

  # Create data for cumulative category
  for (i in seq_along(duration_category_list)) {
    low <- ifelse(is.na(duration_category_list[[i]][1]), -Inf, duration_category_list[[i]][1])
    high <- ifelse(is.na(duration_category_list[[i]][2]), Inf, duration_category_list[[i]][2])

    adexsum0 <- expected_extended_data_obs[which(expected_extended_data_obs$AVAL >= low & expected_extended_data_obs$AVAL < high), ]
    if (nrow(adexsum0) > 0) {
      adexsum0$EXDURGR <- NA
      adexsum0$EXDURGR <- duration_category_labels[i]
      adexsum0$EXDURGRN <- i

      if (i == 1) {
        adexsum <- adexsum0
      } else if (i > 1) {
        adexsum <- rbind(adexsum, adexsum0)
      }
    }
  }

  adexsumtot <- adexsum
  adexsumtot$TRTA <- NA
  adexsumtot$TRTA <- "Total"
  adexsum <- rbind(adexsum, adexsumtot)

  test_extended_data_stat_cum <- list()
  for (j in seq_along(unique(adexsum$EXDURGR))) {
    sub <- adexsum[which(adexsum$EXDURGR == unique(adexsum$EXDURGR)[j]), ]
    stat <- tapply(sub$AVAL, sub$TRTA, function(x) {
      value <- c(
        Mean = mean(x, na.rm = TRUE),
        SD = stats::sd(x, na.rm = TRUE),
        SE = stats::sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))),
        Median = stats::median(x, na.rm = TRUE),
        Min = min(x, na.rm = TRUE),
        Max = max(x, na.rm = TRUE)
      )
      value <- formatC(value, format = "f", digits = 1)

      value <- c(value,
        `Q1 to Q3` = paste0(
          stats::quantile(x, probs = 0.25, na.rm = TRUE, names = FALSE), " to ",
          stats::quantile(x, probs = 0.75, na.rm = TRUE, names = FALSE)
        ),
        Range = paste0(min(x, na.rm = TRUE), " to ", max(x, na.rm = TRUE))
      )

      value
    })
    stat <- t(do.call(rbind, stat))
    stat <- data.frame(
      name = row.names(stat),
      stat
    )
    # combine results
    names(stat) <- names(stat)
    row.names(stat) <- NULL
    stat$var_label <- "Exposure Duration (Days) (extend)"
    names(stat) <- sub("\\.", " ", names(stat))

    # missing TRTA
    col <- setdiff(extended_data$group_label, sub$TRTA)
    for (k in seq_along(col)) {
      trt <- col[k]
      stat[, trt] <- as.character(NA)
    }

    reference <- c("name", as.character(levels(extended_data$group_label)), "Total", "var_label")
    stat_sorted <- stat[, reference]
    test_extended_data_stat_cum[[j]] <- stat_sorted
  }
  names(test_extended_data_stat_cum) <- unique(adexsum$EXDURGR)

  # Define expected output data for comparison
  expected_extended_data_stat_cum <- extended_data$char_stat_cums
  expected_extended_data_stat_cum <- lapply(expected_extended_data_stat_cum, function(x) {
    x[] <- lapply(x, as.character)
    x
  })

  # Test stat
  expect_equal(
    test_extended_data_stat_cum,
    expected_extended_data_stat_cum,
    ignore_attr = TRUE
  )
})
