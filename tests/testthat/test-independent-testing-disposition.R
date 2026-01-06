library(metalite)

adsl <- r2rtf::r2rtf_adsl

set.seed(123)

meta <- meta_sl_example()
outdata <- prepare_disposition(meta,
  analysis = "disp",
  population = "apat",
  parameter = "disposition;medical-disposition"
)

#### Test 1 ######
test_that("rtf output: n, prop, total", {
  tbl <- outdata |>
    format_disposition(
      display_stat = c("mean", "sd", "median", "range"),
      display_col = c("n", "prop", "total")
    ) |>
    rtf_disposition(
      orientation = "landscape",
      col_rel_width = c(4, rep(1, 9)),
      "Source: [CDISCpilot: adam-adsl]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "disposition1.rtf")
    )

  expect_rtf_snapshot(tbl, "disposition1")
})

#### Test 2 ######
test_that("rtf output: n, prop, total", {
  tbl <- outdata |>
    format_disposition(
      display_stat = c(),
      display_col = c("n", "prop", "total")
    ) |>
    rtf_disposition(
      orientation = "landscape",
      col_rel_width = c(4, rep(1, 9)),
      "Source: [CDISCpilot: adam-adsl]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "disposition2.rtf")
    )

  expect_rtf_snapshot(tbl, "disposition2")
})
