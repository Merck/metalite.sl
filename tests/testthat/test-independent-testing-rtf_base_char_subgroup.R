meta <- meta_sl_example()
data_population <- meta$data_population
data_population$AGEGR1 <- factor(
  data_population$AGEGR1,
  levels = c("<65", "65-80", ">80"),
  labels = c("<65", "65-80", ">80")
)
data_population$SEX <- factor(
  data_population$SEX,
  levels = c("F", "M"),
  labels = c("Female", "Male")
)
meta$data_population <- data_population


test_that("rtf output: n and prop including subgroup total w/o total", {
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA")
  )
  tbl <- outdata |>
    format_base_char_subgroup(
      display = c("n", "prop"),
      display_total = TRUE
    ) |>
    rtf_base_char_subgroup(
      source = "Source:  [CDISCpilot: adam-adsl]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "base0char0subgroup1.rtf")
    )

  expect_rtf_snapshot(tbl, "base0char0subgroup1")
})

test_that("rtf output: n and prop including subgroup total w/ total", {
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA")
  )
  tbl <- outdata |>
    format_base_char_subgroup(
      display = c("n", "prop", "total"),
      display_total = TRUE
    ) |>
    rtf_base_char_subgroup(
      source = "Source:  [CDISCpilot: adam-adsl]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "base0char0subgroup2.rtf")
    )

  expect_rtf_snapshot(tbl, "base0char0subgroup2")
})

test_that("rtf output: n and prop not including subgroup total w/o total", {
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA")
  )
  tbl <- outdata |>
    format_base_char_subgroup(
      display = c("n", "prop"),
      display_total = FALSE
    ) |>
    rtf_base_char_subgroup(
      source = "Source:  [CDISCpilot: adam-adsl]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "base0char0subgroup3.rtf")
    )

  expect_rtf_snapshot(tbl, "base0char0subgroup3")
})

test_that("rtf output: n and prop not including subgroup total w/ total", {
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA")
  )
  tbl <- outdata |>
    format_base_char_subgroup(
      display = c("n", "prop", "total"),
      display_total = FALSE
    ) |>
    rtf_base_char_subgroup(
      source = "Source:  [CDISCpilot: adam-adsl]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "base0char0subgroup4.rtf")
    )

  expect_rtf_snapshot(tbl, "base0char0subgroup4")
})


test_that("rtf output: no group/subgroup total when a subgroup has no subject", {
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "race",
    subgroup_var = "SEX",
    subgroup_header = c("SEX", "TRTA")
  )
  tbl <- outdata |>
    format_base_char_subgroup(
      display = c("n", "prop"),
      display_total = FALSE
    ) |>
    rtf_base_char_subgroup(
      source = "Source:  [CDISCpilot: adam-adsl]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "base0char0subgroup5.rtf")
    )

  expect_rtf_snapshot(tbl, "base0char0subgroup5")
})

test_that("rtf output: group/subgroup total when a subgroup has no subject", {
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "race",
    subgroup_var = "SEX",
    subgroup_header = c("SEX", "TRTA")
  )
  tbl <- outdata |>
    format_base_char_subgroup(
      display = c("n", "prop", "total"),
      display_total = TRUE
    ) |>
    rtf_base_char_subgroup(
      source = "Source:  [CDISCpilot: adam-adsl]",
      path_outdata = tempfile(fileext = ".Rdata"),
      path_outtable = file.path(tempdir(), "base0char0subgroup6.rtf")
    )

  expect_rtf_snapshot(tbl, "base0char0subgroup6")
})

test_that("relative width 'works' with display_subgroup_total = FALSE", {
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA")
  )

  expect_error(
    {
      tbl <- outdata |>
        format_base_char_subgroup(
          display = c("n", "prop"),
          display_total = FALSE
        ) |>
        rtf_base_char_subgroup(
          source = "Source:  [CDISCpilot: adam-adsl]",
          col_rel_width = c(3, rep(2, 2 * 2 * 3)),
          path_outdata = tempfile(fileext = ".Rdata"),
          path_outtable = file.path(tempdir(), "rwnt_base0char0subgroup.rtf")
        )
    },
    regexp = "col_rel_width must have the same length"
  )
  expect_message(
    {
      tbl <- outdata |>
        format_base_char_subgroup(
          display = c("n", "prop"),
          display_total = FALSE
        ) |>
        rtf_base_char_subgroup(
          source = "Source:  [CDISCpilot: adam-adsl]",
          col_rel_width = c(3, rep(2, 2 * 2 * 3), 2),
          path_outdata = tempfile(fileext = ".Rdata"),
          path_outtable = file.path(tempdir(), "rwnt_base0char0subgroup2.rtf")
        )
    },
    regexp = "The outdata is saved"
  )
})

test_that("relative width 'works' display_subgroup_total = TRUE", {
  outdata <- prepare_base_char_subgroup(
    meta,
    population = "apat",
    parameter = "age",
    subgroup_var = "TRTA",
    subgroup_header = c("SEX", "TRTA")
  )

  expect_error(
    {
      tbl <- outdata |>
        format_base_char_subgroup(
          display = c("n", "prop"),
          display_total = TRUE
        ) |>
        rtf_base_char_subgroup(
          source = "Source:  [CDISCpilot: adam-adsl]",
          col_rel_width = c(3, rep(2, 2 * 2 * 4)),
          path_outdata = tempfile(fileext = ".Rdata"),
          path_outtable = file.path(tempdir(), "rwt_base0char0subgroup.rtf")
        )
    },
    regexp = "col_rel_width must have the same length"
  )
  expect_message(
    {
      tbl <- outdata |>
        format_base_char_subgroup(
          display = c("n", "prop"),
          display_total = TRUE
        ) |>
        rtf_base_char_subgroup(
          source = "Source:  [CDISCpilot: adam-adsl]",
          col_rel_width = c(3, rep(2, 2 * 2 * 4), 2),
          path_outdata = tempfile(fileext = ".Rdata"),
          path_outtable = file.path(tempdir(), "rwt_base0char0subgroup2.rtf")
        )
    },
    regexp = "The outdata is saved"
  )
})
