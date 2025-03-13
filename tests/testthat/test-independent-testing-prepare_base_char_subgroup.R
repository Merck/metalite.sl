library(dplyr)
library(tidyr)

meta <- meta_sl_example()
data_population <- meta$data_population
data_population$SEX <- factor(
  data_population$SEX,
  levels = c("F", "M"),
  labels = c("Female", "Male")
)
data_population$AGEGR1 <- factor(
  data_population$AGEGR1,
  levels = c("<65", "65-80", ">80"),
  labels = c("<65", "65-80", ">80")
)
meta$data_population <- data_population

outdata <- prepare_base_char_subgroup(
  meta,
  population = "apat",
  parameter = "age",
  subgroup_var = "SEX",
  subgroup_header = c("SEX", "TRTA")
)

# Testing
test_that("Group matching", {
  expect_equal(
    outdata$group,
    c("Female", "Male")
  )
})

test_that("Subgroup matching", {
  expect_equal(
    outdata$subgroup,
    c("Placebo", "Low Dose", "High Dose")
  )
})

test_that("Participants in population", {
  adsl_tot <- data_population |>
    dplyr::mutate(
      TRTA = "Total"
    )
  adsl_tot <- rbind(data_population, adsl_tot)
  adsl_tot$SEX <- as.numeric(adsl_tot$SEX)

  res_tot <- adsl_tot |>
    dplyr::summarise(
      n = n_distinct(USUBJID),
      .by = c(TRTA, SAFFL, SEX)
    )

  res <-
    res_tot |>
    dplyr::mutate(
      x = paste0("n_", SEX)
    )

  pop_cnt <- res |>
    dplyr::filter(SAFFL == "Y") |>
    tidyr::pivot_wider(
      id_cols = "TRTA",
      names_from = "x",
      values_from = n,
      values_fill = list(n = 0)
    )
  pop_cnt$n_9999 <-
    apply(pop_cnt[, grepl("n_", colnames(pop_cnt))], 1, sum)
  pop_cnt <- pop_cnt[order(pop_cnt$TRTA), ]

  for (i in length(outdata$out_all)) {
    expect_equal(
      outdata$out_all[[i]]$n |> select(starts_with("n_")) |> tibble(),
      tibble(pop_cnt[i, ]) |> select(-c(TRTA))
    )
    expect_equal(outdata$out_all[[i]]$n[["name"]], "Participants in population")
    expect_equal(outdata$out_all[[i]]$n[["var_label"]], "-----")
  }
})

test_that("Character variables count", {
  adsl_tot <- data_population |>
    dplyr::mutate(
      TRTA = "Total"
    )
  adsl_tot <- rbind(data_population, adsl_tot)
  adsl_tot_sex <- adsl_tot |>
    dplyr::mutate(
      SEX = "Total"
    )
  adsl_tot <- rbind(adsl_tot, adsl_tot_sex)

  res_tot <- adsl_tot |>
    dplyr::summarise(
      n = n_distinct(USUBJID),
      .by = c(TRTA, SAFFL, SEX)
    )

  res_frq <-
    adsl_tot |>
    dplyr::summarise(
      n = n_distinct(USUBJID),
      .by = c(TRTA, SAFFL, SEX, AGEGR1)
    ) |>
    dplyr::arrange(TRTA, AGEGR1) |>
    dplyr::rename(name = AGEGR1) |>
    dplyr::full_join(
      res_tot |> rename(z = n),
      by = c("SAFFL", "TRTA", "SEX"),
      multiple = "all"
    ) |>
    data.frame() |>
    dplyr::mutate(
      pct = 100 * n / z,
    )

  res_frq_n <- res_frq |>
    dplyr::filter(SAFFL == "Y") |>
    tidyr::pivot_wider(
      id_cols = c("TRTA", "name"),
      names_from = "SEX",
      values_from = n,
      values_fill = c(n = 0)
    ) |>
    dplyr::arrange(TRTA, name) |>
    dplyr::mutate(
      var_label = "Age (years)"
    )

  res_frq_prop <- res_frq |>
    dplyr::filter(SAFFL == "Y") |>
    tidyr::pivot_wider(
      id_cols = c("TRTA", "name"),
      names_from = "SEX",
      values_from = pct,
      values_fill = c(pct = 0)
    ) |>
    dplyr::arrange(TRTA, name) |>
    dplyr::mutate(
      var_label = "Age (years)"
    )

  res_frq_n$name <- as.character(res_frq_n$name)
  res_frq_prop$name <- as.character(res_frq_prop$name)

  res_frq_n[!names(res_frq_n) %in% c("TRTA", "name", "var_label")] <-
    apply(res_frq_n[!names(res_frq_n) %in% c("TRTA", "name", "var_label")], 2, function(x) {
      gsub(" ", "", as.character(x))
    }) |>
    data.frame()
  res_frq_prop <- res_frq_prop |> data.frame()

  for (i in length(outdata$out_all)) {
    out <- outdata$out_all[[i]]
    res_n <- split(res_frq_n, factor(res_frq_n$TRTA, levels = unique(res_frq_n$TRTA)))[[i]] |>
      data.frame() |>
      select(-c(TRTA))
    rownames(res_n) <- NULL
    res_prop <- split(res_frq_prop, factor(res_frq_prop$TRTA, levels = unique(res_frq_prop$TRTA)))[[i]] |>
      data.frame() |>
      select(-c(TRTA))
    rownames(res_prop) <- NULL
    # Test n
    expect_equal(
      out$char_n[[1]][!out$char_n[[1]]$name %in% c("Mean", "SD", "SE", "Median", "Min", "Max", "Q1 to Q3", "Range", NA), ],
      res_n
    )
    # Test proportion
    expect_equal(
      out$char_prop[[1]][!out$char_prop[[1]]$name %in% c("Mean", "SD", "SE", "Median", "Min", "Max", "Q1 to Q3", "Range", NA), ],
      res_prop
    )
  }
})

test_that("Numeric variables summary", {
  adsl_tot <- data_population |>
    dplyr::mutate(
      TRTA = "Total"
    )
  adsl_tot <- rbind(data_population, adsl_tot)
  adsl_tot_sex <- adsl_tot |>
    dplyr::mutate(
      SEX = "Total"
    )
  adsl_tot <- rbind(adsl_tot, adsl_tot_sex)

  res_stat <-
    adsl_tot |>
    dplyr::summarise(
      n = n_distinct(USUBJID, na.rm = TRUE),
      Mean = mean(AGE, na.rm = TRUE),
      SD = sd(AGE, na.rm = TRUE),
      SE = SD / sqrt(n),
      Median = median(AGE, na.rm = TRUE),
      Min = min(AGE, na.rm = TRUE),
      Max = max(AGE, na.rm = TRUE),
      Q1 = quantile(AGE, probs = 0.25, na.rm = TRUE),
      Q3 = quantile(AGE, probs = 0.75, na.rm = TRUE),
      .by = c(TRTA, SAFFL, SEX)
    ) |>
    dplyr::mutate(
      Q1_to_Q3 = paste0(Q1, " to ", Q3),
      Range = paste0(Min, " to ", Max)
    ) |>
    dplyr::arrange(TRTA, SEX)

  res_stat[c("n", "Mean", "SD", "SE", "Median", "Min", "Max")] <-
    lapply(
      res_stat[c("n", "Mean", "SD", "SE", "Median", "Min", "Max")],
      function(x) {
        formatC(x, format = "f", digits = 1)
      }
    )

  res_stat_n <- res_stat |>
    dplyr::filter(SAFFL == "Y") |>
    dplyr::select(-Q1, -Q3) |>
    dplyr::select(-c(SAFFL, n)) |>
    tidyr::pivot_longer(
      cols = -c("TRTA", "SEX"),
      names_to = "name",
      values_to = "stat"
    ) |>
    tidyr::pivot_wider(
      id_cols = c("TRTA", "name"),
      names_from = "SEX",
      values_from = stat,
      values_fill = c(stat = "0")
    ) |>
    dplyr::mutate(name = gsub("_", " ", name)) |>
    dplyr::mutate(var_label = "Age (years)") |>
    data.frame()

  res_stat_n$name <- factor(
    res_stat_n$name,
    levels = c("Mean", "SD", "SE", "Median", "Min", "Max", "Q1 to Q3", "Range")
  )
  res_stat_n$name <- as.character(res_stat_n$name)


  for (i in length(outdata$out_all)) {
    out <- outdata$out_all[[i]]
    res_n <- split(res_stat_n, factor(res_stat_n$TRTA, levels = unique(res_stat_n$TRTA)))[[i]] |>
      select(-c(TRTA)) |>
      tibble()
    rownames(res_n) <- NULL
    res_stat_prop <- res_n
    res_stat_prop[!names(res_stat_prop) %in% c("name", "var_label")] <- as.double(NA)
    # Test n
    expect_equal(
      out$char_n[[1]][out$char_n[[1]]$name %in% c("Mean", "SD", "SE", "Median", "Min", "Max", "Q1 to Q3", "Range"), ] |> tibble(),
      res_n
    )
    # Test proportion
    expect_equal(
      out$char_prop[[1]][out$char_prop[[1]]$name %in% c("Mean", "SD", "SE", "Median", "Min", "Max", "Q1 to Q3", "Range"), ] |> tibble(),
      res_stat_prop
    )
  }
})

test_that("Population matching", {
  expect_equal(outdata$population, "apat")
})

test_that("Observation matching", {
  expect_equal(outdata$observation, "apat")
})

test_that("Parameter matching", {
  expect_equal(outdata$parameter, "age")
})

test_that("Output from prepare_base_char_subgroup is a list", {
  expect_true("list" %in% class(outdata))
})
