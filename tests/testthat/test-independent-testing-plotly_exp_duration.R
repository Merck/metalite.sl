library(plotly)
library(htmlwidgets)
library(testthat)
library(htmltools)
library(pandoc)

if (!require("vdiffr", character.only = TRUE)) {
  install.packages("vdiffr")
  library(vdiffr)
}


# Prepare data
meta <- meta_sl_exposure_example()

outdata <- meta |> prepare_exp_duration()


outdata_plot <- outdata |>
  extend_exp_duration(
    duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
    duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
  )


save_tags <- function(tags, file, selfcontained = TRUE, libdir = "./lib") {
  if (is.null(libdir)) {
    libdir <- paste(tools::file_path_sans_ext(basename(file)), "_files", sep = "")
  }

  htmltools::save_html(tags, file = file, libdir = libdir)

  if (selfcontained) {
    if (!pandoc:::pandoc_available()) {
      stop(
        "Saving a widget with selfcontained = TRUE requires pandoc. For details see:\n",
        "https://github.com/rstudio/rmarkdown/blob/master/PANDOC.md"
      )
    }

    # htmlwidgets:::pandoc_self_contained_html(tags, file)  # this creates .html but the file does not render in browser but displaying codes
    # htmlwidgets::saveWidget is designed to save a single htmlwidget, which might be the reason 'saveWidget' is not working here, we have interactive plot with multiple htmlwidgets
    # htmlwidgets::saveWidget(tags, file = file, selfcontained = TRUE)

    unlink(libdir, recursive = TRUE)
  }
  return(file)
}

# Testing the plotly_exp_duration function - run multiple plots
test_that("Interactive plot is created successfully", {
  interactive_plot <- outdata_plot |> plotly_exp_duration(plot_type_label = c("Histogram", "Stacked histogram", "Horizontal histogram"))

  # str(interactive_plot)
  expect_s3_class(interactive_plot, "shiny.tag.list")

  # expect_doppelganger("Test_plotly_exp_duration", interactive_plot)  # for static plot only


  file_path <- file.path(getwd(), "_snaps", "Test_plotly_exp_duration.html")
  print(file_path)

  save_tags(interactive_plot, file = file_path, selfcontained = TRUE)

  # Check if the file was saved
  expect_true(file.exists(file_path))
})
