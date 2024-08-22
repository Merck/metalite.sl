library(metalite)

adsl <- r2rtf::r2rtf_adsl

meta <- meta_sl_example()
outdata <- prepare_disposition(meta,
                                  analysis = "disp",
                                  population = "apat",
                                  parameter="disposition;medical-disposition")

#### Test 1 ######
test_that("rtf output: n, prop, total", {
  path_rtf <- file.path(tempdir(), "disposition1.rtf")
  path_rdata <- tempfile(fileext = ".Rdata")
  
  
  tbl <- outdata |>
    format_disposition(display_stat = c("mean", "sd", "median", "range"), 
                          display_col = c("n", "prop", "total")
    )|>
    rtf_disposition(
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
  path_rtf <- file.path(tempdir(), "disposition2.rtf")
  path_rdata <- tempfile(fileext = ".Rdata")
  
  
  tbl <- outdata |>
    format_disposition(display_stat = c(), 
                       display_col = c("n", "prop", "total")
    )|>
    rtf_disposition(
      orientation = "landscape",
      col_rel_width = c(4, rep(1, 9)),
      "Source: [CDISCpilot: adam-adsl]",
      path_outdata = path_rdata,
      path_outtable = path_rtf
    )
  
  
  testthat::expect_snapshot_file(path_rtf)
})



