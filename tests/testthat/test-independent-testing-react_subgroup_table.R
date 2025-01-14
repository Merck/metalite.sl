library(reactable)
library(htmltools)

expect_and_replace_dataKey <- function(tbl, newDataKey = "__predictable_data_key__") {
  dataKey <- tbl$x$tag$attribs$dataKey
  expect_true(is.character(dataKey) && nchar(dataKey) > 0)
  tbl$x$tag$attribs$dataKey <- newDataKey
  tbl
}

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
  table_output <- expect_and_replace_dataKey(table_output)
  rendered <- htmltools::renderTags(table_output)
  expect_snapshot(cat(rendered$html))
})
