library(reactable)
library(htmltools)

test_that("Testing react_subgroup_table function", {
  # the "react_subgroup_table()" function is called inside the "react_base_char()" function
  outdata <- metalite.ae::prepare_ae_specific_subgroup(
    metalite.ae::meta_ae_example(),
    population = "apat",
    observation = "wk12",
    parameter = "rel",
    subgroup_var = "SEX",
    display_subgroup_total = FALSE # total display for subgroup is not needed
  ) |>
    metalite.ae::format_ae_specific_subgroup()

  table <- react_subgroup_table(outdata$tbl, outdata$group, "F")

  html <- gsub("id=\"htmlwidget-[A-Za-z0-9]+\"", "id=\"htmlwidget-123456\"", table)
  html <- gsub(
    "\"dataKey\":\"[a-f0-9]{32}\"", # Regex pattern to match the dataKey
    "\"dataKey\":\"fixed_data_key\"", # New fixed dataKey value
    html
  )

  expect_snapshot(html)
})
