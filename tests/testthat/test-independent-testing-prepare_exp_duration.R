library(metalite)
library(metalite.ae)
library(dplyr)
library(tidyr)

# Read data
adsl <- r2rtf::r2rtf_adsl


# Create ADEXSUM dataset
adexsum <- data.frame(USUBJID = adsl$USUBJID)
adexsum$TRTA <- factor(adsl$TRT01A,
  levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
  labels = c("Placebo", "Low Dose", "High Dose")
)

adexsum$TRTAN <- adsl$TRT01AN
adexsum$SAFFL <- adsl$SAFFL

names(adexsum$TRTA) <- "TREATMENT"

adexsum$APERIODC <- "Base"
adexsum$APERIOD <- 1
adexsum$AVAL <- sample(x = 0:(24 * 7), size = length(adexsum$USUBJID), replace = TRUE)
adexsum$EXDURGR <- "not treated"
adexsum$EXDURGR[adexsum$AVAL >= 1] <- ">=1 day"
adexsum$EXDURGR[adexsum$AVAL >= 7] <- ">=7 days"
adexsum$EXDURGR[adexsum$AVAL >= 28] <- ">=28 days"
adexsum$EXDURGR[adexsum$AVAL >= 12 * 7] <- ">=12 weeks"
adexsum$EXDURGR[adexsum$AVAL >= 24 * 7] <- ">=24 weeks"

adexsum$EXDURGR <- factor(adexsum$EXDURGR,
  levels = c("not treated", ">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
)

plan <- metalite::plan(
  analysis = "exp_dur",
  population = "apat",
  observation = "apat",
  parameter = "expdur"
)


meta_test <- metalite::meta_adam(
  population = adexsum,
  observation = adexsum
) |>
  metalite::define_plan(plan) |>
  metalite::define_population(
    name = "apat",
    group = "TRTA",
    subset = quote(APERIOD == 1 & AVAL > 0)
  ) |>
  metalite::define_parameter(
    name = "expdur",
    var = "AVAL",
    label = "Exposure Duration (Days)",
    vargroup = "EXDURGR"
  ) |>
  metalite::define_analysis(
    name = "exp_dur",
    title = "Summary of Exposure Duration",
    label = "exposure duration table"
  )


# Prepare test data by the tested function
test_meta_exp_dur <- prepare_sl_summary(
  meta_test,
  population = "apat",
  analysis = "exp_dur",
  parameter = "expdur"
)

# all
test_meta_n_all <- tibble(test_meta_exp_dur$n)

# Count and proportion, or statistics for variables
test_meta_n_char <- NULL
test_meta_prop_char <- NULL
test_meta_n_num <- NULL
test_meta_prop_num <- NULL
test_meta_n_num1 <- NULL
test_meta_prop_num1 <- NULL

for (i in (1:length(test_meta_exp_dur$char_var))) {
  if (test_meta_exp_dur$var_type[[i]] == "integer") {
    test_meta_n_char <-
      rbind(
        test_meta_n_char,
        tibble(test_meta_exp_dur$char_n[[i]])
      )
    test_meta_prop_char <-
      rbind(
        test_meta_prop_char,
        tibble(test_meta_exp_dur$char_prop[[i]])
      )
  } else {
    test_meta_n_num <-
      rbind(
        test_meta_n_num,
        tibble(test_meta_exp_dur$char_n[[i]])
      )
    test_meta_prop_num <-
      rbind(
        test_meta_prop_num,
        tibble(test_meta_exp_dur$char_prop[[i]])
      )
  }
}


# Prepare compare data for calculation
adexsum_tot <- adexsum |>
  select(-c(TRTAN)) |>
  mutate(TRTA = "Overall")

adexsum_tot <- adexsum_tot |> mutate(TRTAN = 9999)

adexsum_tot <- rbind(adexsum, adexsum_tot)

adexsum_tot <- adexsum_tot |> filter(APERIOD == 1 & AVAL > 0 & SAFFL == "Y")


res_tot <- adexsum_tot |>
  summarise(n = n_distinct(USUBJID), .by = c(TRTAN, TRTA))

# Testing

# 1
test_that("Group matching", {
  expect_equal(
    test_meta_exp_dur$group_label,
    factor(c("Placebo", "High Dose", "Low Dose"),
      levels = c("Placebo", "Low Dose", "High Dose")
    )
  )
})


# 2
test_that("Participants in population", {
  res <-
    res_tot |>
    arrange(TRTAN) |>
    mutate(x = case_when(
      TRTA == "Overall" ~ "n_9999",
      TRUE ~ paste0("n_", row_number())
    ))


  pop_cnt <- res |>
    select(-c(TRTA, TRTAN)) |>
    pivot_wider(
      names_from = "x",
      values_from = n,
      values_fill = list(n = 0)
    )


  expect_equal(
    test_meta_n_all |> select(c(n_1, n_2, n_3, n_9999)),
    tibble(pop_cnt)
  )

  expect_equal(test_meta_exp_dur$n[["name"]], "Participants in population")
  expect_equal(test_meta_exp_dur$n[["var_label"]], "-----")
})


# 3
test_that("Character variables count", {
  char_var <- c("EXDURGR")
  res_frq_n <- NULL
  res_frq_prop <- NULL

  for (var in char_var) {
    res_frq <-
      adexsum_tot |>
      summarise(n = n_distinct(USUBJID), .by = c(TRTAN, TRTA, !!var)) |>
      arrange(!!var, TRTAN) |>
      mutate(x = case_when(
        TRTAN == 0 ~ "Placebo",
        TRTAN == 54 ~ "Low Dose",
        TRTAN == 81 ~ "High Dose",
        TRTAN == 9999 ~ "Total"
      )) |>
      rename(name = !!var)

    attr(res_frq[["name"]], "label") <- NULL

    res_frq <-
      data.frame(full_join(
        res_frq, res_tot |> rename(z = n, TRTA_ = TRTA),
        by = c("TRTAN"),
        multiple = "all"
      )) |>
      mutate(
        pct = 100 * n / z,
      ) |>
      mutate(p = case_when(
        TRTAN == 0 ~ "Placebo",
        TRTAN == 54 ~ "Low Dose",
        TRTAN == 81 ~ "High Dose",
        TRTAN == 9999 ~ "Total"
      ))

    res_frq1 <- res_frq |>
      select(-c(TRTA_)) |>
      pivot_wider(
        id_cols = c("name"),
        names_from = "x",
        values_from = n,
        values_fill = c(n = 0)
      ) |>
      arrange(name)


    res_frq2 <- res_frq |>
      pivot_wider(
        id_cols = c("name"),
        names_from = "p",
        values_from = pct,
        values_fill = c(pct = 0)
      ) |>
      arrange(name)


    res_frq_n <- rbind(res_frq_n, res_frq1)
    res_frq_prop <- rbind(res_frq_prop, res_frq2)
  }


  for (col in (names(res_frq_n))) {
    names(res_frq_n[[col]]) <- NULL
    names(res_frq_prop[[col]]) <- NULL
  }


  test_meta_n_num <- dplyr::select(test_meta_n_char, -var_label)

  test_meta_prop_num <- dplyr::select(test_meta_prop_char, -var_label)


  test_meta_n_num1 <- test_meta_n_num[!(test_meta_n_num$name %in% c("Mean", "SD", "SE", "Median", "Min", "Max", "Q1 to Q3", "Range", "not treated")), ]

  test_meta_prop_num1 <- test_meta_prop_num[!(test_meta_prop_num$name %in% c("Mean", "SD", "SE", "Median", "Min", "Max", "Q1 to Q3", "Range", "not treated")), ]


  test_meta_n_num1$name <- factor(test_meta_n_num1$name, levels = levels(res_frq_n$name))
  test_meta_prop_num1$name <- factor(test_meta_prop_num1$name, levels = levels(res_frq_prop$name))

  # Specify the variables to be updated
  vars_to_update <- c("Placebo", "Low Dose", "High Dose", "Total")

  # Update selected variables to character type
  test_meta_n_num1 <- test_meta_n_num1 %>%
    mutate_at(vars_to_update, as.integer)

  # Filter out empty line with NA
  test_meta_n_num1 <- na.omit(test_meta_n_num1)

  # Remove the na.action attribute from the object to avoid inequality comparsion at below expect_equal" step
  attr(test_meta_n_num1, "na.action") <- NULL

  # Filter out empty line with NA
  test_meta_prop_num1 <- na.omit(test_meta_prop_num1)
  # Remove the na.action attribute from the object to avoid inequality comparsion at below "expect_equal" step
  attr(test_meta_prop_num1, "na.action") <- NULL

  # Test n
  expect_equal(
    test_meta_n_num1,
    tibble(res_frq_n)
  )

  # Test proportion
  expect_equal(
    test_meta_prop_num1,
    tibble(res_frq_prop)
  )
})


# 4
test_that("Numeric variables summary", {
  char_var <- c("AVAL")
  res_stat_n <- NULL
  res_stat_prop <- NULL

  for (var in char_var) {
    res_stat <-
      adexsum_tot |>
      summarise(
        n = n_distinct(USUBJID, na.rm = TRUE),
        Mean = mean(AVAL, na.rm = TRUE),
        SD = sd(AVAL, na.rm = TRUE),
        SE = SD / sqrt(n),
        Median = median(AVAL, na.rm = TRUE),
        Min = min(AVAL, na.rm = TRUE),
        Max = max(AVAL, na.rm = TRUE),
        Q1 = quantile(AVAL, probs = 0.25, na.rm = TRUE),
        Q3 = quantile(AVAL, probs = 0.75, na.rm = TRUE),
        .by = c(TRTAN, SAFFL)
      ) |>
      mutate(
        Q1_to_Q3 = paste0(Q1, " to ", Q3),
        Range = paste0(Min, " to ", Max)
      ) |>
      arrange(TRTAN) |>
      mutate(x = case_when(
        TRTAN == 0 ~ "Placebo",
        TRTAN == 54 ~ "Low Dose",
        TRTAN == 81 ~ "High Dose",
        TRTAN == 9999 ~ "Total"
      ))

    res_stat[c("n", "Mean", "SD", "SE", "Median", "Min", "Max")] <-
      lapply(
        res_stat[c("n", "Mean", "SD", "SE", "Median", "Min", "Max")],
        \(x) formatC(x, format = "f", digits = 1)
      )

    res_stat1 <- res_stat |>
      filter(SAFFL == "Y") |>
      select(-Q1, -Q3) |>
      select(-c(TRTAN, SAFFL, n)) |>
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
        !!var == "AVAL" ~ "Exposure Duration (Days)"
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


  test_meta_n_num1 <- test_meta_n_char[(test_meta_n_char$name %in% c("Mean", "SD", "SE", "Median", "Min", "Max", "Q1 to Q3", "Range")), ]

  # Test n
  expect_equal(
    test_meta_n_num1,
    tibble(res_stat_n)
  )
})

test_that("Population matching", {
  expect_equal(test_meta_exp_dur$population, "apat")
})

test_that("Observation matching", {
  expect_equal(test_meta_exp_dur$observation, "apat")
})

test_that("Parameter matching", {
  expect_equal(test_meta_exp_dur$parameter, "expdur")
})

test_that("Output from prepare_sl_summary is a list", {
  expect_true("outdata" %in% class(test_meta_exp_dur))
})
