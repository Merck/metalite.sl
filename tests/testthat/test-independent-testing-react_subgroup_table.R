test_that("Testing react_subgroup_table function via calling react_base_char function", {
  library(reactable)
  library(htmltools)
  if (!require("htmlwidgets", character.only = TRUE)) {
    install.packages("htmlwidgets")
    library(htmlwidgets)
  }

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


  # Define the file path for the HTML output
  file_path <- "react_subgroup_table.html"

  # Save the table output to the HTML file:  use saveWidget to save the reactable output
  saveWidget(table_output, file_path, selfcontained = TRUE)

  # Use expect_snapshot_file to compare the file against the snapshot
  expect_snapshot_file(file_path)
})
