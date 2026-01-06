expect_rtf_snapshot <- function(rtf_obj, name) {
  path_rtf <- file.path(tempdir(), paste0(name, ".rtf"))
  path_rdata <- tempfile(fileext = ".Rdata")

  if (inherits(rtf_obj, "list") && !is.null(rtf_obj$path_outtable)) {
    rtf_obj$path_outtable <- path_rtf
  }
  if (inherits(rtf_obj, "list") && !is.null(rtf_obj$path_outdata)) {
    rtf_obj$path_outdata <- path_rdata
  }

  if (file.exists(path_rtf)) {
    rtf_content <- readLines(path_rtf, warn = FALSE)

    rtf_snapshot_dir <- file.path("tests", "testthat", "rtf")
    dir.create(rtf_snapshot_dir, showWarnings = FALSE, recursive = TRUE)
    file.copy(path_rtf, file.path(rtf_snapshot_dir, paste0(name, ".rtf")), overwrite = TRUE)

    testthat::expect_snapshot(
      cat(rtf_content, sep = "\n")
    )
  } else {
    stop("RTF file was not generated at: ", path_rtf)
  }

  invisible(rtf_obj)
}
