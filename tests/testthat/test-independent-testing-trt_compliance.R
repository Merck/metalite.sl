library(metalite)

adsl <- r2rtf::r2rtf_adsl

meta <- meta_sl_example()
outdata <- prepare_trt_compliance(meta,
  analysis = "trt_compliance",
  population = "apat",
  parameter = "comp8;comp16;comp24"
)

#### Test 1 ######
test_that("rtf output: n, prop, total", {
  path_rtf <- file.path(tempdir(), "trt_compliance.rtf")
  path_rdata <- tempfile(fileext = ".Rdata")


  tbl <- outdata |>
    format_trt_compliance(
      display_stat = c("mean", "sd", "median", "range"),
      display_col = c("n", "prop", "total")
    ) |>
    rtf_trt_compliance(
      orientation = "landscape",
      col_rel_width = c(4, rep(1, 9)),
      "Source: [CDISCpilot: adam-adsl]",
      path_outdata = path_rdata,
      path_outtable = path_rtf
    )


  testthat::expect_snapshot_file(path_rtf)
})

#### Test 2 ######
test_that("rtf output: n, prop, total", {
  path_rtf <- file.path(tempdir(), "trt_compliance1.rtf")
  path_rdata <- tempfile(fileext = ".Rdata")


  tbl <- outdata |>
    format_trt_compliance(
      display_stat = c(),
      display_col = c("n", "prop", "total")
    ) |>
    rtf_trt_compliance(
      orientation = "landscape",
      col_rel_width = c(4, rep(1, 9)),
      "Source: [CDISCpilot: adam-adsl]",
      path_outdata = path_rdata,
      path_outtable = path_rtf
    )


  testthat::expect_snapshot_file(path_rtf)
})
