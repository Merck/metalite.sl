
library(metalite)
library(metalite.ae)
library(dplyr)
library(tidyr)   

# Read data
adsl <- r2rtf::r2rtf_adsl


# Create ADEXSUM dataset
adexsum <- data.frame(USUBJID=adsl$USUBJID)
adexsum$TRTA <- factor(adsl$TRT01A,
                       levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
                       labels = c("Placebo", "Low Dose", "High Dose")
)

adexsum$TRTAN <- adsl$TRT01AN
adexsum$SAFFL <- adsl$SAFFL

names(adexsum$TRTA) <- "TREATMENT"

adexsum$APERIODC <- "Base"
adexsum$APERIOD <- 1
adexsum$AVAL <- sample(x = 0:(24*7), size = length(adexsum$USUBJID), replace = TRUE)
adexsum$EXDURGR <- "not treated"
adexsum$EXDURGR[adexsum$AVAL>=1] <- ">=1 day"
adexsum$EXDURGR[adexsum$AVAL>=7] <- ">=7 days"
adexsum$EXDURGR[adexsum$AVAL>=28] <- ">=28 days"
adexsum$EXDURGR[adexsum$AVAL>=12*7] <- ">=12 weeks"
adexsum$EXDURGR[adexsum$AVAL>=24*7] <- ">=24 weeks"

adexsum$EXDURGR <- factor(adexsum$EXDURGR,
                          levels = c("not treated", ">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks"))

plan <- metalite::plan(
  analysis = "exp_dur", 
  population = "apat",
  observation = "apat", 
  parameter = "expdur"
) 

# Create test metadata
meta_test <- metalite::meta_adam(
  population = adexsum,
  observation = adexsum
) |>
  metalite::define_plan(plan) |>
  metalite::define_population(
    name = "apat",
    group = "TRTA",
    subset = quote(APERIOD==1 & AVAL>0)
  ) |>
  metalite::define_parameter(
    name = "expdur",
    var = "AVAL",
    label = "Exposure Duration (Days)",
    vargroup = "EXDURGR"
  )|>
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


# Prepare adding more info
adexsum_tot <- adexsum |> select(-c(TRTAN))  |> mutate(TRTA = "Overall")

adexsum_tot <- adexsum_tot |> mutate(TRTAN=9999)

adexsum_tot <- rbind(adexsum, adexsum_tot)

adexsum_tot <- adexsum_tot |> filter(APERIOD==1 & AVAL>0 & SAFFL == "Y")

exdurgr_value <- as.character(sort(unique(adexsum_tot$EXDURGR)))


# Testing


# 1
test_that("When display_col contains n and prop then the total column disappears", {
  dis <- c("n", "prop")
  test <- format_exp_duration(
    test_meta_exp_dur,
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

# 2
test_that("When digits_prop is specified then the proportions are rounded to the decimal place", {
  dis <- c("n", "prop", "total")
  
  test_dig0 <- format_exp_duration(
    test_meta_exp_dur,
    display_col = dis,
    digits_prop = 0
  )
  
  test_dig2 <- format_exp_duration(
    test_meta_exp_dur,
    display_col = dis,
    digits_prop = 2
  )
  
  test_meta_exp_dur$char_prop
  test_meta_prop_char <- NULL
  
  for (i in (1:length(test_meta_exp_dur$char_var))) {
    
    test_meta_prop_char <-
      rbind(
        test_meta_prop_char,
        tibble(test_meta_exp_dur$char_prop[[i]])
      )
    
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
    names(res_frq_prop0) <- c("name", paste0("p_", seq(1, length(test_meta_exp_dur$group_label))), "p_9999")
    names(res_frq_prop2) <- c("name", paste0("p_", seq(1, length(test_meta_exp_dur$group_label))), "p_9999")
  } else {
    names(res_frq_prop0) <- c("name", paste0("p_", seq(1, length(test_meta_exp_dur$group_label))))
    names(res_frq_prop2) <- c("name", paste0("p_", seq(1, length(test_meta_exp_dur$group_label))))
  }
  
  test_dig0dat <- test_dig0$tbl |>
    filter(!name %in% c("Participants in population", "Mean", "SD", "SE", "Median", "Q1 to Q3", "Range", "Min", "Max")) |>
    select(c("name", starts_with("p_"))
    )
  
  
  expect_equal(
    test_dig0dat,
    res_frq_prop0 |>
      filter(!name %in% c("Participants in population", "Mean", "SD", "SE", "Median", "Q1 to Q3", "Range", "Min", "Max"))
  )
  
  expect_equal(
    test_dig2$tbl |>
      filter(!name %in% c("Participants in population", "Mean", "SD", "SE", "Median", "Q1 to Q3", "Range", "Min", "Max")) |>
      select(c("name", starts_with("p_"))),
    res_frq_prop2 |>
      filter(!name %in% c("Participants in population", "Mean", "SD", "SE", "Median", "Q1 to Q3", "Range", "Min", "Max"))
  )
})

# 3
test_that("When display_stat contains mean then Mean row is included", {
  
  hold <- c("SD", "SE", "Median", "Min", "Max", "Q1 to Q3", "Range")
  
  test <- format_exp_duration(
    test_meta_exp_dur,
    display_col = c("n", "prop", "total"),
    display_stat = c("mean")
  )
  
  expect_equal(
    as.vector(c(
      "Participants in population", "not treated",
      exdurgr_value,
      "Mean"
    )),
    
    test$tbl[["name"]][!as.vector(test$tbl[["name"]]) %in% hold]
    
  )
})

# 4
test_that("When display_stat contains sd then SD row is included", {
  
  hold <- c("Mean", "SE", "Median", "Min", "Max", "Q1 to Q3", "Range")
  
  test <- format_exp_duration(
    test_meta_exp_dur,
    display_col = c("n", "prop", "total"),
    display_stat = c("sd")
  )
  
  expect_equal(
    as.vector(c(
      "Participants in population", "not treated",
      exdurgr_value,
      "SD"
    )),
    test$tbl[["name"]][!as.vector(test$tbl[["name"]]) %in% hold]
  )
})

# 5
test_that("When display_stat contains se then SE row is included", {
  
  hold <- c("Mean", "SD", "Median", "Min", "Max", "Q1 to Q3", "Range")
  
  test <- format_exp_duration(
    test_meta_exp_dur,
    display_col = c("n", "prop", "total"),
    display_stat = c("se")
  )
  
  expect_equal(
    as.vector(c(
      "Participants in population", "not treated",
      exdurgr_value,
      "SE"
   ) ),
    test$tbl[["name"]][!as.vector(test$tbl[["name"]]) %in% hold]
  )
})

# 6
test_that("When display_stat contains median then Median row is included", {
  
  hold <- c("Mean", "SD", "SE", "Min", "Max", "Q1 to Q3", "Range")
  
  test <- format_exp_duration(
    test_meta_exp_dur,
    display_col = c("n", "prop", "total"),
    display_stat = c("median")
  )
  
  expect_equal(
    as.vector(c(
      "Participants in population", "not treated",
      exdurgr_value,
      "Median"
    )),
    test$tbl[["name"]][!as.vector(test$tbl[["name"]]) %in% hold]
  )
})

# 7

test_that("When display_stat contains q1 to q3 then q1 to q3 row is included", {
  
  hold <- c("Mean", "SD", "SE", "Min", "Max", "Median", "Range")
  
  test <- format_exp_duration(
    test_meta_exp_dur,
    display_col = c("n", "prop", "total"),
    display_stat = c("q1 to q3")
  )
  
  expect_equal(
    as.vector(c(
      "Participants in population", "not treated",
      exdurgr_value,
      "Q1 to Q3"
    )),
    test$tbl[["name"]][!as.vector(test$tbl[["name"]]) %in% hold]
  )
})

# 8

test_that("When display_stat contains range then Range row is included", {
  
  hold <- c("Mean", "SD", "SE", "Min", "Max", "Median", "Q1 to Q3")
  
  test <- format_exp_duration(
    test_meta_exp_dur,
    display_col = c("n", "prop", "total"),
    display_stat = c("range")
  )
  
  expect_equal(
    as.vector(c(
      "Participants in population", "not treated",
      exdurgr_value,
      "Range"
    )),
    test$tbl[["name"]][!as.vector(test$tbl[["name"]]) %in% hold]
  )
})
