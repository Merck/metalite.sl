# Copyright (c) 2024 Merck & Co., Inc., Rahway, NJ, USA and its affiliates.
# All rights reserved.
#
# This file is part of the metalite.sl program.
#
# metalite.sl is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#' Baseline characteristic table
#'
#' @param outdata An `outdata` object created by [prepare_sl_summary()].
#' @param source A character value of the data source.
#' @inheritParams r2rtf::rtf_page
#' @inheritParams r2rtf::rtf_body
#' @param footnotes A character vector of table footnotes.
#' @param title Term "analysis", "observation" and "population") for collecting title from metadata or a character vector of table titles.
#' @param path_outdata A character string of the outdata path.
#' @param path_outtable A character string of the outtable path.
#'
#' @return RTF file and source dataset for baseline characteristic table.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#'
#' meta |>
#'   prepare_sl_summary(
#'     population = "apat",
#'     analysis = "base_char",
#'     parameter = "age;gender"
#'   ) |>
#'   format_sl_summary() |>
#'   rtf_sl_summary(
#'     source = "Source: [CDISCpilot: adam-adsl]",
#'     path_outdata = tempfile(fileext = ".Rdata"),
#'     path_outtable = tempfile(fileext = ".rtf")
#'   )
rtf_sl_summary <- function(
    outdata,
    source,
    col_rel_width = NULL,
    text_font_size = 9,
    orientation = "portrait",
    footnotes = NULL,
    title = NULL,
    path_outdata = NULL,
    path_outtable = NULL) {
  # Set default column width
  tbl <- outdata$tbl
  display_total <- "total" %in% outdata$display_col
  if (display_total == TRUE) {
    group <- c(levels(outdata$group_label), "Total")
    n_group <- length(outdata$group_label) + 1
  } else {
    group <- levels(outdata$group_label)
    n_group <- length(outdata$group_label)
  }
  n_row <- nrow(tbl)
  n_col <- ncol(tbl)

  if (!is.null(col_rel_width) && !(n_col == length(col_rel_width))) {
    stop(
      "col_rel_width must have the same length (has ",
      length(col_rel_width),
      ") as as `outdata$tbl` has number of columns (has ",
      n_col, ").",
      call. = FALSE
    )
  }

  # Set default title
  if (is.null(title)) {
    title <- metalite::collect_title(outdata$meta,
      outdata$population,
      "",
      outdata$parameter,
      analysis = outdata$analysis
    )
  }

  # Set default footnote
  footnotes_stat <- NULL
  if ("numeric" %in% outdata$var_type) {
    if ("sd" %in% tolower(outdata$display_stat)) {
      footnotes_stat <- c(footnotes_stat, "SD=Standard deviation")
    }
    if ("se" %in% tolower(outdata$display_stat)) {
      footnotes_stat <- c(footnotes_stat, paste0("SE=Standard err", "or"))
    }
    if ("q1 to q3" %in% tolower(outdata$display_stat)) {
      footnotes_stat <- c(footnotes_stat, "Q1=First quartile, Q3=Third quartile")
    }
    # combine footnotes for abbreviation of statistics
    footnotes_stat <- paste(footnotes_stat, collapse = "; ")
    # combine with user defined footnotes if not NULL
    if (nchar(footnotes_stat) > 0) {
      if (!is.null(footnotes)) {
        footnotes <- paste0(footnotes_stat, ".\n", footnotes)
      } else {
        footnotes <- paste0(footnotes_stat, ".")
      }
    }
  }

  # Set column header
  colheader <- c(
    paste0(" | ", paste(group, collapse = " | ")),
    paste0(" | ", paste(rep("n | (%)", n_group), collapse = " | "))
  )

  # Set relative width
  if (is.null(col_rel_width)) {
    rel_width_body <- c(3, rep(1, 2 * n_group), 1)
  } else {
    rel_width_body <- col_rel_width
  }

  rel_width_head2 <- rel_width_body[1:(length(rel_width_body) - 1)]

  rel_width_head1 <- c(
    rel_width_head2[1],
    tapply(rel_width_head2[2:(n_group * 2 + 1)], c(rep(1:n_group, each = 2)), sum),
    rel_width_head2[-(1:(n_group * 2 + 1))]
  )

  # Column boarder
  border_top <- c("", rep("single", n_group * 2))
  border_top_body <- c(rep("", n_col - 1), "single")
  border_bottom <- c(rep("", n_col - 1), "single")
  border_left <- c("single", rep(c("single", ""), n_group))
  border_left_body <- c(border_left, "single")

  text_format <- c(rep("", 1 + n_group * 2), "b")

  # Using order number to customize row format
  text_justification <- c("l", rep("c", n_group * 2), "l")
  text_indent <- matrix(0, nrow = n_row, ncol = n_col)
  text_indent[, 1] <- ifelse(FALSE, 0, 100)
  text_indent[1, 1] <- 0

  # Use r2rtf
  outdata$rtf <- tbl |>
    r2rtf::rtf_page(orientation = orientation) |>
    r2rtf::rtf_title(title) |>
    r2rtf::rtf_colheader(
      colheader = colheader[1],
      col_rel_width = rel_width_head1,
      text_font_size = text_font_size
    ) |>
    r2rtf::rtf_colheader(
      colheader = colheader[2],
      border_top = border_top,
      border_left = border_left,
      col_rel_width = rel_width_head2,
      text_font_size = text_font_size
    ) |>
    r2rtf::rtf_body(
      page_by = "var_label",
      col_rel_width = rel_width_body,
      border_left = border_left_body,
      border_top = border_top_body,
      border_bottom = border_bottom,
      text_justification = text_justification,
      text_indent_first = text_indent,
      text_indent_left = text_indent,
      text_format = text_format,
      text_font_size = text_font_size
    )

  if (!is.null(footnotes)) {
    outdata$rtf <- outdata$rtf |>
      r2rtf::rtf_footnote(footnotes,
        text_font_size = text_font_size
      )
  }

  if (!is.null(source)) {
    outdata$rtf <- outdata$rtf |>
      r2rtf::rtf_source(source,
        text_font_size = text_font_size
      )
  }

  # Prepare output
  rtf_output(outdata, path_outdata, path_outtable)
}

#' Baseline characteristic table
#'
#' @inheritParams rtf_sl_summary
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#'
#' meta |>
#'   prepare_base_char(
#'     population = "apat",
#'     analysis = "base_char",
#'     parameter = "age;gender"
#'   ) |>
#'   format_base_char() |>
#'   rtf_base_char(
#'     source = "Source: [CDISCpilot: adam-adsl]",
#'     path_outdata = tempfile(fileext = ".Rdata"),
#'     path_outtable = tempfile(fileext = ".rtf")
#'   )
rtf_base_char <- rtf_sl_summary

#' Treatment compliance table
#'
#' @inheritParams rtf_sl_summary
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#'
#' meta |>
#'   prepare_trt_compliance(population = "apat", parameter = "comp8;comp16") |>
#'   format_trt_compliance() |>
#'   rtf_trt_compliance(
#'     source = "Source: [CDISCpilot: adam-adsl]",
#'     path_outdata = tempfile(fileext = ".Rdata"),
#'     path_outtable = tempfile(fileext = ".rtf")
#'   )
rtf_trt_compliance <- rtf_sl_summary


#' Disposition table
#'
#' @inheritParams rtf_sl_summary
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#'
#' meta |>
#'   prepare_disposition(population = "apat", parameter = "disposition;medical-disposition") |>
#'   format_disposition() |>
#'   rtf_disposition(
#'     source = "Source: [CDISCpilot: adam-adsl]",
#'     path_outdata = tempfile(fileext = ".Rdata"),
#'     path_outtable = tempfile(fileext = ".rtf")
#'   )
rtf_disposition <- rtf_sl_summary