library(reactable)
library(htmltools)

test_that("Testing react_base_char function", {
  # the "react_subgroup_table()" function is called inside the "react_base_char()" function

  table <- react_base_char(
    metadata_sl = meta_sl_example(),
    metadata_ae = metalite.ae::meta_ae_example(),
    population = "apat",
    observation = "wk12",
    display_total = TRUE,
    sl_parameter = "age;gender;race",
    ae_subgroup = c("age", "race", "gender"),
    ae_specific = "rel",
    width = 1200
  )

  html <- gsub("id=\"htmlwidget-[A-Za-z0-9]+\"", "id=\"htmlwidget-123456\"", table)
  html <- gsub(
    "\"dataKey\":\"[a-f0-9]{32}\"", # Regex pattern to match the dataKey
    "\"dataKey\":\"fixed_data_key\"", # New fixed dataKey value
    html
  )

  expect_snapshot(html)
})
