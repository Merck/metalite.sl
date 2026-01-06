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
  tbl <- outdata |>
    format_trt_compliance(
      display_stat = c("mean", "sd", "median", "range"),
      display_col = c("n", "prop", "total")
    ) |>
    rtf_trt_compliance(
      orientation = "landscape",
      col_rel_width = c(4, rep(1, 9)),
      "Source: [CDISCpilot: adam-adsl]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "trt_compliance.rtf")
    )

  expect_rtf_snapshot(tbl, "trt_compliance")
})

#### Test 2 ######
test_that("rtf output: n, prop, total (no display_stat)", {
  tbl <- outdata |>
    format_trt_compliance(
      display_stat = c(),
      display_col = c("n", "prop", "total")
    ) |>
    rtf_trt_compliance(
      orientation = "landscape",
      col_rel_width = c(4, rep(1, 9)),
      "Source: [CDISCpilot: adam-adsl]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "trt_compliance1.rtf")
    )

  expect_rtf_snapshot(tbl, "trt_compliance1")
})
