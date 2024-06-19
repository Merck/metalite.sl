library(metalite)
library(metalite.ae)
library(dplyr)
library(tidyr)

# Read data
adsl <- r2rtf::r2rtf_adsl
adsl$TRT01A <- factor(
  adsl$TRT01A,
  levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
  labels = c("Placebo", "Low Dose", "High Dose")
)

# Create test metadata
test_meta_base_char <- meta_adam(
  population = adsl,
  observation = adsl
) |>
  define_plan(
    plan = plan(
      analysis = "base_char",
      population = "apat",
      observation = "apat",
      parameter = "age;agen;race;gender"
    )
  ) |>
  define_population(
    name = "apat",
    group = "TRT01A",
    subset = quote(SAFFL == "Y"),
    var = c("USUBJID", "TRT01A", "SAFFL", "AGEGR1", "AGE", "SEX", "RACE")
  ) |>
  define_observation(
    name = "apat",
    group = "TRT01A",
    subset = quote(SAFFL == "Y"),
    var = c("USUBJID", "TRT01A", "SAFFL", "AGEGR1", "AGE", "SEX", "RACE")
  ) |>
  define_parameter(
    name = "age",
    var = "AGEGR1",
    label = "Age (years)"
  ) |>
  define_parameter(
    name = "agen",
    var = "AGE",
    label = "Age (years)"
  ) |>
  define_parameter(
    name = "gender",
    var = "SEX",
    label = "Gender"
  ) |>
  define_parameter(
    name = "race",
    var = "RACE",
    label = "Race"
  ) |>
  define_analysis(
    name = "base_char",
    title = "Participant Baseline Characteristics by Treatment Group",
    var_name = c("AGEGR1", "AGE", "RACE", "SEX")
  ) |>
  prepare_sl_summary(
    population = "apat",
    analysis = "base_char",
    parameter = "age;agen;gender;race"
  )

# Append total
adsl_tot <- adsl |> mutate(TRT01AN = 9999)
adsl_tot <- rbind(adsl, adsl_tot)

# Prepare check value for character variables
adsl_tot$AGEGR1 <- factor(adsl_tot$AGEGR1)
adsl_tot$SEX <- factor(adsl_tot$SEX)
adsl_tot$RACE <- factor(adsl_tot$RACE)

agegr1_value <- as.character(sort(unique(adsl_tot$AGEGR1)))
sex_value <- as.character(sort(unique(adsl_tot$SEX)))
race_value <- as.character(sort(unique(adsl_tot$RACE)))

# Testing
test_that("When display_col contains n and prop then the total column disappears", {
  dis <- c("n", "prop")
  test <- format_base_char(
    test_meta_base_char,
    display_col = dis
  )

  display_total <- "total" %in% dis

  if ("n" %in% dis) {
    if (display_total) {
      n_col <- test$char_n[[1]]
      names(n_col) <- c("name", paste0("n_", seq(1, 3)), "n_9999", "var_label")
    } else {
      n_col <- test$char_n[[1]] |> select(-c("Total"))
      names(n_col) <- c("name", paste0("n_", seq(1, 3)), "var_label")
    }
    n_col_names <- names(n_col)
  }

  if ("prop" %in% dis) {
    if (display_total) {
      prop_col <- test$char_prop[[1]]
      names(prop_col) <- c("name", paste0("p_", seq(1, 3)), "p_9999", "var_label")
    } else {
      prop_col <- test$char_n[[1]] |> select(-c("Total"))
      names(prop_col) <- c("name", paste0("p_", seq(1, 3)), "var_label")
    }
    prop_col_names <- names(prop_col)
  }

  expect_col_names <- sort(unique(c(n_col_names, prop_col_names)))

  format_tbl_col_names <- sort(names(test$tbl))

  expect_equal(format_tbl_col_names, expect_col_names)
})

test_that("When digits_prop is specified then the proportions are rounded to the decimal place", {
  dis <- c("n", "prop", "total")

  test_dig0 <- format_base_char(
    test_meta_base_char,
    display_col = dis,
    digits_prop = 0
  )

  test_dig2 <- format_base_char(
    test_meta_base_char,
    display_col = dis,
    digits_prop = 2
  )

  test_meta_base_char$char_prop
  test_meta_prop_char <- NULL
  for (i in (1:length(test_meta_base_char$char_var))) {
    if (test_meta_base_char$var_type[[i]] == "character") {
      test_meta_prop_char <-
        rbind(
          test_meta_prop_char,
          tibble(test_meta_base_char$char_prop[[i]])
        )
    }
  }

  test_meta_prop_char_val <-
    test_meta_prop_char |> select(-c("name", "var_label"))

  res_frq_prop0 <-
    data.frame(
      test_meta_prop_char$name,
      apply(
        test_meta_prop_char_val,
        2,
        \(x) formatC(paste0("(", formatC(x, digits = 0, format = "f"), ")"), format = "f")
      )
    )

  res_frq_prop2 <-
    data.frame(
      test_meta_prop_char$name,
      apply(
        test_meta_prop_char_val,
        2,
        \(x) formatC(paste0("(", formatC(x, digits = 2, format = "f"), ")"), format = "f")
      )
    )

  if ("total" %in% dis) {
    names(res_frq_prop0) <- c("name", paste0("p_", seq(1, length(test_meta_base_char$group_label))), "p_9999")
    names(res_frq_prop2) <- c("name", paste0("p_", seq(1, length(test_meta_base_char$group_label))), "p_9999")
  } else {
    names(res_frq_prop0) <- c("name", paste0("p_", seq(1, length(test_meta_base_char$group_label))))
    names(res_frq_prop2) <- c("name", paste0("p_", seq(1, length(test_meta_base_char$group_label))))
  }

  expect_equal(
    test_dig0$tbl |>
      filter(!name %in% c("Participants in population", "Mean", "SD", "SE", "Median", "Q1 to Q3", "Range")) |>
      select(c("name", starts_with("p_"))),
    res_frq_prop0
  )

  expect_equal(
    test_dig2$tbl |>
      filter(!name %in% c("Participants in population", "Mean", "SD", "SE", "Median", "Q1 to Q3", "Range")) |>
      select(c("name", starts_with("p_"))),
    res_frq_prop2
  )
})

test_that("When display_stat contains mean then Mean row is included", {
  test <- format_base_char(
    test_meta_base_char,
    display_col = c("n", "prop", "total"),
    display_stat = c("mean")
  )

  expect_equal(
    c(
      "Participants in population",
      agegr1_value,
      "Mean",
      sex_value,
      race_value
    ),
    test$tbl[["name"]]
  )
})

test_that("When display_stat contains sd then SD row is included", {
  test <- format_base_char(
    test_meta_base_char,
    display_col = c("n", "prop", "total"),
    display_stat = c("sd")
  )

  expect_equal(
    c(
      "Participants in population",
      agegr1_value,
      "SD",
      sex_value,
      race_value
    ),
    test$tbl[["name"]]
  )
})

test_that("When display_stat contains se then SE row is included", {
  test <- format_base_char(
    test_meta_base_char,
    display_col = c("n", "prop", "total"),
    display_stat = c("se")
  )

  expect_equal(
    c(
      "Participants in population",
      agegr1_value,
      "SE",
      sex_value,
      race_value
    ),
    test$tbl[["name"]]
  )
})

test_that("When display_stat contains median then Median row is included", {
  test <- format_base_char(
    test_meta_base_char,
    display_col = c("n", "prop", "total"),
    display_stat = c("median")
  )

  expect_equal(
    c(
      "Participants in population",
      agegr1_value,
      "Median",
      sex_value,
      race_value
    ),
    test$tbl[["name"]]
  )
})

test_that("When display_stat contains q1 to q3 then q1 to q3 row is included", {
  test <- format_base_char(
    test_meta_base_char,
    display_col = c("n", "prop", "total"),
    display_stat = c("q1 to q3")
  )

  expect_equal(
    c(
      "Participants in population",
      agegr1_value,
      "Q1 to Q3",
      sex_value,
      race_value
    ),
    test$tbl[["name"]]
  )
})

test_that("When display_stat contains range then Range row is included", {
  test <- format_base_char(
    test_meta_base_char,
    display_col = c("n", "prop", "total"),
    display_stat = c("range")
  )

  expect_equal(
    c(
      "Participants in population",
      agegr1_value,
      "Range",
      sex_value,
      race_value
    ),
    test$tbl[["name"]]
  )
})
