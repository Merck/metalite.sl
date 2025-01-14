library(reactable)
library(htmltools)

test_that("Testing react_subgroup_table function via calling react_base_char function", {
  # the "react_subgroup_table()" function is called inside the "react_base_char()" function
  table_output <- react_base_char(
    metadata_sl = meta_sl_example(),
    metadata_ae = metalite.ae::meta_ae_example(),
    population = "apat",
    observation = "wk12",
    display_total = TRUE,
    sl_parameter = "age;race",
    ae_subgroup = c("age", "race"),
    ae_specific = "rel",
    width = 1200
  )

  rendered <- htmltools::renderTags(table_output)
  expect_snapshot(cat(rendered$html))
})
