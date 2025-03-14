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
