library(metalite)

#Prepare test data
adsl <- r2rtf::r2rtf_adsl
adsl$TRTA <- adsl$TRT01A
adsl$TRTA <- factor(
  adsl$TRTA,
  levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
  labels = c("Placebo", "Low Dose", "High Dose")
)

meta <- meta_sl(
  dataset_population = adsl,
  population_term = "apat",
  parameter_term = "age;gender;race",
  parameter_var = "AGE^AGEGR1;SEX;RACE",
  treatment_group = "TRTA"
)

#Test
test_that("There is one analysis: base_char", {
  expect_equal(names(meta$analysis), "base_char")
})

test_that("There is one observation: apat", {
  expect_equal(names(meta$observation), c("apat"))
})

test_that("There is one population: apat", {
  expect_equal(names(meta$population), "apat")
})

test_that("There are three parameters: age, gender, race", {
  expect_equal(names(meta$parameter), c("age","gender","race"))
})

test_that("There is one group parameter for age: agegr1", {
  expect_equal(meta$parameter$age$vargroup, "AGEGR1")
})

test_that("Output from meta_sl is a list", {
  expect_type(meta, "list")
})