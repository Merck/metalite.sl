library(metalite)

set.seed(123)
metatest <- meta_sl_exposure_example()

outdata <- prepare_sl_summary(
  meta = metatest,
  population = "apat",
  analysis = "exp_dur",
  parameter = "expdur"
)


# #### Test 1 ######
test_that("rtf output: n, and prop, NO total. With 2 decimal places.", {
  tbl <- outdata |>
    format_exp_duration(
      display_col = c("n", "prop"),
      digits_prop = 2
    ) |>
    rtf_exp_duration(
      source = "Source: [CDISCpilot: adam-adexsum]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "exp0duration1.rtf")
    )

  expect_rtf_snapshot(tbl, "exp0duration1")
})

# #### Test 2 #####
test_that("rtf output: n, prop and total, with Landscape", {
  tbl <- outdata |>
    format_exp_duration(display_col = c("n", "prop", "total")) |>
    rtf_exp_duration(
      orientation = "landscape",
      col_rel_width = NULL,
      source = "Source: [CDISCpilot: adam-adexsum]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "exp0duration2.rtf")
    )

  expect_rtf_snapshot(tbl, "exp0duration2")
})


# #### Test 3 #####
test_that("rtf output: n, prop and total, with no value of col_rel_width", {
  tbl <- outdata |>
    format_exp_duration(display_col = c("n", "prop", "total")) |>
    rtf_exp_duration(
      col_rel_width = c(4, 2, 2, 2, 2, 2, 2, 3, 3, 3),
      source = "Source: [CDISCpilot: adam-adexsum]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "exp0duration3.rtf")
    )

  expect_rtf_snapshot(tbl, "exp0duration3")
})
