meta <- meta_sl_example()
# Standard example
outdata <- prepare_base_char_subgroup(
  meta,
  population = "apat",
  parameter = "age",
  subgroup_var = "TRTA",
  subgroup_header = c("SEX", "TRTA"),
  display_subgroup_total = TRUE
)
# Without summary statistics
outdata_nostat <- prepare_base_char_subgroup(
  meta,
  population = "apat",
  parameter = "gender",
  subgroup_var = "TRTA",
  subgroup_header = c("AGEGR1", "TRTA"),
  display_subgroup_total = TRUE
)
# Get values
agegr1_value <- as.character(sort(unique(meta$data_population$AGEGR1)))
sex_value <- as.character(sort(unique(meta$data_population$SEX)))

# Testing
test_that("When display is n, prop then display only n and prop", {
  test1 <- format_base_char_subgroup(
    outdata,
    display = c("n", "prop")
  )
  exp_header <-
    c(
      lapply(outdata$subgroup, function(x) paste0(x, "n_", seq_along(outdata$group))) |> unlist(),
      lapply(outdata$subgroup, function(x) paste0(x, "p_", seq_along(outdata$group))) |> unlist()
    )

  expect_equal(test1$display, c("n", "prop"))
  expect_true(all(exp_header %in% names(test1$tbl)))
})

test_that("When display is n, prop, total then display only n, prop and total", {
  test2 <- format_base_char_subgroup(
    outdata,
    display = c("n", "prop", "total")
  )
  exp_header <-
    c(
      lapply(outdata$subgroup, function(x) paste0(x, "n_", c(seq_along(outdata$group), 9999))) |> unlist(),
      lapply(outdata$subgroup, function(x) paste0(x, "p_", c(seq_along(outdata$group), 9999))) |> unlist()
    )

  expect_equal(test2$display, c("n", "prop", "total"))
  expect_true(all(exp_header %in% names(test2$tbl)))
})

test_that("When display_stat contains mean then Mean row is included", {
  test3 <- format_base_char_subgroup(
    outdata,
    display = c("n", "prop"),
    display_stat = c("mean")
  )

  expect_equal(
    c(
      "Participants in population",
      agegr1_value,
      NA,
      "Mean"
    ),
    test3$tbl[["name"]]
  )
})

test_that("When display_stat contains sd then SD row is included", {
  test4 <- format_base_char_subgroup(
    outdata,
    display = c("n", "prop"),
    display_stat = c("sd")
  )

  expect_equal(
    c(
      "Participants in population",
      agegr1_value,
      NA,
      "SD"
    ),
    test4$tbl[["name"]]
  )
})

test_that("When display_stat contains median then Median row is included", {
  test5 <- format_base_char_subgroup(
    outdata,
    display = c("n", "prop"),
    display_stat = c("median")
  )

  expect_equal(
    c(
      "Participants in population",
      agegr1_value,
      NA,
      "Median"
    ),
    test5$tbl[["name"]]
  )
})

test_that("When display_stat contains range then Range row is included", {
  test6 <- format_base_char_subgroup(
    outdata,
    display = c("n", "prop"),
    display_stat = c("range")
  )

  expect_equal(
    c(
      "Participants in population",
      agegr1_value,
      NA,
      "Range"
    ),
    test6$tbl[["name"]]
  )
})

test_that("Summary statistics are not disply when they are not included", {
  test7 <- format_base_char_subgroup(
    outdata_nostat,
    display = c("n", "prop")
  )

  expect_equal(
    c(
      "Participants in population",
      sex_value
    ),
    test7$tbl[["name"]]
  )
})
