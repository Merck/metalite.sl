# library(metalite)
# 
# meta <- meta_sl_example()
# outdata <- prepare_sl_summary(meta,
#   population = "apat",
#   observation = "apat",
#   parameter = "age;gender"
# )
# 
# #### Test 1 ######
# test_that("rtf output: n, and prop, NO total. With 2 decimal places.", {
#   path_rtf <- file.path(tempdir(), "base0char1.rtf")
#   path_rdata <- tempfile(fileext = ".Rdata")
# 
#   tbl <- outdata |>
#     format_base_char(
#       display_col = c("n", "prop"),
#       digits_prop = 4
#     ) |>
#     rtf_base_char(
#       source = "Source: [CDISCpilot: adam-adsl]",
#       path_outdata = path_rdata,
#       path_outtable = path_rtf
#     )
# 
#   testthat::expect_snapshot_file(path_rtf)
# })
# 
# #### Test 2 #####
# test_that("rtf output: n, prop and total, with Landscape, manual entory of col_rel_width", {
#   path_rtf <- file.path(tempdir(), "base0char2.rtf")
#   path_rdata <- tempfile(fileext = ".Rdata")
# 
#   tbl <- outdata |>
#     format_base_char() |>
#     rtf_base_char(
#       orientation = "landscape",
#       col_rel_width = c(4, 2, 2, 2, 2, 2, 2, 2, 2, 3),
#       source = "Source: [CDISCpilot: adam-adsl]",
#       path_outdata = path_rdata,
#       path_outtable = path_rtf
#     )
# 
#   testthat::expect_snapshot_file(path_rtf)
# })
# 
# 
# #### Test 3 #####
# test_that("rtf output: n, prop and total, with no value of col_rel_width", {
#   path_rtf <- file.path(tempdir(), "base0char3.rtf")
#   path_rdata <- tempfile(fileext = ".Rdata")
# 
#   tbl <- outdata |>
#     format_base_char(display_col = c("n", "prop", "total")) |>
#     rtf_base_char(
#       col_rel_width = c(4, 2, 2, 2, 2, 2, 2, 3, 3, 3),
#       source = "Source: [CDISCpilot: adam-adsl]",
#       path_outdata = path_rdata,
#       path_outtable = path_rtf
#     )
# 
#   testthat::expect_snapshot_file(path_rtf)
# })
