meta <- meta_sl_example()

test_that("rtf output: n and prop including subgroup total w/o total", {
  path_rtf <- file.path(tempdir(), "base0char0subgroup1.rtf")
  path_rdata <- tempfile(fileext = ".Rdata")
  
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA"),
    display_subgroup_total = TRUE
  )
  tbl <- outdata |>
    format_base_char_subgroup(
      display = c("n", "prop")
    ) |>
    rtf_base_char_subgroup(
      source = "Source:  [CDISCpilot: adam-adsl]",
      path_outdata = path_rdata,
      path_outtable = path_rtf
    )

  testthat::expect_snapshot_file(path_rtf)
})

test_that("rtf output: n and prop including subgroup total w/ total", {
  path_rtf <- file.path(tempdir(), "base0char0subgroup2.rtf")
  path_rdata <- tempfile(fileext = ".Rdata")
  
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA"),
    display_subgroup_total = TRUE
  )
  tbl <- outdata |>
    format_base_char_subgroup(
      display = c("n", "prop", "total")
    ) |>
    rtf_base_char_subgroup(
      source = "Source:  [CDISCpilot: adam-adsl]",
      path_outdata = path_rdata,
      path_outtable = path_rtf
    )
  
  testthat::expect_snapshot_file(path_rtf)
})

test_that("rtf output: n and prop not including subgroup total w/o total", {
  path_rtf <- file.path(tempdir(), "base0char0subgroup3.rtf")
  path_rdata <- tempfile(fileext = ".Rdata")
  
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA"),
    display_subgroup_total = FALSE
  )
  tbl <- outdata |>
    format_base_char_subgroup(
      display = c("n", "prop")
    ) |>
    rtf_base_char_subgroup(
      source = "Source:  [CDISCpilot: adam-adsl]",
      path_outdata = path_rdata,
      path_outtable = path_rtf
    )
  
  testthat::expect_snapshot_file(path_rtf)
})

test_that("rtf output: n and prop not including subgroup total w/ total", {
  path_rtf <- file.path(tempdir(), "base0char0subgroup4.rtf")
  path_rdata <- tempfile(fileext = ".Rdata")
  
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA"),
    display_subgroup_total = FALSE
  )
  tbl <- outdata |>
    format_base_char_subgroup(
      display = c("n", "prop", "total")
    ) |>
    rtf_base_char_subgroup(
      source = "Source:  [CDISCpilot: adam-adsl]",
      path_outdata = path_rdata,
      path_outtable = path_rtf
    )
  
  testthat::expect_snapshot_file(path_rtf)
})

test_that("relative width 'works' with display_subgroup_total = FALSE", {
  path_rtf <- file.path(tempdir(), "base0char0subgroup5.rtf")
  path_rdata <- tempfile(fileext = ".Rdata")

  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA"),
    display_subgroup_total = FALSE
  )
  
  expect_error(
    {
      tbl <- outdata |>
        format_base_char_subgroup(
          display = c("n", "prop")
        ) |>
        rtf_base_char_subgroup(
          source = "Source:  [CDISCpilot: adam-adsl]",
          col_rel_width = c(3, rep(2, 2 * 2 * 3)),
          path_outdata = path_rdata,
          path_outtable = path_rtf
        )
    },
    regexp = "col_rel_width must have the same length"
  )
  expect_message(
    {
      tbl <- outdata |>
        format_base_char_subgroup(
          display = c("n", "prop")
        ) |>
        rtf_base_char_subgroup(
          source = "Source:  [CDISCpilot: adam-adsl]",
          col_rel_width = c(3, rep(2, 2 * 2 * 3), 2),
          path_outdata = path_rdata,
          path_outtable = path_rtf
        )
    },
    regexp = "The outdata is saved"
  )
})

test_that("relative width 'works' display_subgroup_total = TRUE", {
  path_rtf <- file.path(tempdir(), "base0char0subgroup6.rtf")
  path_rdata <- tempfile(fileext = ".Rdata")
  
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA"),
    display_subgroup_total = TRUE
  )
  
  expect_error(
    {
      tbl <- outdata |>
        format_base_char_subgroup(
          display = c("n", "prop")
        ) |>
        rtf_base_char_subgroup(
          source = "Source:  [CDISCpilot: adam-adsl]",
          col_rel_width = c(3, rep(2, 2 * 3 * 3)),
          path_outdata = path_rdata,
          path_outtable = path_rtf
        )
    },
    regexp = "col_rel_width must have the same length"
  )
  expect_message(
    {
      tbl <- outdata |>
        format_base_char_subgroup(
          display = c("n", "prop")
        ) |>
        rtf_base_char_subgroup(
          source = "Source:  [CDISCpilot: adam-adsl]",
          col_rel_width = c(3, rep(2, 2 * 3 * 3), 2),
          path_outdata = path_rdata,
          path_outtable = path_rtf
        )
    },
    regexp = "The outdata is saved"
  )
})