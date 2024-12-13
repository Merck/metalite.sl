test_that("ae_forestly(): default setting can be executed without error", {
  library(reactable)
  library(htmltools)

  # the "react_subgroup_table()" function is called insided the "react_base_char()" function
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
  file_path <- "_snaps/react_subgroup_table.html"

  if (file.exists(file_path)) {
    # Read in the previous output as a character vector
    previous_output <- as.character(readLines(file_path, warn = FALSE))
  } else {
    previous_output <- NULL
  }

  # Save the current output as HTML
  tryCatch(
    {
      # Save the current output as HTML
      save_html(table_output, file = file_path)

      # Read in the current HTML output as a character vector
      new_output <- as.character(readLines(file_path, warn = FALSE))
    },
    error = function(e) {
      message("Error saving HTML output: ", e$message)
    }
  )


  # Function to clean up HTML for comparison
  clean_html_output <- function(html_lines) {
    # Join lines back into a single string
    html_text <- paste(html_lines, collapse = "\n")

    # Remove id attributes (pattern: id="some-id")
    html_text <- gsub('id="[^"]*"', 'id="PLACEHOLDER_ID"', html_text)

    # Remove data-for attributes (pattern: data-for="some-id")
    html_text <- gsub('data-for="[^"]*"', 'data-for="PLACEHOLDER_DATA_FOR"', html_text)

    return(html_text)
  }

  # Clean the outputs for comparison
  clean_previous_output <- clean_html_output(previous_output)
  clean_new_output <- clean_html_output(new_output)

  # Comparison logic
  if (is.null(previous_output)) {
    message("No previous output to compare, but current output exists.")
  } else {
    expect_equal(clean_previous_output, clean_new_output,
      info = "The cleaned outputs do not match."
    )
  }
})
