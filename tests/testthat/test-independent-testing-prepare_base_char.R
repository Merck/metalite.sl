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

# Define plan
plan <- plan(
  analysis = "base_char",
  population = "apat",
  observation = "apat",
  parameter = "age;agen;race;gender"
)

meta_test <- meta_adam(
  population = adsl,
  observation = adsl
) |>
  define_plan(
    plan = plan
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
  )

# Prepare test data by the tested function
test_meta_base_char <- prepare_base_char(
  meta_test,
  population = "apat",
  observation = "apat",
  analysis = "base_char",
  parameter = "age;agen;gender;race"
)

# all
test_meta_n_all <- tibble(test_meta_base_char$n)

# Count and proportion, or statistics for variables
test_meta_n_char <- NULL
test_meta_prop_char <- NULL
test_meta_n_num <- NULL
test_meta_prop_num <- NULL
for (i in (1:length(test_meta_base_char$char_var))) {
  if (test_meta_base_char$var_type[[i]] == "character") {
    test_meta_n_char <-
      rbind(
        test_meta_n_char,
        tibble(test_meta_base_char$char_n[[i]])
      )
    test_meta_prop_char <-
      rbind(
        test_meta_prop_char,
        tibble(test_meta_base_char$char_prop[[i]])
      )
  } else {
    test_meta_n_num <-
      rbind(
        test_meta_n_num,
        tibble(test_meta_base_char$char_n[[i]])
      )
    test_meta_prop_num <-
      rbind(
        test_meta_prop_num,
        tibble(test_meta_base_char$char_prop[[i]])
      )
  }
}


# Prepare compare data for calculation
adsl_tot <- adsl |> mutate(TRT01AN = 9999)
adsl_tot <- rbind(adsl, adsl_tot)
adsl_tot$AGEGR1 <- factor(adsl_tot$AGEGR1)
adsl_tot$SEX <- factor(adsl_tot$SEX)
adsl_tot$RACE <- factor(adsl_tot$RACE)

res_tot <- adsl_tot |>
  summarise(n = n_distinct(USUBJID), .by = c(TRT01AN, SAFFL))

# Testing
test_that("Group matching", {
  expect_equal(
    test_meta_base_char$group_label,
    factor(c("Placebo", "High Dose", "Low Dose"),
      levels = c("Placebo", "Low Dose", "High Dose")
    )
  )
})

test_that("Participants in population", {
  res <-
    res_tot |>
    mutate(x = case_when(
      TRT01AN == 9999 ~ "n_9999",
      TRUE ~ paste0("n_", row_number())
    ))

  pop_cnt <- res |>
    pivot_wider(
      id_cols = "SAFFL",
      names_from = "x",
      values_from = n,
      values_fill = list(n = 0)
    )

  expect_equal(
    test_meta_n_all |> select(c(n_1, n_2, n_3, n_9999)),
    tibble(pop_cnt) |> select(-c(SAFFL))
  )
  expect_equal(test_meta_base_char$n[["name"]], "Participants in population")
  expect_equal(test_meta_base_char$n[["var_label"]], "-----")
})

test_that("Character variables count", {
  char_var <- c("AGEGR1", "SEX", "RACE")
  res_frq_n <- NULL
  res_frq_prop <- NULL

  for (var in char_var) {
    res_frq <-
      adsl_tot |>
      summarise(n = n_distinct(USUBJID), .by = c(TRT01AN, SAFFL, !!var)) |>
      arrange(!!var, TRT01AN) |>
      mutate(x = case_when(
        TRT01AN == 0 ~ "Placebo",
        TRT01AN == 54 ~ "Low Dose",
        TRT01AN == 81 ~ "High Dose",
        TRT01AN == 9999 ~ "Total"
      )) |>
      rename(name = !!var)

    attr(res_frq[["name"]], "label") <- NULL

    res_frq <-
      data.frame(full_join(
        res_frq, res_tot |> rename(z = n),
        by = c("TRT01AN", "SAFFL"),
        multiple = "all"
      )) |>
      mutate(
        pct = 100 * n / z,
      ) |>
      mutate(p = case_when(
        TRT01AN == 0 ~ "Placebo",
        TRT01AN == 54 ~ "Low Dose",
        TRT01AN == 81 ~ "High Dose",
        TRT01AN == 9999 ~ "Total"
      ))

    res_frq1 <- res_frq |>
      filter(SAFFL == "Y") |>
      pivot_wider(
        id_cols = c("name"),
        names_from = "x",
        values_from = n,
        values_fill = c(n = 0)
      ) |>
      arrange(name) |>
      mutate(var_label = case_when(
        !!var == "AGEGR1" ~ "Age (years)",
        !!var == "SEX" ~ "Gender",
        !!var == "RACE" ~ "Race"
      ))

    res_frq2 <- res_frq |>
      filter(SAFFL == "Y") |>
      pivot_wider(
        id_cols = c("name"),
        names_from = "p",
        values_from = pct,
        values_fill = c(pct = 0)
      ) |>
      arrange(name) |>
      mutate(var_label = case_when(
        !!var == "AGEGR1" ~ "Age (years)",
        !!var == "SEX" ~ "Gender",
        !!var == "RACE" ~ "Race"
      ))

    res_frq_n <- rbind(res_frq_n, res_frq1)
    res_frq_prop <- rbind(res_frq_prop, res_frq2)
  }

  res_frq_n$name <- as.character(res_frq_n$name)
  res_frq_prop$name <- as.character(res_frq_prop$name)

  for (col in (names(res_frq_n))) {
    names(res_frq_n[[col]]) <- NULL
    names(res_frq_prop[[col]]) <- NULL
  }

  # Test n
  expect_equal(
    test_meta_n_char,
    tibble(res_frq_n)
  )
  # Test proportion
  expect_equal(
    test_meta_prop_char,
    tibble(res_frq_prop)
  )
})

test_that("Numeric variables summary", {
  char_var <- c("AGE")
  res_stat_n <- NULL
  res_stat_prop <- NULL

  for (var in char_var) {
    res_stat <-
      adsl_tot |>
      summarise(
        n = n_distinct(USUBJID, na.rm = TRUE),
        Mean = mean(AGE, na.rm = TRUE),
        SD = sd(AGE, na.rm = TRUE),
        SE = SD / sqrt(n),
        Median = median(AGE, na.rm = TRUE),
        Min = min(AGE, na.rm = TRUE),
        Max = max(AGE, na.rm = TRUE),
        Q1 = quantile(AGE, probs = 0.25, na.rm = TRUE),
        Q3 = quantile(AGE, probs = 0.75, na.rm = TRUE),
        .by = c(TRT01AN, SAFFL)
      ) |>
      mutate(
        Q1_to_Q3 = paste0(Q1, " to ", Q3),
        Range = paste0(Min, " to ", Max)
      ) |>
      arrange(TRT01AN) |>
      mutate(x = case_when(
        TRT01AN == 0 ~ "Placebo",
        TRT01AN == 54 ~ "Low Dose",
        TRT01AN == 81 ~ "High Dose",
        TRT01AN == 9999 ~ "Total"
      ))

    res_stat[c("n", "Mean", "SD", "SE", "Median", "Min", "Max")] <-
      lapply(
        res_stat[c("n", "Mean", "SD", "SE", "Median", "Min", "Max")],
        \(x) formatC(x, format = "f", digits = 1)
      )

    res_stat1 <- res_stat |>
      filter(SAFFL == "Y") |>
      select(-Q1, -Q3) |>
      select(-c(TRT01AN, SAFFL, n)) |>
      pivot_longer(
        cols = -c(x),
        names_to = "name",
        values_to = "stat"
      ) |>
      pivot_wider(
        id_cols = c("name"),
        names_from = "x",
        values_from = stat,
        values_fill = c(stat = "0")
      ) |>
      mutate(name = gsub("_", " ", name)) |>
      mutate(var_label = case_when(
        !!var == "AGE" ~ "Age (years)"
      ))

    res_stat1$name <- factor(res_stat1$name,
      levels = c("Mean", "SD", "SE", "Median", "Min", "Max", "Q1 to Q3", "Range")
    )

    res_stat_n <- rbind(
      res_stat_n,
      res_stat1 |> arrange(name)
    )
  }

  res_stat_n$name <- as.character(res_stat_n$name)

  for (col in (names(res_stat_n))) {
    names(res_stat_n[[col]]) <- NULL
  }

  # Test n
  expect_equal(
    test_meta_n_num,
    tibble(res_stat_n)
  )

  res_stat_prop <- res_stat_n
  res_stat_prop[c("Placebo", "Low Dose", "High Dose", "Total")] <- NA

  # Test proportion
  expect_equal(
    test_meta_prop_num,
    tibble(res_stat_prop)
  )
})

test_that("Population matching", {
  expect_equal(test_meta_base_char$population, "apat")
})

test_that("Observation matching", {
  expect_equal(test_meta_base_char$observation, "apat")
})

test_that("Parameter matching", {
  expect_equal(test_meta_base_char$parameter, "age;agen;gender;race")
})

test_that("Output from prepare_base_char is a list", {
  expect_true("outdata" %in% class(test_meta_base_char))
})
